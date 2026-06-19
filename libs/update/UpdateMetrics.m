function [Chosen, MFEA] = UpdateMetrics(Iter, MFEA, Config)
    
    Chosen = struct();
    Chosen.Pop   = [];
    Chosen.Jx    = [];
    Chosen.ExtJx = [];
    
    % Reset Updated Metrics
    MFEA.Metrics.Metaheuristic.Updated = [];
        
    for i=1:Iter

        % Recovery Previous Population
        Pop = MFEA.Population.([sprintf('Iter%d', i)]);

        % Recalculate Cost Function
        [JxPop,ExtJxPop] = CostFunctionRBF(Pop, MFEA, Config); 

        % Identify dupes
        PopRM    = RoundM(Pop, Config.Domain.Precision);
        [~, ia]  = unique(PopRM, 'rows');
        
        % Remove dupes
        Pop      = Pop(ia,:);
        JxPop    = JxPop(ia,:);
        ExtJxPop = ExtJxPop(ia,:);

        % Enforce Restrictions
        if Config.Restriction.Flag
            [JxPop, ~] = Restriction(JxPop, Config);
        end
        
        % Add Distance as a Cost Function
        DxPop = NeighborsProximity(Pop, MFEA.Xs, MFEA.Ns, Config.Domain.Precision);
        
        switch Config.Operation.SurrogateCostFunction

            % Min. Distance Towards Training Points Population
            case {1}       
                JxPop = [JxPop, DxPop];
                
        end 
        
        % Rank Population        
        [rank, ~, index] = TruncateIndex(JxPop, Config.Metaheuristic.Size);
        Pop      = Pop(index,:);
        JxPop    = JxPop(index,:);
        ExtJxPop = ExtJxPop(index,:);  
        DxPop    = DxPop(index,:);       

        % Update Chosen Ones
        Chosen.Pop   = [Chosen.Pop; Pop];                
        Chosen.Jx    = [Chosen.Jx; JxPop];               
        Chosen.ExtJx = [Chosen.ExtJx; ExtJxPop];
        
        % Cost Function Validation
        [Violations, ~] = Validation(Iter, JxPop, ExtJxPop, MFEA, Config, false);
        
        % Pareto Front Sanitization
        Pareto_i = Sanitization(Pop, ...
                                JxPop, ...
                                ExtJxPop, ...
                                DxPop, ...
                                rank, ...
                                Violations, ...
                                Config.Domain.Precision, ...
                                Config.Normalization.Minimum, ...
                                Config.Normalization.Maximum, ...
                                Config.ExtNormalization.Minimum, ...
                                Config.ExtNormalization.Maximum);

        % Metrics       
        Metric = CalculateMetrics(Pareto_i, ...
                                  MFEA.Metrics.Nadir, ...
                                  Config.Domain.Initial, ...
                                  Config.Domain.Final, ...
                                  Config.Domain.Precision, ...
                                  1, ...
                                  Config);

        MFEA.Metrics.Metaheuristic.Updated = [MFEA.Metrics.Metaheuristic.Updated; Metric];

    end 

end