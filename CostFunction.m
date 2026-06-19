function [Fx, FxEvaluations, Database, ExtFx, CostStats] = CostFunction(X, Database, Config)
    

    if Config.Operation.Problem == 5 || Config.Operation.Mode == "BENCHMARK" % ZDT1

        N = size(X,1);
        Fx = zeros(N,2);
        ExtFx = zeros(N, Config.ExtObjectives.Number);

        n = size(X,2);

        for i=1:N
            f1 = X(i,1);
            g  = 1 + 9*sum(X(i,2:end))/(n-1);
            f2 = g*(1 - sqrt(f1/g));

            Fx(i,:) = [f1 f2];
        end

        FxEvaluations = [N, 0];
        return
    end
    
    Queue = [];
    
    N = size(X,1);

    CostStats = struct();

    CostStats.TotalRequestedPoints = size(X,1);
    CostStats.NewAnsysCalls = 0;
    CostStats.ReusedDatabasePoints = 0;
    CostStats.TotalAnsysTime = 0;
    CostStats.TotalSimulationTime = 0;
    
    %% Check Database    
    for k = 1:N
    
        Index = GetIndexNumber(X(k,:), Config);
        
        % Add Candidate Solution do Queue        
        if (Database.Index(Index) == 0)            
            Queue = [Queue; X(k,:)];            
        end
        
    end
      
    QueueNumber = size(Queue,1);

    CostStats.NewAnsysCalls = QueueNumber;
    CostStats.ReusedDatabasePoints = N - QueueNumber;

	% Print Information
	fprintf("Cost Function Evaluation: %d simulations.\n", QueueNumber);
            
    % Update Number of the Real Cost Function Evaluations
    FxEvaluations = [N, N - QueueNumber];
        
    %% Simulation
    if (QueueNumber > 0)
    
        % Simulation Timer
        tSimulation = tic;
        
        batch = ceil(QueueNumber / Config.Ansys.BatchNumber);
        
        % Batch
        for i = 1:batch
        
            % Batch Timer
            tBatch = tic;
            
            BatchInitial = 1 + (i-1) * Config.Ansys.BatchNumber;
            BatchFinal   = min([i * Config.Ansys.BatchNumber, QueueNumber]);
            
            % Batch Queue
            Queue_i = Queue(BatchInitial:BatchFinal,:);
            
            % Batch Queue Size
            QueueNumber_i = size(Queue_i, 1);
            
            % Print Information
            fprintf("\tBatch %d / %d: %d simulations", i, batch, QueueNumber_i);
    
            % Create Input File
            inputPath = fullfile(Config.RootPath, 'ansys', char(Config.Ansys.Project), 'input.txt');
            inputFile = fopen(inputPath, 'w');
            
            if inputFile < 0
                error("Could not open ANSYS input.txt for writing:\n%s", inputPath);
            end

            for k = 1:Config.Dimension.Number % coloca os dados dos parametros a serem otimizados

                fprintf(inputFile,'%0.2f,',Queue_i(:,k));
                fprintf(inputFile,'\n');

            end

            % Close Input file
            fclose(inputFile);
            pause(1);

            % fprintf('\nInput file:\n');
            % type(inputPath);
            % fprintf('\n');

            % ANSYS
            [data, ~, ~] = ANSYS(QueueNumber_i, Config); %Pega os dados do output do Ansys

            % Update Database
            for k=1:QueueNumber_i

                [Entry, Param] = DatabaseEntry(k, data, Config); %Pasta principal, retorna os dados de cada parametro de acordo com o problema

                Index = GetIndexNumber(Param', Config);

                % Insert into Database
                Database.Data.([sprintf("D%d", Index)]) = Entry;
                
                % Update Index
                Database.Index(Index) = 1;

            end
            
            % Backup Database
            save([Config.Database.Path + Config.Database.Filename], 'Database');

            % Print Information
            tDelta = toc(tBatch);
            fprintf(" @ [Total = %6.2f s, Mean = %6.2f s]\n", tDelta, tDelta / QueueNumber_i);

            %caso trave durante a execução

            CostLogFile = Config.Database.Path + "CostLog_" + Config.Database.Filename;
            
            if isfile(CostLogFile)
                load(CostLogFile, 'CostLog');
            else
                CostLog = table();
            end
            
            NewRow = table( ...
                string(Config.Hash), ...
                Config.runid, ...
                i, ...
                QueueNumber_i, ...
                tDelta, ...
                tDelta / QueueNumber_i, ...
                datetime("now"), ...
                'VariableNames', {'Hash','RunID','Batch','NewAnsysCalls','BatchTime_s','MeanTime_s','DateTime'} ...
            );
            
            CostLog = [CostLog; NewRow];
            
            save(CostLogFile, 'CostLog');
    
        end
        
         % Print Information
        tDeltaSimulation = toc(tSimulation);

        CostStats.TotalSimulationTime = tDeltaSimulation;
        CostStats.TotalAnsysTime = tDeltaSimulation;
        
        fprintf("\tExecution Time: [Total = %6.2f s, Mean = %6.2f s]\n", tDeltaSimulation, tDeltaSimulation / QueueNumber);
            
    end
    
    %% Init Cost Function
    Fx    = zeros(N, Config.Objectives.Number);   
    ExtFx = zeros(N, Config.ExtObjectives.Number);
    
    %% Load results from Database    
    for k = 1:N
    
        Index = GetIndexNumber(X(k,:), Config);
        
        Results = Database.Data.([sprintf("D%d", Index)]);
        
        [Fx, ExtFx] = CostFunctionSelection(k, Fx, ExtFx, Results, Config);%Calcula a função custo
        
    end

end