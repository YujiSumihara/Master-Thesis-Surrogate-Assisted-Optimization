function [MFEA, Database] = SetupSurrogate(Database, Config)
    %disp('Dentro do Setup Surrogate')

    %% Surrogate Datastruct
    MFEA = struct();

    %% Statistics / Computational Cost
    MFEA.Statistics = struct();
    
    MFEA.Statistics.TotalCostFunctionCalls = 0;
    MFEA.Statistics.TotalRequestedPoints   = 0;
    
    MFEA.Statistics.NewAnsysCalls          = 0;
    MFEA.Statistics.ReusedDatabasePoints   = 0;
    
    MFEA.Statistics.TotalAnsysTime         = 0;
    MFEA.Statistics.TotalSimulationTime    = 0;
    
    MFEA.Statistics.TrainingPointsInitial  = 0;
    MFEA.Statistics.TrainingPointsFinal    = 0;
    
    MFEA.Statistics.NewTrainingPoints = 0;
    MFEA.Statistics.NewTrainingPointsHistory = [];
    
    % Iteration Populations
    MFEA.Population = struct();
    
    % Updates
	MFEA.Updates = struct();
    MFEA.Updates.Iteration = [];
    MFEA.Updates.Schedule  = [];
    MFEA.Updates.N         = 0;
    
    % Metrics
    MFEA.Metrics = struct();
    
        % Worst Possible Solution (Normalized)
        MFEA.Metrics.Nadir = ones(1, Config.Objectives.Number);
        % Normalization Fix
        MFEA.Metrics.NormalizationFix = [-1, ones(1, Config.Objectives.Number - 1)]; 
        
        % Metaheuristic
        MFEA.Metrics.Metaheuristic = struct();
        % On-the-fly Metrics
        MFEA.Metrics.Metaheuristic.OTF = [];
        % Updated Metrics
        MFEA.Metrics.Metaheuristic.Updated = [];
    
        % Surrogate
        MFEA.Metrics.Surrogate = struct();
        % Population Space Filling Metrics
        MFEA.Metrics.Surrogate.SpaceFilling = [];
        % Pareto Front RMS Metrics
        MFEA.Metrics.Surrogate.RMS = [];
        % Pareto Front Norm Metrics
        MFEA.Metrics.Surrogate.NORM = [];
    
    % Cost Function Validation   
    MFEA.Validation              = struct();   
    MFEA.Validation.Iteration    = [];
    MFEA.Validation.Accumulative = [];
    
    % Proof of Concept
    MFEA.PoC             = struct();
    MFEA.PoC.Iteration   = [];
    MFEA.PoC.N           = 0;
    MFEA.PoC.Pareto.RMS  = [];
    MFEA.PoC.Pareto.NORM = [];
    MFEA.PoC.Metrics     = [];
    
    % Proof of Concept #2
    MFEA.PoC2        = struct();
    MFEA.PoC2.N      = 0;
    MFEA.PoC2.X      = [];
    MFEA.PoC2.Fx     = [];
    MFEA.PoC2.ExtFx  = [];
    MFEA.PoC2.FxN    = [];
    MFEA.PoC2.ExtFxN = [];
    MFEA.PoC2.Jx     = [];
    MFEA.PoC2.ExtJx  = [];
    MFEA.PoC2.JxN    = [];
    MFEA.PoC2.ExtJxN = [];
    MFEA.PoC2.RMS    = [];
    MFEA.PoC2.NORM   = [];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    %% Generate Training Points
    PopDist = createDist(Config.Surrogates.Initial, Config.Dimension.Number, ...
                         Config.Surrogates.Method, Config.Surrogates.Mode);
    
    % Seed Traning Points: Speedy up debug/dev
    if Config.Surrogates.Seed.Flag
        
        if isfile(Config.Surrogates.Seed.File)
            load(Config.Surrogates.Seed.File);           
        else       
            save(Config.Surrogates.Seed.File, 'PopDist');            
        end
    
    end
    
    % Re-scale Distribution to the Search Domain
    MFEA.Xs = Config.Domain.Initial + (Config.Domain.Final - Config.Domain.Initial) .* PopDist;
    
    % Ajust Precision
    MFEA.Xs = RoundM(MFEA.Xs, Config.Domain.Precision);
    
    % Remove dupes
    MFEA.Xs = unique(MFEA.Xs, 'rows');    
    
    % Number of unique training points
    MFEA.Ns = size(MFEA.Xs,1);

    MFEA.Statistics.TrainingPointsInitial = MFEA.Ns;
    MFEA.Statistics.TrainingPointsFinal   = MFEA.Ns;
    
    %% Metrics
    
    % Evaluate the distribution of the training points
    if Config.Operation.Problem < 5
	    [~, metric_SF, metric_SF_n] = fill_avg(MFEA.Xs, 5, Config.Domain.Precision, ...
                                           Config.Domain.Initial, Config.Domain.Final, ...
                                           Config.SpaceFilling.lower_bound, Config.SpaceFilling.upper_bound, ...
                                           Config.SpaceFilling.deep_level, Config.SpaceFilling.behavior, ...
                                           Config.SpaceFilling.grid, Config.SpaceFilling.D_factor, ...
                                           Config.SpaceFilling.R_factor); %Pasta fill
                                       
	    MFEA.Metrics.Surrogate.SpaceFilling = [metric_SF, metric_SF_n];
    else
        MFEA.Metrics.Surrogate.SpaceFilling = [];
    end
    
    %% Evaluate Cost Function
    
    % Objectives
    MFEA.FXs    = zeros(MFEA.Ns, Config.Objectives.Number);
    
    % Extended Objectives 
    MFEA.ExtFXs = zeros(MFEA.Ns, Config.ExtObjectives.Number);
    
    % Evaluation

    %disp('Avaliando MFEA.xs')
    [MFEA.FXs, FxEvaluations, Database, MFEA.ExtFXs, CostStats] = CostFunction(MFEA.Xs, Database, Config); %Pasta principal _ retorna resultados da função custo real

    MFEA.Statistics.TotalCostFunctionCalls = MFEA.Statistics.TotalCostFunctionCalls + 1;
    MFEA.Statistics.TotalRequestedPoints   = MFEA.Statistics.TotalRequestedPoints + CostStats.TotalRequestedPoints;
    MFEA.Statistics.NewAnsysCalls          = MFEA.Statistics.NewAnsysCalls + CostStats.NewAnsysCalls;
    MFEA.Statistics.ReusedDatabasePoints   = MFEA.Statistics.ReusedDatabasePoints + CostStats.ReusedDatabasePoints;
    MFEA.Statistics.TotalAnsysTime         = MFEA.Statistics.TotalAnsysTime + CostStats.TotalAnsysTime;
    MFEA.Statistics.TotalSimulationTime    = MFEA.Statistics.TotalSimulationTime + CostStats.TotalSimulationTime;
    MFEA.Statistics.TrainingPointsFinal    = MFEA.Ns;
    
    % Log Real Function Evaluations
    MFEA.Evaluations = [0, FxEvaluations];
     
    % Generate Objectives Surrogates
    MFEA = Surrogates(MFEA, Config); % Pasta Surrogate - Retona Lambda e C dos objetivos e objetivos externos
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Proof of Concept
    if (Config.Operation.Problem < 5)

        % Grid
        MFEA.PoC2.X = createGrid(Config.PoC.Grid, Config.Domain.Initial, Config.Domain.Final, Config.Domain.Precision);
        
        % Grid Size
        MFEA.PoC2.N = size(MFEA.PoC2.X, 1);
        
        % Evaluation Cost Function

        %disp('Criando o MFEA.POC2.Fx')
        [MFEA.PoC2.Fx, ~, Database, MFEA.PoC2.ExtFx, CostStats] = CostFunction(MFEA.PoC2.X, Database, Config); % retorna o valor da função custo

        MFEA.Statistics.TotalCostFunctionCalls = MFEA.Statistics.TotalCostFunctionCalls + 1;
        MFEA.Statistics.TotalRequestedPoints   = MFEA.Statistics.TotalRequestedPoints + CostStats.TotalRequestedPoints;
        MFEA.Statistics.NewAnsysCalls          = MFEA.Statistics.NewAnsysCalls + CostStats.NewAnsysCalls;
        MFEA.Statistics.ReusedDatabasePoints   = MFEA.Statistics.ReusedDatabasePoints + CostStats.ReusedDatabasePoints;
        MFEA.Statistics.TotalAnsysTime         = MFEA.Statistics.TotalAnsysTime + CostStats.TotalAnsysTime;
        MFEA.Statistics.TotalSimulationTime    = MFEA.Statistics.TotalSimulationTime + CostStats.TotalSimulationTime;
	    
        % Estimate Cost Function
	    [MFEA.PoC2.Jx, MFEA.PoC2.ExtJx] = CostFunctionRBF(MFEA.PoC2.X, MFEA, Config); % retorna a função custo aproximada por RBF
        
	    % Normalize Data
	    MFEA.PoC2.FxN    = NormalizeColumn(MFEA.PoC2.Fx, ...
                                           Config.Normalization.Minimum, ...
                                           Config.Normalization.Maximum);
	    MFEA.PoC2.JxN    = NormalizeColumn(MFEA.PoC2.Jx, ...
                                           Config.Normalization.Minimum, ...
                                           Config.Normalization.Maximum);    
	    MFEA.PoC2.ExtFxN = NormalizeColumn(MFEA.PoC2.ExtFx, ...
                                           Config.ExtNormalization.Minimum, ...
                                           Config.ExtNormalization.Maximum);    
	    MFEA.PoC2.ExtJxN = NormalizeColumn(MFEA.PoC2.ExtJx, ...
                                           Config.ExtNormalization.Minimum, ...
                                           Config.ExtNormalization.Maximum);
        
        A = [MFEA.PoC2.FxN, MFEA.PoC2.ExtFxN]; %função custo por ANSYS (calculado)
        B = [MFEA.PoC2.JxN, MFEA.PoC2.ExtJxN]; %função custo por rbf (aproximado)
        
        RMS  = sqrt(mean((A - B).^2));
	    NORM = zeros(MFEA.PoC2.N, 1);
    
        for i=1:MFEA.PoC2.N
    
            NORM(i) = norm(A(i,:) - B(i,:));
    
        end
    
        DataNORM = [min(NORM), median(NORM), mean(NORM), max(NORM)];
    
        MFEA.PoC2.RMS  = [MFEA.PoC2.RMS; RMS];
        MFEA.PoC2.NORM = [MFEA.PoC2.NORM; DataNORM];    
    else
        MFEA.PoC2.N      = 0;
        MFEA.PoC2.X      = [];
        MFEA.PoC2.Fx     = [];
        MFEA.PoC2.ExtFx  = [];
        MFEA.PoC2.FxN    = [];
        MFEA.PoC2.ExtFxN = [];
        MFEA.PoC2.Jx     = [];
        MFEA.PoC2.ExtJx  = [];
        MFEA.PoC2.JxN    = [];
        MFEA.PoC2.ExtJxN = [];
        MFEA.PoC2.RMS    = [];
        MFEA.PoC2.NORM   = [];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
    %% Sequence of Scheduled Updates
    UpdateNumber = 1:20;
    
    switch Config.Surrogates.Update.Curve
        % 10 Updates 20	24	30	39	51	69	94	130	182	260      376 550	816	1223	1854	2842	4403	6891	10894	17393
        case 2
            Schedule = round((18 + UpdateNumber.^1.2) .* exp(UpdateNumber.^1.5 /  25).^1.612);       
        % 15 Updates 20	23	28	34	43	54	69	88	113	146	189	245	320	419	550	725	958	1271	1691	2259
        case 3
            Schedule = round((18 + UpdateNumber.^1.5) .* exp(UpdateNumber.^1.5 /  40).^1.362);       
        % 20 Updates 19	22	27	35	44	56	71	88	108	130	155	184	216	251	290	333	381	432	489	550
        case 4
            Schedule = round((18 + UpdateNumber.^2.0) .* exp(UpdateNumber.^1.5 / 150).^0.460);
        % 0 Updates
        otherwise
            Schedule = [];   
    end
    
    MFEA.Updates.Schedule = Schedule;
    
    if (Config.Dimension.Number ~= 2 && Config.SpaceFilling.Strategy == 3) %only 1 &
       
        error('Error: Incompatible Filling Strategy!');
        
    end

end