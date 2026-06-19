function ResultadoFinal = EvaluateFinalPareto(PopFinal, JxFinal, ExtJxFinal, MFEA, Database, Config)

    % Ajust precision
    X = RoundM(PopFinal, Config.Domain.Precision);

    % Remove dupes
    [~, ia] = unique(X, 'rows');
    X       = X(ia,:);
    FXs     = JxFinal(ia,:);
    ExtFXs  = ExtJxFinal(ia,:);

    valid = all(isfinite(FXs),2) & all(isfinite(ExtFXs),2) & all(isfinite(X),2);
    
    X      = X(valid,:);
    FXs    = FXs(valid,:);
    ExtFXs = ExtFXs(valid,:);
    
    if isempty(X)
        warning('EvaluateFinalPareto: all endpoints are invalid.');
        ResultadoFinal = struct();
        ResultadoFinal.X = [];
        ResultadoFinal.Model.Set = [];
        ResultadoFinal.Model.Front = [];
        ResultadoFinal.Model.ExtFront = [];
        ResultadoFinal.Real.Set = [];
        ResultadoFinal.Real.Front = [];
        ResultadoFinal.Real.ExtFront = [];
        ResultadoFinal.All.FModel = [];
        ResultadoFinal.All.FReal = [];
        ResultadoFinal.All.ExtFModel = [];
        ResultadoFinal.All.ExtFReal = [];
        ResultadoFinal.Database = Database;
        return;
    end

    %% Primeiro limita os candidatos pelo surrogate
    [Xsel, FXs_sel, rank_s, ~, index_s] = ...
        truncate(X, FXs, Config.Metaheuristic.Size);

    ExtFXs_sel = ExtFXs(index_s,:);
    disp(size(Xsel))
    %% Pareto pelo surrogate dentro dos selecionados
    Pareto_Index_s = find(rank_s == 1);

    ParetoSet_s      = Xsel(Pareto_Index_s,:);
    ParetoFront_s    = FXs_sel(Pareto_Index_s,:);
    ParetoExtFront_s = ExtFXs_sel(Pareto_Index_s,:);

    %% Avaliação real via ANSYS SOMENTE dos selecionados
    [FX, ~, Database, ExtFX, CostStats] = CostFunction(Xsel, Database, Config);
    MFEA.Statistics.TotalCostFunctionCalls = MFEA.Statistics.TotalCostFunctionCalls + 1;
    MFEA.Statistics.TotalRequestedPoints   = MFEA.Statistics.TotalRequestedPoints + CostStats.TotalRequestedPoints;
    MFEA.Statistics.NewAnsysCalls          = MFEA.Statistics.NewAnsysCalls + CostStats.NewAnsysCalls;
    MFEA.Statistics.ReusedDatabasePoints   = MFEA.Statistics.ReusedDatabasePoints + CostStats.ReusedDatabasePoints;
    MFEA.Statistics.TotalAnsysTime         = MFEA.Statistics.TotalAnsysTime + CostStats.TotalAnsysTime;
    MFEA.Statistics.TotalSimulationTime    = MFEA.Statistics.TotalSimulationTime + CostStats.TotalSimulationTime;



    %% Pareto real dos mesmos pontos selecionados
    [ParetoSet_r, ParetoFront_r, rank_r, ~, index_r] = ...
        truncate(Xsel, FX, Config.Metaheuristic.Size);

    ParetoExtFront_r = ExtFX(index_r,:);

    Pareto_Index_r = find(rank_r == 1);

    ParetoSet_r      = ParetoSet_r(Pareto_Index_r,:);
    ParetoFront_r    = ParetoFront_r(Pareto_Index_r,:);
    ParetoExtFront_r = ParetoExtFront_r(Pareto_Index_r,:);

    %% Saída
    ResultadoFinal = struct();

    ResultadoFinal.X = Xsel;

    ResultadoFinal.Model.Set = ParetoSet_s;
    ResultadoFinal.Model.Front = ParetoFront_s;
    ResultadoFinal.Model.ExtFront = ParetoExtFront_s;

    ResultadoFinal.Real.Set = ParetoSet_r;
    ResultadoFinal.Real.Front = ParetoFront_r;
    ResultadoFinal.Real.ExtFront = ParetoExtFront_r;

    ResultadoFinal.All.FModel = FXs_sel;
    ResultadoFinal.All.FReal = FX;
    ResultadoFinal.All.ExtFModel = ExtFXs_sel;
    ResultadoFinal.All.ExtFReal = ExtFX;

    ResultadoFinal.Database = Database;

end