function [Metric] = CalculateMetrics(Pareto, Nadir, Initial, Final, Precision, Selector, Config)

    switch Selector
        case 1
            FrontN = Pareto.FrontN;
        case 2
            FrontN = Pareto.PoC.FrontN;  
        case 3
            FrontN = Pareto.Updated.FrontN;         
    end

    if isempty(FrontN)
        warning("No solution in pareto set - CalculateMetrics");
        Metric = [0, NaN, NaN, 0, NaN];
        return;
    end
        
    % Cardinality
    metric_C  = size(Pareto.Set, 1);
    % Spacing
    metric_S  = spacing(Pareto.Set);
    % NRatio
    metric_NR = NRatio(Pareto.Set, Initial, Final, Precision);
    
    % Hypervolume
    FrontHV = FrontN;

    FrontHV = FrontHV(FrontHV(:,1) >= 0 & FrontHV(:,1) <= 1 & ...
                      FrontHV(:,2) >= 0 & FrontHV(:,2) <= 1, :);
    
    if isempty(FrontHV)
        metric_HV = 0;
    else
        try
            metric_HV = Hypervolume_MEX(FrontN, Nadir);
        catch
            warning("Hypervolume_MEX failed. Returning NaN.");
            metric_HV = NaN;
        end
    end
    
    % Kernel
    try
        metric_K = kernel_metric(FrontN, Nadir);
    catch
        metric_K = NaN;
    end

    metric_IGD = NaN;

    if Config.Operation.Problem == 5
        PFtrue = TrueParetoZDT1(1000);
        % usar FRONT SEM normalização do código
        metric_IGD = IGD(PFtrue, Pareto.Front);
    end

    % Store Metrics
    Metric = [metric_C, metric_S, metric_NR, metric_HV, metric_K, metric_IGD];
        
end