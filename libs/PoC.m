function [Pareto, MFEA, Database] = PoC(Iter, Pareto, MFEA, Database, Config)
%Avalia o PAreto usando a função real e compara com o pareto estimado pelo
%surrogate. Ansys vs Surrogate

    %Flag
    Pareto.PoC.Flag = true;

    % Evaluations
    [Pareto.PoC.Front, ~, Database, Pareto.PoC.ExtFront, CostStats] = CostFunction(Pareto.Set, Database, Config);
    MFEA.Statistics.TotalCostFunctionCalls = MFEA.Statistics.TotalCostFunctionCalls + 1;
    MFEA.Statistics.TotalRequestedPoints   = MFEA.Statistics.TotalRequestedPoints + CostStats.TotalRequestedPoints;
    MFEA.Statistics.NewAnsysCalls          = MFEA.Statistics.NewAnsysCalls + CostStats.NewAnsysCalls;
    MFEA.Statistics.ReusedDatabasePoints   = MFEA.Statistics.ReusedDatabasePoints + CostStats.ReusedDatabasePoints;
    MFEA.Statistics.TotalAnsysTime         = MFEA.Statistics.TotalAnsysTime + CostStats.TotalAnsysTime;
    MFEA.Statistics.TotalSimulationTime    = MFEA.Statistics.TotalSimulationTime + CostStats.TotalSimulationTime;

    % Backup Database    
    save([Config.Database.Path + Config.Database.Filename], 'Database');
    
    % Normalized Pareto Front
	Pareto.PoC.FrontN    = NormalizeColumn(Pareto.PoC.Front, ...
                                           Config.Normalization.Minimum, ...
                                           Config.Normalization.Maximum);   
	Pareto.PoC.ExtFrontN = NormalizeColumn(Pareto.PoC.ExtFront, ...
                                           Config.ExtNormalization.Minimum, ...
                                           Config.ExtNormalization.Maximum);

     % Compare Pareto 
    [RMS, DataNORM] = ComparePareto(Pareto, 1);   
    
	MFEA.PoC.Pareto.RMS  = [MFEA.PoC.Pareto.RMS; RMS]; 
	MFEA.PoC.Pareto.NORM = [MFEA.PoC.Pareto.NORM; DataNORM]; 
    
    % Iteration
    MFEA.PoC.Iteration = [MFEA.PoC.Iteration; Iter];

    % N
    MFEA.PoC.N = MFEA.PoC.N + 1;
    
    % Metrics
    Metric = CalculateMetrics(Pareto, ...
                              MFEA.Metrics.Nadir, ...
                              Config.Domain.Initial, ...
                              Config.Domain.Final, ...
                              Config.Domain.Precision, ...
                              2, ...
                              Config);
	MFEA.PoC.Metrics = [MFEA.PoC.Metrics; Metric(:,3:4)];
 
end