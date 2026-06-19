%% MFEAMOEAD_PURE = MetaFEA + pure MOEA/D + Surrogate
% Based on MFEA_Return.m, replacing MODE global Pareto selection by
% MOEA/D decomposition, neighborhood update and PBI/Tchebycheff scalarization.
% one-to-one association Parent(i,:) <-> Lambda(i,:) throughout the run.
function Output = MFEAMOEAD_Return(Config)

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
    [MFEAMOEAD, Database, Config] = Setup(Config);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %% MOEA/D PARAMETERS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nPop = Config.Metaheuristic.Size;
    nVar = Config.Dimension.Number;
    nObj = Config.Objectives.Number;

    % Defaults caso ainda não existam no Config
    if ~isfield(Config.Metaheuristic,'ScalingFactor'); Config.Metaheuristic.ScalingFactor = 0.5; end
    if ~isfield(Config.Metaheuristic,'CrossOver');     Config.Metaheuristic.CrossOver     = 0.2; end
    if ~isfield(Config.Metaheuristic,'NeighborSize');  Config.Metaheuristic.NeighborSize  = max(3, ceil(0.20*nPop)); end
    if ~isfield(Config.Metaheuristic,'Delta');         Config.Metaheuristic.Delta         = 0.90; end
    if ~isfield(Config.Metaheuristic,'Nr');            Config.Metaheuristic.Nr            = 2; end

    % Decomposition settings
    % Options: 'PBI' or 'TCHEBYCHEFF'
    if ~isfield(Config.Metaheuristic,'Decomposition'); Config.Metaheuristic.Decomposition = 'PBI'; end
    if ~isfield(Config.Metaheuristic,'PBITheta');      Config.Metaheuristic.PBITheta      = 3.0; end %5

    F     = Config.Metaheuristic.ScalingFactor;
    CR    = Config.Metaheuristic.CrossOver;
    T     = min(Config.Metaheuristic.NeighborSize, nPop);
    delta = Config.Metaheuristic.Delta;       % probabilidade de escolher pais na vizinhança
    nr    = Config.Metaheuristic.Nr;          % número máximo de vizinhos substituídos por filho

    VarMin = Config.Domain.Initial;
    VarMax = Config.Domain.Final;

    %% MOEA/D weight vectors and neighborhoods
    Lambda = GenerateWeightVectors(nPop, nObj);
    B = GenerateNeighborhood(Lambda, T);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% MEMORY ALLOCATION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Parent = zeros(nPop, nVar);
    JxParent = zeros(nPop, nObj);
    ExtJxParent = zeros(nPop, Config.ExtObjectives.Number);
    DxParent = zeros(nPop, 1);

    % Pure MOEA/D: no external archive and no Chosen reinsertion.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% INITIALIZATION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PopDist = createDist(nPop, nVar, ...
                         Config.Metaheuristic.Method, Config.Metaheuristic.Mode);
    
    % Seed Training Points
    if Config.Metaheuristic.Seed.Flag
        if isfile(Config.Metaheuristic.Seed.File)
            load(Config.Metaheuristic.Seed.File);           
        else       
            save(Config.Metaheuristic.Seed.File, 'PopDist');            
        end
    end
    
    % Re-Scale Distribution
    Parent = VarMin + (VarMax - VarMin) .* PopDist;

    % Evaluate Cost Function through Models
    [JxParent, ExtJxParent] = CostFunctionRBF(Parent, MFEAMOEAD, Config);
    [JxParent, ExtJxParent] = PenalizeInvalid(JxParent, ExtJxParent, Config);

    DxParent = NeighborsProximity(Parent, MFEAMOEAD.Xs, MFEAMOEAD.Ns, Config.Domain.Precision);

    % Ideal and nadir points for normalized scalarization
    z = min(JxParent, [], 1);
    nadir = max(JxParent, [], 1);

    %% Iterative Process
    for Iter = 1:Config.Iter.Max
        
        fprintf("==> Iter MOEA/D-Surrogate %d\n", Iter);
        
        %% MOEA/D evolutionary step
        for i = 1:nPop

            % Select mating pool: neighborhood or entire population
            if rand < delta
                P = B(i,:);
            else
                P = 1:nPop;
            end

            % Need three parents for DE/rand/1. Fallback to full population if needed.
            if numel(P) < 3
                P = 1:nPop;
            end

            rp = P(randperm(numel(P), min(3,numel(P))));
            while numel(unique(rp)) < 3
                rp = P(randperm(numel(P), min(3,numel(P))));
            end

            r1 = rp(1); r2 = rp(2); r3 = rp(3);

            % DE/rand/1 mutation
            Mutant = Parent(r1,:) + F .* (Parent(r2,:) - Parent(r3,:));
            Mutant = RepairBounds(Mutant, VarMin, VarMax);

            % Binomial crossover using current subproblem solution as target
            Child = Parent(i,:);
            jrand = randi(nVar);
            for j = 1:nVar
                if rand <= CR || j == jrand
                    Child(j) = Mutant(j);
                end
            end
            Child = RepairBounds(Child, VarMin, VarMax);

            % Evaluate child through surrogate
            [JxChild, ExtJxChild] = CostFunctionRBF(Child, MFEAMOEAD, Config);
            [JxChild, ExtJxChild] = PenalizeInvalid(JxChild, ExtJxChild, Config);
            DxChild = NeighborsProximity(Child, MFEAMOEAD.Xs, MFEAMOEAD.Ns, Config.Domain.Precision);

            % Restriction handling for comparison only
            JxChildRank = JxChild;
            JxParentRank = JxParent;

            if Config.Restriction.Flag
                [JxChildRank, ~] = Restriction(JxChildRank, Config);
                [JxParentRank, ~] = Restriction(JxParentRank, Config);
            end

            % Update ideal/nadir points using objective values
            z = min(z, JxChildRank(:,1:nObj));
            nadir = max(nadir, JxChildRank(:,1:nObj));

            % Update neighboring subproblems by scalar decomposition
            replaceCount = 0;
            UpdateSet = B(i,:);
            UpdateSet = UpdateSet(randperm(numel(UpdateSet)));

            for kk = 1:numel(UpdateSet)
                j = UpdateSet(kk);

                g_old = ScalarDecomposition(JxParentRank(j,1:nObj), Lambda(j,:), z, nadir, Config);
                g_new = ScalarDecomposition(JxChildRank(1,1:nObj),  Lambda(j,:), z, nadir, Config);

                if g_new <= g_old
                    Parent(j,:) = Child;
                    JxParent(j,:) = JxChild;
                    ExtJxParent(j,:) = ExtJxChild;
                    DxParent(j,:) = DxChild;

                    replaceCount = replaceCount + 1;
                    if replaceCount >= nr
                        break;
                    end
                end
            end
        end

        %% Pure MOEA/D

        % Prepare ranking data for validation/sanitization/metrics
        JxRank = JxParent;
        if Config.Restriction.Flag
            [JxRank, ~] = Restriction(JxRank, Config);
        end

        switch Config.Operation.SurrogateCostFunction
            case {1}
                JxRank = [JxRank, DxParent];
        end

        rank = nonDominatedRank(JxRank);

        % Store Iteration Population
        MFEAMOEAD.Population.([sprintf('Iter%d', Iter)]) = Parent;

        %% Cost Function Validation
        [Violations, MFEAMOEAD] = Validation(Iter, JxParent, ExtJxParent, MFEAMOEAD, Config);

        %% Pareto Front Sanitization
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
    
        %% Metaheuristic Metrics
        Metric = CalculateMetrics(Pareto, MFEAMOEAD.Metrics.Nadir, ...
                                  Config.Domain.Initial, ...
                                  Config.Domain.Final, ...
                                  Config.Domain.Precision, ...
                                  1, Config);

        MFEAMOEAD.Metrics.Metaheuristic.OTF = [MFEAMOEAD.Metrics.Metaheuristic.OTF; Metric];
                
        plotFlag = false;
        
        %% Proof of Concept (ANSYS)
        if (Config.PoC.Flag && (Iter == 1 || rem(Iter, Config.PoC.Frequency) == 0))
            disp('Estou no POC 1')
            [Pareto, MFEAMOEAD, Database] = PoC(Iter, Pareto, MFEAMOEAD, Database, Config);
            plotFlag = true;
        end

        %% Surrogate Update
        if (MFEAMOEAD.Ns < Config.Surrogates.Limit)
            
            if (ismember(Iter, MFEAMOEAD.Updates.Schedule) || ...
                mov_mean(MFEAMOEAD.Validation.Iteration, 3) > nPop * 0.20 || ...
                MFEAMOEAD.Validation.Accumulative(end)      > nPop * 0.75)

                disp('Estou no Surrogate')
                MFEAMOEAD.Validation.Accumulative(end) = 0;

                % Update Training Points using current MOEA/D population
                MFEAMOEAD = UpdatePopulation(Iter, Parent, MFEAMOEAD, Config);

                % Update Models
                disp('Ajusta modelo')
                [MFEAMOEAD, Database] = UpdateModels(Iter, MFEAMOEAD, Database, Config);

                % Reevaluate Parent Population through updated surrogate
                [JxParent, ExtJxParent] = CostFunctionRBF(Parent, MFEAMOEAD, Config);
                [JxParent, ExtJxParent] = PenalizeInvalid(JxParent, ExtJxParent, Config);
                DxParent = NeighborsProximity(Parent, MFEAMOEAD.Xs, MFEAMOEAD.Ns, Config.Domain.Precision);
                z = min(JxParent, [], 1);
                nadir = max(JxParent, [], 1);

                % Update previous-iteration metrics only. The Chosen population is discarded
                % to keep the algorithm as pure MOEA/D.
                disp('Atualiza metrica')
                [~, MFEAMOEAD] = UpdateMetrics(Iter, MFEAMOEAD, Config);
                
                % Pareto update comparison
                Pareto.Updated.Flag = true;
                [Pareto.Updated.Front, Pareto.Updated.ExtFront] = CostFunctionRBF(Pareto.Set, MFEAMOEAD, Config);
                Pareto.Updated.Distance = NeighborsProximity(Pareto.Set, MFEAMOEAD.Xs, MFEAMOEAD.Ns, Config.Domain.Precision);
                
                Pareto.Updated.FrontN = NormalizeColumn(Pareto.Updated.Front, ...
                                                       Config.Normalization.Minimum, ...
                                                       Config.Normalization.Maximum);
                Pareto.Updated.ExtFrontN = NormalizeColumn(Pareto.Updated.ExtFront, ...
                                                          Config.ExtNormalization.Minimum, ...
                                                          Config.ExtNormalization.Maximum);
    
                [RMS, DataNORM] = ComparePareto(Pareto, 2);
                MFEAMOEAD.Metrics.Surrogate.RMS  = [MFEAMOEAD.Metrics.Surrogate.RMS; RMS];
                MFEAMOEAD.Metrics.Surrogate.NORM = [MFEAMOEAD.Metrics.Surrogate.NORM; DataNORM];

                % PoC #2
                disp('Estou no POC 2')
                [MFEAMOEAD.PoC2.Jx, MFEAMOEAD.PoC2.ExtJx] = CostFunctionRBF(MFEAMOEAD.PoC2.X, MFEAMOEAD, Config);

                MFEAMOEAD.PoC2.JxN = NormalizeColumn(MFEAMOEAD.PoC2.Jx, ...
                                                Config.Normalization.Minimum, ...
                                                Config.Normalization.Maximum);       
                MFEAMOEAD.PoC2.ExtJxN = NormalizeColumn(MFEAMOEAD.PoC2.ExtJx, ...
                                                   Config.ExtNormalization.Minimum, ...
                                                   Config.ExtNormalization.Maximum);

                A = [MFEAMOEAD.PoC2.FxN, MFEAMOEAD.PoC2.ExtFxN];
                Bp = [MFEAMOEAD.PoC2.JxN, MFEAMOEAD.PoC2.ExtJxN];

                RMS  = sqrt(mean((A - Bp).^2));
                NORM = zeros(MFEAMOEAD.PoC2.N, 1);

                for k=1:MFEAMOEAD.PoC2.N
                    NORM(k) = norm(A(k,:) - Bp(k,:));
                end

                DataNORM = [min(NORM), median(NORM), mean(NORM), max(NORM)];

                MFEAMOEAD.PoC2.RMS  = [MFEAMOEAD.PoC2.RMS; RMS];
                MFEAMOEAD.PoC2.NORM = [MFEAMOEAD.PoC2.NORM; DataNORM];
                plotFlag = true;
                
            else
                MFEAMOEAD.Evaluations = [MFEAMOEAD.Evaluations; [Iter, MFEAMOEAD.Evaluations(end,2:3)]];   
            end
        end
        
        %% Plot Progress
        if (plotFlag || Iter == 1 || Iter == Config.Iter.Max || ismember(Iter + 1, MFEAMOEAD.Updates.Schedule)) 
            if (Config.Graphic.Flag)
                PlotProgress(Iter, Pareto, MFEAMOEAD, Config);
            end
        end
    end
    
    %% Return Results
    disp('Avaliacao final')
    Final = EvaluateFinalPareto(Parent, JxParent, ExtJxParent, MFEAMOEAD, Database, Config);

    Output.Final = Final;
    Output.Pareto.Model = Final.Model;
    Output.Pareto.Real  = Final.Real;
    Output.Database = Final.Database;
    Output.MFEA = MFEAMOEAD;
    Output.Config = Config;

    MFEAMOEAD.Statistics.TrainingPointsFinal = MFEAMOEAD.Ns;

    Output.Statistics = MFEAMOEAD.Statistics;
    Output.Statistics.FinalEvaluations = MFEAMOEAD.Evaluations(end,:);

    %% salva workspace
    expname = sprintf("MFEAMOEAD_PURE_%d_%s.mat", Config.runid, Config.Hash);
    savePath = fullfile(Config.runsFolder, expname);
    save(savePath);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL HELPERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

function X = RepairBounds(X, VarMin, VarMax)
    over = X > VarMax;
    under = X < VarMin;

    % Similar to MFEA_Return: if outside, returns near the violated bound.
    X(over) = VarMax(over) - rand(1,sum(over)) .* (VarMax(over) - VarMin(over)) * 0.1;
    X(under) = VarMin(under) + rand(1,sum(under)) .* (VarMax(under) - VarMin(under)) * 0.1;
end

function Lambda = GenerateWeightVectors(nPop, nObj)
    if nObj == 2
        w1 = linspace(0, 1, nPop)';
        Lambda = [w1, 1-w1];
    else
        % Generic fallback: random normalized weights plus canonical directions.
        Lambda = rand(nPop, nObj);
        Lambda = Lambda ./ sum(Lambda, 2);
        for j = 1:min(nObj,nPop)
            Lambda(j,:) = 0;
            Lambda(j,j) = 1;
        end
    end

    Lambda(Lambda == 0) = 1e-6;
end

function B = GenerateNeighborhood(Lambda, T)
    nPop = size(Lambda,1);
    D = zeros(nPop,nPop);

    for i = 1:nPop
        for j = 1:nPop
            D(i,j) = norm(Lambda(i,:) - Lambda(j,:));
        end
    end

    [~, idx] = sort(D, 2, 'ascend');
    B = idx(:,1:T);
end

function g = ScalarDecomposition(F, lambda, z, nadir, Config)
    % Normalized decomposition function for MOEA/D.
    % Supports:
    %   - PBI: penalty-based boundary intersection
    %   - TCHEBYCHEFF: normalized Tchebycheff
    %
    % All objectives are treated as minimization.

    method = upper(Config.Metaheuristic.Decomposition);

    Fn = NormalizeObjectivesLocal(F, Config.Normalization.Minimum, Config.Normalization.Maximum);
    zn = NormalizeObjectivesLocal(z, Config.Normalization.Minimum, Config.Normalization.Maximum);

    % Dynamic normalization fallback. This avoids near-zero ranges if the
    % configured normalization is not compatible with the current surrogate
    % image. It only acts when needed.
    if any(~isfinite(Fn)) || any(~isfinite(zn))
        Fn = NormalizeObjectivesDynamic(F, z, nadir);
        zn = NormalizeObjectivesDynamic(z, z, nadir);
    end

    lambda(lambda == 0) = 1e-6;

    switch method

        case 'PBI'
            theta = Config.Metaheuristic.PBITheta;

            w = lambda(:)' ./ norm(lambda);

            d = Fn - zn;

            d1 = abs(d * w');
            projection = zn + d1 .* w;
            d2 = norm(Fn - projection);

            g = d1 + theta * d2;

        otherwise
            % Normalized Tchebycheff
            g = max(lambda .* abs(Fn - zn));
    end
end

function Fn = NormalizeObjectivesLocal(F, NormMin, NormMax)
    den = NormMax - NormMin;
    den(abs(den) < eps) = eps;
    Fn = (F - NormMin) ./ den;
end

function Fn = NormalizeObjectivesDynamic(F, z, nadir)
    den = nadir - z;
    den(abs(den) < eps) = eps;
    Fn = (F - z) ./ den;
end
