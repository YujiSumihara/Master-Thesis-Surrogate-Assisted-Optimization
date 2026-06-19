%% MFEA = MetaFEA
function Output = MFEA_Return(Config)

    %% Add directories 
    addpath('libs');
    addpath('libs/fill');
    addpath('libs/init');
    addpath('libs/metric');
    addpath('libs/plot');
    addpath('libs/setup');
    addpath('libs/surrogate');
    addpath('libs/strategy');
    addpath('libs/tools');
    addpath('libs/update');
    
    %% Setup: Surrogate's Environment
    [MFEA, Database, Config] = Setup(Config);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %% MODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Memory Allocation
    
    % Population
        % Parent
        Parent = zeros(Config.Metaheuristic.Size, Config.Dimension.Number);
        % Mutant
        Mutant = zeros(Config.Metaheuristic.Size, Config.Dimension.Number);
        % Child
        Child  = zeros(Config.Metaheuristic.Size, Config.Dimension.Number);   
    
    % Objectives
        % Parent
        JxParent = zeros(Config.Metaheuristic.Size, Config.Objectives.Number);
        % Child
        JxChild  = zeros(Config.Metaheuristic.Size, Config.Objectives.Number); 
    
    % Extended Objectives   
        % Parent
        ExtJxParent = zeros(Config.Metaheuristic.Size, 1);
        % Child
        ExtJxChild  = zeros(Config.Metaheuristic.Size, 1);    
    
	% Chosen: Recovery Pareto Candidates from previous iterations
        Chosen = struct();
        % Population
        Chosen.Pop   = [];
        % Objectives
        Chosen.Jx    = [];
        % Extended Objectives
        Chosen.ExtJx = [];    
        
        
    %% Initialization
    PopDist = createDist(Config.Metaheuristic.Size, Config.Dimension.Number, ...
                         Config.Metaheuristic.Method, Config.Metaheuristic.Mode);
    
    % Seed Traning Points
    if Config.Metaheuristic.Seed.Flag
        
        if isfile(Config.Metaheuristic.Seed.File)
            load(Config.Metaheuristic.Seed.File);           
        else       
            save(Config.Metaheuristic.Seed.File, 'PopDist');            
        end
    
    end
    
    % Re-Scale Distribution
    %Inicialização vetorial contínua
    Parent = Config.Domain.Initial + (Config.Domain.Final - Config.Domain.Initial) .* PopDist;

    % Evaluate Cost Function through Models
    % Avaliação multiobjetivo
    [JxParent, ExtJxParent] = CostFunctionRBF(Parent, MFEA, Config);
    %f(x)                                       x
    invalid = any(~isfinite(JxParent),2);

    if any(invalid)
        warning('%d pontos com NaN/Inf no surrogate foram penalizados.', sum(invalid));
    
        JxParent(invalid,:) = repmat(Config.Normalization.Maximum, sum(invalid), 1) * 10;
    
        if ~isempty(ExtJxParent)
            ExtJxParent(invalid,:) = repmat(Config.ExtNormalization.Maximum, sum(invalid), 1) * 10;
        end
    end
    %% Iteractive Process
    for Iter = 1:Config.Iter.Max
        
        fprintf("==> Iter MODE %d\n", Iter);
        
        %% Generate Child Population
        for xpop = 1:Config.Metaheuristic.Size
            
            % Permutation Vector
            % a cada interação existirá um rev diferente para permutação
            rev = randperm(Config.Metaheuristic.Size);

            % Population: Mutant
            %DE/rand/1
            Mutant(xpop,:) = Parent(rev(1,1),:) + Config.Metaheuristic.ScalingFactor * (Parent(rev(1,2),:) - Parent(rev(1,3),:));

            % Domain Bounds
            for i = 1:Config.Dimension.Number
                
                % Upper Bound
                if Mutant(xpop,i) > Config.Domain.Final(i)                    
                    %Mutant(xpop,i) = Config.Domain.Final(i);
                    Mutant(xpop,i) = Config.Domain.Final(i) - rand() * (Config.Domain.Final(i) - Config.Domain.Initial(i)) * 0.1;
                    
                % Lower Bound
                elseif Mutant(xpop,i) < Config.Domain.Initial(i)                   
                    %Mutant(xpop,i) = Config.Domain.Initial(i);
                    Mutant(xpop,i) = Config.Domain.Initial(i) + rand() * (Config.Domain.Final(i) - Config.Domain.Initial(i)) * 0.1;
                end
                
            end

            % Crossover binomial
            for i = 1:Config.Dimension.Number
                
                % Keep original
                if rand() > Config.Metaheuristic.CrossOver %se rand() maior que taxa de crossover, pego parente
                    Child(xpop,i) = Parent(xpop,i);
                    if Child(xpop,i) > Config.Domain.Final(i)
                        Child(xpop,i) = Config.Domain.Final(i);
                    elseif Child(xpop,i) < Config.Domain.Initial(i)
                        Child(xpop,i) = Config.Domain.Initial(i);
                    end
                
                % Mutation
                else                  
                    Child(xpop,i) = Mutant(xpop,i);
                    
                end
                
            end

        end

        % Evaluate Child Population through Models
        % Avaliação multiobjetiva
        [JxChild, ExtJxChild] = CostFunctionRBF(Child, MFEA, Config);   %avalia a função custo do trial - child  
        % fu                                     u
        invalid = any(~isfinite(JxChild),2);
        if any(invalid)
            warning('%d pontos com NaN/Inf no surrogate foram penalizados.', sum(invalid));
        
            JxChild(invalid,:) = repmat(Config.Normalization.Maximum, sum(invalid), 1) * 10;
        
            if ~isempty(ExtJxChild)
                ExtJxParent(invalid,:) = repmat(Config.ExtNormalization.Maximum, sum(invalid), 1) * 10;
            end
        end
        %% Selection
        
        % Population (arquivo externo com soluções)
        Pop      = [Parent; Child; Chosen.Pop];
        % Cost Function
        JxPop    = [JxParent; JxChild; Chosen.Jx];
        % Ext Cost Function
        ExtJxPop = [ExtJxParent; ExtJxChild; Chosen.ExtJx];
        
        % Reset Chosen Ones
        Chosen.Pop   = [];
        Chosen.Jx    = [];
        Chosen.ExtJx = [];
            
        % Identify dupes
        PopRM    = RoundM(Pop, Config.Domain.Precision);
        [~, ia]  = unique(PopRM, 'rows');
            
        % Remove dupes
        Pop      = Pop(ia,:);
        JxPop    = JxPop(ia,:);
        ExtJxPop = ExtJxPop(ia,:);

        %% Parte extra pra verificar restricao

        % Enforce Restrictions
        if (Config.Restriction.Flag)
            [JxPop, ~] = Restriction(JxPop, Config); %penaliza com os valores de penalidade
            
        end
        
        % Surrogate Cost Functions (evita regiões mal modeladas e
        % incentivar exploração segura)
        DxPop = NeighborsProximity(Pop, MFEA.Xs, MFEA.Ns, Config.Domain.Precision); %surrogates pasta
        
        switch Config.Operation.SurrogateCostFunction

            % Min. Distance Towards Training Points Population
            case {1}       
                JxPop = [JxPop, DxPop];
                
        end
        
        % Rank Population - uso do truncate
        %Seleção por não-dominancia estilo NSGA-II
        [rank, ~, index] = TruncateIndex(JxPop, Config.Metaheuristic.Size);     %Calcula rank e organiza os index
        Parent      = Pop(index,:);
        JxParent    = JxPop(index,1:Config.Objectives.Number);
        ExtJxParent = ExtJxPop(index,:);
        DxParent    = DxPop(index,:);
                
        % Store Iteration Population
        MFEA.Population.([sprintf('Iter%d', Iter)]) = Parent;

        %% Fim selecao - fim MODE

        %% Cost Function Validation
        [Violations, MFEA] = Validation(Iter, JxParent, ExtJxParent, MFEA, Config); %%

        %% Pareto Front Sanitization %Necessita de avaliação melhor
        %gera pareto set e pareto front
        Pareto = Sanitization(Parent, ...
                              JxParent, ...
                              ExtJxParent, ...
                              DxParent, ...
                              rank, ...
                              Violations, ...
                              Config.Domain.Precision, ...
                              Config.Normalization.Minimum, ...
                              Config.Normalization.Maximum, ...
                              Config.ExtNormalization.Minimum, ...
                              Config.ExtNormalization.Maximum);
    
        %% Metaheuristic Metrics - valores do pareto set      
        Metric = CalculateMetrics(Pareto, MFEA.Metrics.Nadir, ...
                                  Config.Domain.Initial, ...
                                  Config.Domain.Final, ...
                                  Config.Domain.Precision, ...
                                  1,Config);

        MFEA.Metrics.Metaheuristic.OTF = [MFEA.Metrics.Metaheuristic.OTF; Metric];
                
        % Plot Flag
        plotFlag = false;
        
        %% Proof of Concept (ANSYS)
        if (Config.PoC.Flag && (Iter == 1 || rem(Iter, Config.PoC.Frequency) == 0)) % se o resto da divicao for zero

            disp('Estou no POC 1')
            [Pareto, MFEA, Database] = PoC(Iter, Pareto, MFEA, Database, Config); %chama o ansys a apartir da função costfunction
                
            % Plot Flag
            plotFlag = true;

        end

        %% Surrogate Update
        if (MFEA.Ns < Config.Surrogates.Limit)
            
            if (ismember(Iter, MFEA.Updates.Schedule) || ...
                mov_mean(MFEA.Validation.Iteration, 3) > Config.Metaheuristic.Size * 0.20 || ...
                MFEA.Validation.Accumulative(end)      > Config.Metaheuristic.Size * 0.75)
                disp('Estou no Surrogate')
                % Reset Accumulative Violation
                MFEA.Validation.Accumulative(end) = 0;

                % Update Training Points         
                MFEA = UpdatePopulation(Iter, Parent, MFEA, Config); %tecnicas de space filling

                % Update Models
                [MFEA, Database] = UpdateModels(Iter, MFEA, Database, Config); %calcula função custo real

                % Reavaluate Parent Population through Models
                [JxParent, ExtJxParent] = CostFunctionRBF(Parent, MFEA, Config);

                invalid = any(~isfinite(JxParent),2);
                if any(invalid)
                    warning('%d pontos com NaN/Inf no surrogate foram penalizados.', sum(invalid));
                
                    JxParent(invalid,:) = repmat(Config.Normalization.Maximum, sum(invalid), 1) * 10;
                
                    if ~isempty(ExtJxParent)
                        ExtJxParent(invalid,:) = repmat(Config.ExtNormalization.Maximum, sum(invalid), 1) * 10;
                    end
                end

                % Update Previous Iterations Metrics            
                [Chosen, MFEA] = UpdateMetrics(Iter, MFEA, Config);%Validation, Sanitization, Restriction
                
                % Pareto
                Pareto.Updated.Flag = true;
                
                [Pareto.Updated.Front, Pareto.Updated.ExtFront] = CostFunctionRBF(Pareto.Set, MFEA, Config);
                
                Pareto.Updated.Distance = NeighborsProximity(Pareto.Set, MFEA.Xs, MFEA.Ns, Config.Domain.Precision);
                
                Pareto.Updated.FrontN = NormalizeColumn(Pareto.Updated.Front, ...
                                                       Config.Normalization.Minimum, ...
                                                       Config.Normalization.Maximum);
                Pareto.Updated.ExtFrontN = NormalizeColumn(Pareto.Updated.ExtFront, ...
                                                          Config.ExtNormalization.Minimum, ...
                                                          Config.ExtNormalization.Maximum);
    
                % Compare Pareto 
                [RMS, DataNORM] = ComparePareto(Pareto, 2);% 2 = compara com o update
                
                MFEA.Metrics.Surrogate.RMS  = [MFEA.Metrics.Surrogate.RMS; RMS];
                MFEA.Metrics.Surrogate.NORM = [MFEA.Metrics.Surrogate.NORM; DataNORM];

                % PoC #2
                disp('Estou no POC 2')
                % Estimate Cost Function
                [MFEA.PoC2.Jx, MFEA.PoC2.ExtJx] = CostFunctionRBF(MFEA.PoC2.X, MFEA, Config);

                % Normalize Data
                MFEA.PoC2.JxN    = NormalizeColumn(MFEA.PoC2.Jx, ...
                                                   Config.Normalization.Minimum, ...
                                                   Config.Normalization.Maximum);       
                MFEA.PoC2.ExtJxN = NormalizeColumn(MFEA.PoC2.ExtJx, ...
                                                   Config.ExtNormalization.Minimum, ...
                                                   Config.ExtNormalization.Maximum);

                A = [MFEA.PoC2.FxN, MFEA.PoC2.ExtFxN]; %Ansys
                B = [MFEA.PoC2.JxN, MFEA.PoC2.ExtJxN]; %Surrogate

                RMS  = sqrt(mean((A - B).^2));
                NORM = zeros(MFEA.PoC2.N, 1);

                for i=1:MFEA.PoC2.N

                    NORM(i) = norm(A(i,:) - B(i,:));% distancia entre dois pontos

                end

                DataNORM = [min(NORM), median(NORM), mean(NORM), max(NORM)];

                MFEA.PoC2.RMS  = [MFEA.PoC2.RMS; RMS];
                MFEA.PoC2.NORM = [MFEA.PoC2.NORM; DataNORM]; 
                
                % Plot Flag
                plotFlag = true;
                
            else

                MFEA.Evaluations = [MFEA.Evaluations; [Iter, MFEA.Evaluations(end,2:3)]];   
                
            end
        
        end
        
        %% Plot Progress
        if (plotFlag || Iter == 1 || Iter == Config.Iter.Max || ismember(Iter + 1, MFEA.Updates.Schedule)) 

            if (Config.Graphic.Flag)
                %PlotProgress3(Iter, Pareto, MFEA, Config);  
                PlotProgress(Iter, Pareto, MFEA, Config);
            end

        end
        
    end
    
    %% Return Results
	%OutputResults(Parent, JxParent, ExtJxParent, MFEA, Database, Config);

    disp('Avaliacao final')
    Final = EvaluateFinalPareto(Parent, JxParent, ExtJxParent, MFEA, Database, Config);

    Output.Final = Final;
    Output.Pareto.Model = Final.Model;
    Output.Pareto.Real  = Final.Real;
    Output.Database = Final.Database;
    Output.MFEA = MFEA;
    Output.Config = Config;

    MFEA.Statistics.TrainingPointsFinal = MFEA.Ns;

    Output.Statistics = MFEA.Statistics;
    Output.Statistics.FinalEvaluations = MFEA.Evaluations(end,:);

    %% salva workspace
    expname = sprintf("MFEA_%d_%s.mat", Config.runid, Config.Hash);

    savePath = fullfile(Config.runsFolder, expname);

    save(savePath);
end