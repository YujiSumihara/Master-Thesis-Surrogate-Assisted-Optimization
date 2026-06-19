%% MFEAPSO = MetaFEA + MOPSO + Surrogate

function Output = MFEAPSO_Return(Config)

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
    [MFEAPSO, Database, Config] = Setup(Config);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% MOPSO PARAMETERS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nPop = Config.Metaheuristic.Size;
    nVar = Config.Dimension.Number;

    % Defaults caso ainda não existam no Config
    if ~isfield(Config.Metaheuristic,'Inertia');        Config.Metaheuristic.Inertia = 0.6; end %0.6
    if ~isfield(Config.Metaheuristic,'InertiaDamp');    Config.Metaheuristic.InertiaDamp = 0.98; end %0.98
    if ~isfield(Config.Metaheuristic,'Cognitive');      Config.Metaheuristic.Cognitive = 1.8; end %1.8 Melhor
    if ~isfield(Config.Metaheuristic,'Social');         Config.Metaheuristic.Social = 2.0; end %2 Melhor
    if ~isfield(Config.Metaheuristic,'VelocityFactor'); Config.Metaheuristic.VelocityFactor = 0.20; end %0.2
    if ~isfield(Config.Metaheuristic,'ArchiveSize');    Config.Metaheuristic.ArchiveSize = Config.Metaheuristic.Size; end

    w  = Config.Metaheuristic.Inertia;
    wd = Config.Metaheuristic.InertiaDamp;
    c1 = Config.Metaheuristic.Cognitive;
    c2 = Config.Metaheuristic.Social;

    VarMin = Config.Domain.Initial;
    VarMax = Config.Domain.Final;
    VelMax = Config.Metaheuristic.VelocityFactor .* (VarMax - VarMin);
    VelMin = -VelMax;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% MEMORY ALLOCATION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Position = zeros(nPop, nVar);
    Velocity = zeros(nPop, nVar);

    JxPosition = zeros(nPop, Config.Objectives.Number);
    ExtJxPosition = zeros(nPop, 1);
    DxPosition = zeros(nPop, 1);

    % Personal best
    PBest.Position = [];
    PBest.Jx = [];
    PBest.ExtJx = [];
    PBest.Dx = [];

    % External archive / repository
    Archive.Position = [];
    Archive.Jx = [];
    Archive.ExtJx = [];
    Archive.Dx = [];
    Archive.Rank = [];

    % Recovery Pareto Candidates from previous iterations
    Chosen = struct();
    Chosen.Pop   = [];
    Chosen.Jx    = [];
    Chosen.ExtJx = [];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% INITIALIZATION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PopDist = createDist(nPop, nVar, ...
                         Config.Metaheuristic.Method, Config.Metaheuristic.Mode);

    if Config.Metaheuristic.Seed.Flag
        if isfile(Config.Metaheuristic.Seed.File)
            load(Config.Metaheuristic.Seed.File);           
        else       
            save(Config.Metaheuristic.Seed.File, 'PopDist');            
        end
    end

    Position = VarMin + (VarMax - VarMin) .* PopDist;
    Velocity = zeros(nPop, nVar);

    [JxPosition, ExtJxPosition] = CostFunctionRBF(Position, MFEAPSO, Config);
    [JxPosition, ExtJxPosition] = PenalizeInvalid(JxPosition, ExtJxPosition, Config);

    DxPosition = NeighborsProximity(Position, MFEAPSO.Xs, MFEAPSO.Ns, Config.Domain.Precision);

    PBest.Position = Position;
    PBest.Jx = JxPosition;
    PBest.ExtJx = ExtJxPosition;
    PBest.Dx = DxPosition;

    Archive = UpdateArchive(Archive, Position, JxPosition, ExtJxPosition, DxPosition, Config);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% ITERATIVE PROCESS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for Iter = 1:Config.Iter.Max

        fprintf("==> Iter MOPSO-Surrogate %d\n", Iter);

        %% Choose leaders and move particles
        for i = 1:nPop

            Leader = SelectLeaderFromArchive(Archive, Config);

            r1 = rand(1,nVar);
            r2 = rand(1,nVar);

            Velocity(i,:) = w .* Velocity(i,:) ...
                          + c1 .* r1 .* (PBest.Position(i,:) - Position(i,:)) ...
                          + c2 .* r2 .* (Leader.Position - Position(i,:));

            Velocity(i,:) = max(Velocity(i,:), VelMin);
            Velocity(i,:) = min(Velocity(i,:), VelMax);

            Position(i,:) = Position(i,:) + Velocity(i,:);

            % Boundary handling with velocity reflection
            over = Position(i,:) > VarMax;
            under = Position(i,:) < VarMin;

            Position(i,over) = VarMax(over);
            Position(i,under) = VarMin(under);

            Velocity(i,over | under) = -0.2 .* Velocity(i,over | under); %0.5
        end

        %% Evaluate particles through surrogate
        [JxPosition, ExtJxPosition] = CostFunctionRBF(Position, MFEAPSO, Config);
        [JxPosition, ExtJxPosition] = PenalizeInvalid(JxPosition, ExtJxPosition, Config);

        %% Restriction and surrogate distance objective
        JxRank = JxPosition;

        if Config.Restriction.Flag
            [JxRank, ~] = Restriction(JxRank, Config);
        end

        DxPosition = NeighborsProximity(Position, MFEAPSO.Xs, MFEAPSO.Ns, Config.Domain.Precision);

        switch Config.Operation.SurrogateCostFunction
            case {1}
                JxRank = [JxRank, DxPosition];
        end

        %% Update personal bests
        for i = 1:nPop

            currentCost = JxRank(i,:);
            pbestCost = PBest.Jx(i,:);

            if Config.Operation.SurrogateCostFunction == 1
                pbestCost = [pbestCost, PBest.Dx(i,:)];
            end

            if Dominates(currentCost, pbestCost)
                PBest.Position(i,:) = Position(i,:);
                PBest.Jx(i,:) = JxPosition(i,:);
                PBest.ExtJx(i,:) = ExtJxPosition(i,:);
                PBest.Dx(i,:) = DxPosition(i,:);

            elseif ~Dominates(pbestCost, currentCost)
                % Empate por não dominância: favorece região menos próxima dos pontos de treino
                if rand < 0.5 %DxPosition(i) > PBest.Dx(i) || rand < 0.5
                    PBest.Position(i,:) = Position(i,:);
                    PBest.Jx(i,:) = JxPosition(i,:);
                    PBest.ExtJx(i,:) = ExtJxPosition(i,:);
                    PBest.Dx(i,:) = DxPosition(i,:);
                end
            end
        end

        %% Update external archive
        Archive = UpdateArchive(Archive, Position, JxPosition, ExtJxPosition, DxPosition, Config);

        %% Include recovered candidates after surrogate update
        if ~isempty(Chosen.Pop)
            ChosenDx = NeighborsProximity(Chosen.Pop, MFEAPSO.Xs, MFEAPSO.Ns, Config.Domain.Precision);
            Archive = UpdateArchive(Archive, Chosen.Pop, Chosen.Jx, Chosen.ExtJx, ChosenDx, Config);

            % Também permite que o enxame seja reorientado por boas soluções recuperadas
            MixPop = [Position; Chosen.Pop];
            MixJx  = [JxPosition; Chosen.Jx];
            MixExt = [ExtJxPosition; Chosen.ExtJx];
            MixDx  = [DxPosition; ChosenDx];

            [~,~,idx] = TruncateIndex(MixJx, nPop);
            Position = MixPop(idx,:);
            JxPosition = MixJx(idx,:);
            ExtJxPosition = MixExt(idx,:);
            DxPosition = MixDx(idx,:);
            Velocity = zeros(nPop,nVar);

            PBest.Position = Position;
            PBest.Jx = JxPosition;
            PBest.ExtJx = ExtJxPosition;
            PBest.Dx = DxPosition;

            Chosen.Pop   = [];
            Chosen.Jx    = [];
            Chosen.ExtJx = [];
        end

        %% Use archive as current selected population for validation/sanitization
        if size(Archive.Position,1) >= nPop
            PositionSel = Archive.Position(1:nPop,:);
            JxSel       = Archive.Jx(1:nPop,:);
            ExtJxSel    = Archive.ExtJx(1:nPop,:);
            DxSel       = Archive.Dx(1:nPop,:);
        else
            PositionSel = Position;
            JxSel       = JxPosition;
            ExtJxSel    = ExtJxPosition;
            DxSel       = DxPosition;
        end

        MFEAPSO.Population.([sprintf('Iter%d', Iter)]) = PositionSel;

        %% Cost Function Validation
        [Violations, MFEAPSO] = Validation(Iter, JxSel, ExtJxSel, MFEAPSO, Config);

        %% Pareto Front Sanitization
        rank = ones(size(PositionSel,1),1);

        Pareto = Sanitization(PositionSel, ...
                              JxSel, ...
                              ExtJxSel, ...
                              DxSel, ...
                              rank, ...
                              Violations, ...
                              Config.Domain.Precision, ...
                              Config.Normalization.Minimum, ...
                              Config.Normalization.Maximum, ...
                              Config.ExtNormalization.Minimum, ...
                              Config.ExtNormalization.Maximum);

        %% Metaheuristic Metrics
        Metric = CalculateMetrics(Pareto, MFEAPSO.Metrics.Nadir, ...
                                  Config.Domain.Initial, ...
                                  Config.Domain.Final, ...
                                  Config.Domain.Precision, ...
                                  1, Config);

        MFEAPSO.Metrics.Metaheuristic.OTF = [MFEAPSO.Metrics.Metaheuristic.OTF; Metric];

        plotFlag = false;

        %% Proof of Concept
        if (Config.PoC.Flag && (Iter == 1 || rem(Iter, Config.PoC.Frequency) == 0))
            %disp('Estou no POC 1')
            [Pareto, MFEAPSO, Database] = PoC(Iter, Pareto, MFEAPSO, Database, Config);
            plotFlag = true;
        end

        %% Surrogate Update
        if (MFEAPSO.Ns < Config.Surrogates.Limit)

            if (ismember(Iter, MFEAPSO.Updates.Schedule) || ...
                mov_mean(MFEAPSO.Validation.Iteration, 3) > nPop * 0.20 || ...
                MFEAPSO.Validation.Accumulative(end)      > nPop * 0.75)

                %disp('Estou no Surrogate')

                MFEAPSO.Validation.Accumulative(end) = 0;

                % Atualiza pontos de treino usando a população selecionada/archive
                MFEAPSO = UpdatePopulation(Iter, PositionSel, MFEAPSO, Config);

                [MFEAPSO, Database] = UpdateModels(Iter, MFEAPSO, Database, Config);

                % Reavalia enxame, pbest e archive após reconstrução do surrogate
                [JxPosition, ExtJxPosition] = CostFunctionRBF(Position, MFEAPSO, Config);
                [JxPosition, ExtJxPosition] = PenalizeInvalid(JxPosition, ExtJxPosition, Config);
                DxPosition = NeighborsProximity(Position, MFEAPSO.Xs, MFEAPSO.Ns, Config.Domain.Precision);

                % Reset PBest after surrogate update
                PBest.Position = Position;
                PBest.Jx       = JxPosition;
                PBest.ExtJx    = ExtJxPosition;
                PBest.Dx       = DxPosition;

                [Archive.Jx, Archive.ExtJx] = CostFunctionRBF(Archive.Position, MFEAPSO, Config);
                [Archive.Jx, Archive.ExtJx] = PenalizeInvalid(Archive.Jx, Archive.ExtJx, Config);
                Archive.Dx = NeighborsProximity(Archive.Position, MFEAPSO.Xs, MFEAPSO.Ns, Config.Domain.Precision);
                Archive = UpdateArchive(EmptyArchive(), Archive.Position, Archive.Jx, Archive.ExtJx, Archive.Dx, Config);

                % (Teste) Reinitialize swarm from archive after surrogate update
                if size(Archive.Position,1) >= nPop
                
                    Position = Archive.Position(1:nPop,:);
                    JxPosition = Archive.Jx(1:nPop,:);
                    ExtJxPosition = Archive.ExtJx(1:nPop,:);
                    DxPosition = Archive.Dx(1:nPop,:);
                
                    Velocity = zeros(nPop,nVar);
                
                    PBest.Position = Position;
                    PBest.Jx       = JxPosition;
                    PBest.ExtJx    = ExtJxPosition;
                    PBest.Dx       = DxPosition;
                
                end

                %%
                [Chosen, MFEAPSO] = UpdateMetrics(Iter, MFEAPSO, Config);

                Pareto.Updated.Flag = true;
                [Pareto.Updated.Front, Pareto.Updated.ExtFront] = CostFunctionRBF(Pareto.Set, MFEAPSO, Config);
                Pareto.Updated.Distance = NeighborsProximity(Pareto.Set, MFEAPSO.Xs, MFEAPSO.Ns, Config.Domain.Precision);

                Pareto.Updated.FrontN = NormalizeColumn(Pareto.Updated.Front, ...
                                                       Config.Normalization.Minimum, ...
                                                       Config.Normalization.Maximum);
                Pareto.Updated.ExtFrontN = NormalizeColumn(Pareto.Updated.ExtFront, ...
                                                          Config.ExtNormalization.Minimum, ...
                                                          Config.ExtNormalization.Maximum);

                [RMS, DataNORM] = ComparePareto(Pareto, 2);

                MFEAPSO.Metrics.Surrogate.RMS  = [MFEAPSO.Metrics.Surrogate.RMS; RMS];
                MFEAPSO.Metrics.Surrogate.NORM = [MFEAPSO.Metrics.Surrogate.NORM; DataNORM];

                % PoC #2
                %disp('Estou no POC 2')

                [MFEAPSO.PoC2.Jx, MFEAPSO.PoC2.ExtJx] = CostFunctionRBF(MFEAPSO.PoC2.X, MFEAPSO, Config);

                MFEAPSO.PoC2.JxN    = NormalizeColumn(MFEAPSO.PoC2.Jx, ...
                                                   Config.Normalization.Minimum, ...
                                                   Config.Normalization.Maximum);
                MFEAPSO.PoC2.ExtJxN = NormalizeColumn(MFEAPSO.PoC2.ExtJx, ...
                                                   Config.ExtNormalization.Minimum, ...
                                                   Config.ExtNormalization.Maximum);

                A = [MFEAPSO.PoC2.FxN, MFEAPSO.PoC2.ExtFxN];
                B = [MFEAPSO.PoC2.JxN, MFEAPSO.PoC2.ExtJxN];

                RMS  = sqrt(mean((A - B).^2));
                NORM = zeros(MFEAPSO.PoC2.N, 1);

                for k = 1:MFEAPSO.PoC2.N
                    NORM(k) = norm(A(k,:) - B(k,:));
                end

                DataNORM = [min(NORM), median(NORM), mean(NORM), max(NORM)];

                MFEAPSO.PoC2.RMS  = [MFEAPSO.PoC2.RMS; RMS];
                MFEAPSO.PoC2.NORM = [MFEAPSO.PoC2.NORM; DataNORM];

                plotFlag = true;

            else
                MFEAPSO.Evaluations = [MFEAPSO.Evaluations; [Iter, MFEAPSO.Evaluations(end,2:3)]];
            end
        end

        %% Plot Progress
        if (plotFlag || Iter == 1 || Iter == Config.Iter.Max || ismember(Iter + 1, MFEAPSO.Updates.Schedule))
            if (Config.Graphic.Flag)
                PlotProgress(Iter, Pareto, MFEAPSO, Config);
            end
        end

        w = w * wd;
    end

    %% Return Results
    %disp('Avaliacao final')
    Final = EvaluateFinalPareto(PositionSel, JxSel, ExtJxSel, MFEAPSO, Database, Config);

    Output.Final = Final;
    Output.Pareto.Model = Final.Model;
    Output.Pareto.Real  = Final.Real;
    Output.Database = Final.Database;
    Output.MFEA = MFEAPSO;
    Output.Config = Config;

    MFEAPSO.Statistics.TrainingPointsFinal = MFEAPSO.Ns;

    Output.Statistics = MFEAPSO.Statistics;
    Output.Statistics.FinalEvaluations = MFEAPSO.Evaluations(end,:);

    expname = sprintf("MFEAPSO_%d_%s.mat", Config.runid, Config.Hash);
    savePath = fullfile(Config.runsFolder, expname);
    save(savePath);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL HELPERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Archive = EmptyArchive()
    Archive.Position = [];
    Archive.Jx = [];
    Archive.ExtJx = [];
    Archive.Dx = [];
    Archive.Rank = [];
end

function [Jx, ExtJx] = PenalizeInvalid(Jx, ExtJx, Config)
    invalid = any(~isfinite(Jx),2);

    if any(invalid)
        warning('%d pontos com NaN/Inf no surrogate foram penalizados.', sum(invalid));
        Jx(invalid,:) = repmat(Config.Normalization.Maximum, sum(invalid), 1) * 10;

        if ~isempty(ExtJx)
            ExtJx(invalid,:) = repmat(Config.ExtNormalization.Maximum, sum(invalid), 1) * 10;
        end
    end
end

