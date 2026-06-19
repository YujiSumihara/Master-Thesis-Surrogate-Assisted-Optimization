function [x, f_ind, f_ind_ex] = FixPopulationSize(x, f_ind, f_ind_ex, MFEA, Config)

    Ntarget  = Config.Metaheuristic.Size;
    Ncurrent = size(x,1);

    if Ncurrent < Ntarget

        Nmissing = Ntarget - Ncurrent;

        % Gera novos indivíduos aleatórios
        Xnew = Config.Domain.Initial + ...
               (Config.Domain.Final - Config.Domain.Initial) .* ...
               rand(Nmissing, Config.Dimension.Number);

        % Avalia com surrogate
        [Fnew,~,~,FnewE] = CostFunction(Xnew, [], Config);

        % Junta com população atual
        x        = [x; Xnew];
        f_ind    = [f_ind; Fnew];
        f_ind_ex = [f_ind_ex; FnewE];

    end

end