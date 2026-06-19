clear; clc; close all;

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

%% Create result folders
resultsFolder = 'Results_placa';

figuresFolder = fullfile(resultsFolder, 'Figures');
tablesFolder  = fullfile(resultsFolder, 'Tables');
matFolder     = fullfile(resultsFolder, 'MAT');
runsFolder    = fullfile(resultsFolder, 'Runs');

if ~exist(resultsFolder, 'dir'); mkdir(resultsFolder); end
if ~exist(figuresFolder, 'dir'); mkdir(figuresFolder); end
if ~exist(tablesFolder,  'dir'); mkdir(tablesFolder);  end
if ~exist(matFolder,     'dir'); mkdir(matFolder);     end
if ~exist(runsFolder,    'dir'); mkdir(runsFolder);    end

%% Experiment setup
nRuns = 30; % use 30 for final comparison

% Choose which front will be used for final IGD/HV/Spacing and plotting:
% 'Model' = surrogate-estimated final Pareto
% 'Real'  = final Pareto after real/ANSYS evaluation of selected points
metricFrontType = 'Model';

algorithms = {'MODE', 'MOPSO', 'MOEAD'};
Resultados = struct();
AllRealPF = [];

for a = 1:numel(algorithms)
    alg = algorithms{a};

    % Metrics
    Resultados.(alg).IGD     = zeros(nRuns,1);
    Resultados.(alg).HV      = zeros(nRuns,1);
    Resultados.(alg).Spacing = zeros(nRuns,1);
    Resultados.(alg).Time    = zeros(nRuns,1);

    % Pareto fronts
    Resultados.(alg).ParetoModel = cell(nRuns,1);
    Resultados.(alg).ParetoReal  = cell(nRuns,1);

    % Computational cost
    Resultados.(alg).TotalTime            = zeros(nRuns,1);
    Resultados.(alg).AnsysTime            = zeros(nRuns,1);
    Resultados.(alg).NewAnsysCalls        = zeros(nRuns,1);
    Resultados.(alg).ReusedDatabasePoints = zeros(nRuns,1);
    Resultados.(alg).TrainingPointsFinal  = zeros(nRuns,1);
    Resultados.(alg).TotalRequestedPoints = zeros(nRuns,1);
    Resultados.(alg).TrainingPointsInitial = zeros(nRuns,1);
    Resultados.(alg).NewTrainingPoints    = zeros(nRuns,1);
end

%% Runs
for runid = 1:nRuns

    fprintf('\n==============================\n');
    fprintf('RUN %d / %d\n', runid, nRuns);
    fprintf('==============================\n');

    for a = 1:numel(algorithms)
        alg = algorithms{a};

        Config = run_experiment_0_3_config_only();
        Config.Hash = sprintf('%s_0_run_%02d', alg, runid);
        Config.runid = runid;
        Config.runsFolder = runsFolder;

        % Same seed per run for all algorithms, as in the original script
        rng(runid);

        runMatFile = GetRunMatFile(runsFolder, alg, runid, Config.Hash);

        if isfile(runMatFile)
            fprintf('\n--- Loading existing %s run %d ---\n', alg, runid);
        
            S = load(runMatFile);
        
            if isfield(S, 'Output')
                Output = S.Output;
            else
                error('Arquivo encontrado, mas não contém a variável Output: %s', runMatFile);
            end
        
            Resultados.(alg).Time(runid) = NaN;
            Resultados.(alg).TotalTime(runid) = NaN;
        
        else
            fprintf('\n--- Running %s + Surrogate ---\n', alg);
            tAlg = tic;
        
            switch alg
                case 'MODE'
                    Output = MFEA_Return(Config);
        
                case 'MOPSO'
                    Output = MFEAPSO_Return(Config);
        
                case 'MOEAD'
                    Output = MFEAMOEAD_Return(Config);
        
                otherwise
                    error('Unknown algorithm: %s', alg);
            end
        
            Resultados.(alg).Time(runid) = toc(tAlg) / 60;
            Resultados.(alg).TotalTime(runid) = Resultados.(alg).Time(runid);
        end

        if isfield(Output, 'Statistics')
            Resultados.(alg).AnsysTime(runid) = Output.Statistics.TotalAnsysTime / 60;
            Resultados.(alg).NewAnsysCalls(runid) = Output.Statistics.NewAnsysCalls;
            Resultados.(alg).ReusedDatabasePoints(runid) = Output.Statistics.ReusedDatabasePoints;
            Resultados.(alg).TrainingPointsFinal(runid) = Output.Statistics.TrainingPointsFinal;
            Resultados.(alg).TotalRequestedPoints(runid) = Output.Statistics.TotalRequestedPoints;

            if isfield(Output.Statistics,'TrainingPointsInitial')
                Resultados.(alg).TrainingPointsInitial(runid) = Output.Statistics.TrainingPointsInitial;
            end
            if isfield(Output.Statistics,'NewTrainingPoints')
                Resultados.(alg).NewTrainingPoints(runid) = Output.Statistics.NewTrainingPoints;
            end
        end

        PF_model = Output.Pareto.Model.Front;
        PF_real  = Output.Pareto.Real.Front;

        Resultados.(alg).ParetoModel{runid} = PF_model;
        Resultados.(alg).ParetoReal{runid}  = PF_real;

        AllRealPF = [AllRealPF; PF_real]; %#ok<AGROW>

        fprintf('\n%s model PF size: ', alg);
        disp(size(PF_model));
        fprintf('%s real PF size: ', alg);
        disp(size(PF_real));

        save(fullfile(matFolder, 'results_Placa_compare_partial.mat'), ...
             'Resultados', 'AllRealPF', 'algorithms', 'metricFrontType');
    end
end

%% Global real Pareto reference
AllRealPF = unique(AllRealPF, 'rows');
rank = nonDominatedRank(AllRealPF);
PF_real_global = AllRealPF(rank == 1,:);

%% Final metrics using the same global reference
for runid = 1:nRuns
    for a = 1:numel(algorithms)
        alg = algorithms{a};

        switch metricFrontType
            case 'Model'
                PF_alg = Resultados.(alg).ParetoModel{runid};
            case 'Real'
                PF_alg = Resultados.(alg).ParetoReal{runid};
            otherwise
                error('metricFrontType must be ''Model'' or ''Real''.');
        end

        if isempty(PF_alg) || isempty(PF_real_global)
            Resultados.(alg).IGD(runid) = NaN;
            Resultados.(alg).HV(runid) = NaN;
            Resultados.(alg).Spacing(runid) = NaN;
        else
            Resultados.(alg).IGD(runid) = IGDResults(PF_real_global, PF_alg);

            PF_alg_n = NormalizeByReference(PF_alg, PF_real_global);
            PF_alg_n = min(max(PF_alg_n, 0), 1);

            Resultados.(alg).HV(runid) = Hypervolume_MEX(PF_alg_n, ones(1,2));
            Resultados.(alg).Spacing(runid) = spacing(PF_alg);
        end
    end
end

save(fullfile(matFolder, 'results_Placa_compare_final.mat'), ...
     'Resultados', 'PF_real_global', 'algorithms', 'metricFrontType');

Summary = BuildSummaryTableMulti(Resultados, algorithms);
disp(Summary);
writetable(Summary, fullfile(tablesFolder, 'summaryPlaca_MODE_MOPSO_MOEAD.csv'));

%% Summary of computational cost
CostSummary = BuildCostSummaryTable(Resultados, algorithms);
disp(CostSummary);
writetable(CostSummary, fullfile(tablesFolder, 'CostSummaryPlaca_MODE_MOPSO_MOEAD.csv'));

%% Statistical comparison: pairwise Wilcoxon signed-rank tests
if nRuns >= 2
    if nRuns < 30
        warning('Wilcoxon executado com nRuns < 30. Use como análise preliminar.');
    end

    Stats = PairwiseWilcoxonCompare(Resultados, algorithms);
    disp(Stats);
    writetable(Stats, fullfile(tablesFolder, 'WilcoxonPlaca_MODE_MOPSO_MOEAD.csv'));
else
    warning('Wilcoxon não executado: nRuns < 2.');
end

%% Boxplots
PlotComparisonBoxplotsMulti(Resultados, algorithms, figuresFolder);

%% Best Pareto plot
PlotBestParetoMulti(Resultados, PF_real_global, algorithms, metricFrontType);
exportgraphics(gcf, fullfile(figuresFolder, 'BestParetoComparison_MODE_MOPSO_MOEAD.png'), 'Resolution', 600);
exportgraphics(gcf, fullfile(figuresFolder, 'BestParetoComparison_MODE_MOPSO_MOEAD.pdf'), 'ContentType', 'vector');

save(fullfile(matFolder, 'ComparePlaca_full_MODE_MOPSO_MOEAD.mat'), ...
     'Resultados', 'PF_real_global', 'Summary', 'CostSummary', 'algorithms', 'metricFrontType');

%% Save all open figures
figs = findall(groot, 'Type', 'figure');
for i = 1:length(figs)
    fig = figs(i);
    exportgraphics(fig, fullfile(figuresFolder, sprintf('Figure_%02d.png', i)), 'Resolution', 600);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local helper functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Summary = BuildSummaryTableMulti(Resultados, algorithms)
    nAlg = numel(algorithms);
    Algorithm = strings(nAlg,1);
    MeanIGD = zeros(nAlg,1); StdIGD = zeros(nAlg,1);
    MeanHV = zeros(nAlg,1);  StdHV = zeros(nAlg,1);
    MeanSpacing = zeros(nAlg,1); StdSpacing = zeros(nAlg,1);

    for a = 1:nAlg
        alg = algorithms{a};
        Algorithm(a) = string(alg);
        MeanIGD(a) = mean(Resultados.(alg).IGD,'omitnan');
        StdIGD(a)  = std(Resultados.(alg).IGD,'omitnan');
        MeanHV(a)  = mean(Resultados.(alg).HV,'omitnan');
        StdHV(a)   = std(Resultados.(alg).HV,'omitnan');
        MeanSpacing(a) = mean(Resultados.(alg).Spacing,'omitnan');
        StdSpacing(a)  = std(Resultados.(alg).Spacing,'omitnan');
    end

    Summary = table(Algorithm, MeanIGD, StdIGD, MeanHV, StdHV, MeanSpacing, StdSpacing);
end

function CostSummary = BuildCostSummaryTable(Resultados, algorithms)
    nAlg = numel(algorithms);
    Algorithm = strings(nAlg,1);

    MeanTotalTime_min = zeros(nAlg,1); StdTotalTime_min = zeros(nAlg,1);
    MeanAnsysTime_min = zeros(nAlg,1); StdAnsysTime_min = zeros(nAlg,1);
    MeanNewAnsysCalls = zeros(nAlg,1); StdNewAnsysCalls = zeros(nAlg,1);
    MeanReusedDatabasePoints = zeros(nAlg,1);
    MeanTotalRequestedPoints = zeros(nAlg,1);
    MeanTrainingPointsInitial = zeros(nAlg,1);
    MeanNewTrainingPoints = zeros(nAlg,1); StdNewTrainingPoints = zeros(nAlg,1);
    MeanTrainingPointsFinal = zeros(nAlg,1); StdTrainingPointsFinal = zeros(nAlg,1);
    UpdateRate_percent = zeros(nAlg,1);
    ReuseRate_percent = zeros(nAlg,1);

    for a = 1:nAlg
        alg = algorithms{a};
        Algorithm(a) = string(alg);

        MeanTotalTime_min(a) = mean(Resultados.(alg).TotalTime,'omitnan');
        StdTotalTime_min(a)  = std(Resultados.(alg).TotalTime,'omitnan');
        MeanAnsysTime_min(a) = mean(Resultados.(alg).AnsysTime,'omitnan');
        StdAnsysTime_min(a)  = std(Resultados.(alg).AnsysTime,'omitnan');
        MeanNewAnsysCalls(a) = mean(Resultados.(alg).NewAnsysCalls,'omitnan');
        StdNewAnsysCalls(a)  = std(Resultados.(alg).NewAnsysCalls,'omitnan');
        MeanReusedDatabasePoints(a) = mean(Resultados.(alg).ReusedDatabasePoints,'omitnan');
        MeanTotalRequestedPoints(a) = mean(Resultados.(alg).TotalRequestedPoints,'omitnan');
        MeanTrainingPointsInitial(a) = mean(Resultados.(alg).TrainingPointsInitial,'omitnan');
        MeanNewTrainingPoints(a) = mean(Resultados.(alg).NewTrainingPoints,'omitnan');
        StdNewTrainingPoints(a)  = std(Resultados.(alg).NewTrainingPoints,'omitnan');
        MeanTrainingPointsFinal(a) = mean(Resultados.(alg).TrainingPointsFinal,'omitnan');
        StdTrainingPointsFinal(a)  = std(Resultados.(alg).TrainingPointsFinal,'omitnan');

        UpdateRate_percent(a) = 100 * MeanNewTrainingPoints(a) / max(MeanTotalRequestedPoints(a), eps);
        ReuseRate_percent(a)  = 100 * MeanReusedDatabasePoints(a) / max(MeanTotalRequestedPoints(a), eps);
    end

    CostSummary = table(Algorithm, MeanTotalTime_min, StdTotalTime_min, ...
        MeanAnsysTime_min, StdAnsysTime_min, MeanNewAnsysCalls, StdNewAnsysCalls, ...
        MeanReusedDatabasePoints, MeanTotalRequestedPoints, MeanTrainingPointsInitial, ...
        MeanNewTrainingPoints, StdNewTrainingPoints, MeanTrainingPointsFinal, ...
        StdTrainingPointsFinal, UpdateRate_percent, ReuseRate_percent);
end

function Stats = PairwiseWilcoxonCompare(Resultados, algorithms)
    pairs = nchoosek(1:numel(algorithms),2);
    Metric = strings(size(pairs,1)*3,1);
    AlgorithmA = strings(size(pairs,1)*3,1);
    AlgorithmB = strings(size(pairs,1)*3,1);
    PValue = NaN(size(pairs,1)*3,1);

    metrics = {'IGD','HV','Spacing'};
    row = 0;
    for p = 1:size(pairs,1)
        a = algorithms{pairs(p,1)};
        b = algorithms{pairs(p,2)};
        for m = 1:numel(metrics)
            row = row + 1;
            met = metrics{m};
            Metric(row) = string(met);
            AlgorithmA(row) = string(a);
            AlgorithmB(row) = string(b);
            try
                PValue(row) = signrank(Resultados.(a).(met), Resultados.(b).(met));
            catch
                PValue(row) = NaN;
            end
        end
    end

    Stats = table(Metric, AlgorithmA, AlgorithmB, PValue);
end

function PlotComparisonBoxplotsMulti(Resultados, algorithms, figuresFolder)
    metrics = {'IGD','HV','Spacing'};

    for m = 1:numel(metrics)
        metric = metrics{m};
        data = [];
        group = strings(0,1);

        for a = 1:numel(algorithms)
            alg = algorithms{a};
            values = Resultados.(alg).(metric)(:);
            data = [data; values]; %#ok<AGROW>
            group = [group; repmat(string(alg), numel(values), 1)]; %#ok<AGROW>
        end

        figure;
        boxplot(data, group);
        ylabel(metric);
        title(sprintf('%s comparison', metric));
        grid on;

        if nargin >= 3 && ~isempty(figuresFolder)
            exportgraphics(gcf, fullfile(figuresFolder, sprintf('Boxplot_%s_MODE_MOPSO_MOEAD.png', metric)), 'Resolution', 600);
        end
    end
end

function PlotBestParetoMulti(Results, PF_real_global, algorithms, metricFrontType)
    figure;
    plot(PF_real_global(:,1), PF_real_global(:,2), 'k-', 'LineWidth', 2);
    hold on;

    legendEntries = strings(1, numel(algorithms)+1);
    legendEntries(1) = 'Real Global Pareto';

    for a = 1:numel(algorithms)
        alg = algorithms{a};
        [~, bestRun] = min(Results.(alg).IGD);

        switch metricFrontType
            case 'Model'
                PF_alg = Results.(alg).ParetoModel{bestRun};
            case 'Real'
                PF_alg = Results.(alg).ParetoReal{bestRun};
        end

        scatter(PF_alg(:,1), PF_alg(:,2), 60, 'filled');
        legendEntries(a+1) = sprintf('%s - run %d', alg, bestRun);
    end

    xlabel('- Safety Factor');
    ylabel('Mass (g)');
    title(sprintf('Best Pareto Front with lower IGD (%s)', metricFrontType));
    legend(legendEntries, 'Location', 'best');
    grid on;
end

function runMatFile = GetRunMatFile(runsFolder, alg, runid, hash)

    switch alg
        case 'MODE'
            prefix = 'MFEA';

        case 'MOPSO'
            prefix = 'MFEAPSO';

        case 'MOEAD'
            prefix = 'MFEAMOEAD_PURE';

        otherwise
            error('Unknown algorithm: %s', alg);
    end

    filename = sprintf('%s_%d_%s.mat', prefix, runid, hash);
    runMatFile = fullfile(runsFolder, filename);
end


    % figure('Position',[100 100 1400 450]);
    % 
    % for a = 1:numel(algorithms)
    % 
    %     subplot(1,numel(algorithms),a)
    % 
    %     % Fronteira global de referência
    %     plot(PF_real_global(:,1), PF_real_global(:,2), ...
    %          'k--', 'LineWidth', 2);
    %     hold on;
    % 
    %     alg = algorithms{a};
    % 
    %     % Melhor execução (menor IGD)
    %     [~, bestRun] = min(Resultados.(alg).IGD);
    % 
    %     switch metricFrontType
    %         case 'Model'
    %             PF_alg = Resultados.(alg).ParetoModel{bestRun};
    % 
    %         case 'Real'
    %             PF_alg = Resultados.(alg).ParetoReal{bestRun};
    %     end
    % 
    %     % Cor de cada algoritmo
    %     switch alg
    % 
    %         case 'MODE'
    %             pointColor = [1 0 0];      % Vermelho
    % 
    %         case 'MOPSO'
    %             pointColor = [1 1 0];      % Amarelo
    % 
    %         case 'MOEAD'
    %             pointColor = [0.5 0 0.8];  % Roxo
    % 
    %         otherwise
    %             pointColor = [0 0 1];
    %     end
    % 
    %     % Pontos da fronteira
    %     scatter(PF_alg(:,1), PF_alg(:,2), ...
    %             60, pointColor, ...
    %             'filled', ...
    %             'MarkerEdgeColor','k', ...
    %             'LineWidth',1);
    % 
    %     xlabel('-Safety Factor');
    %     ylabel('Mass (g)');
    % 
    %     title(sprintf('%s (Run %d)', alg, bestRun));
    % 
    %     legend({'Pareto Global de Referência', alg}, ...
    %            'Location','best');
    % 
    %     grid on;
    %     box on;
    % 
    % end
    % 
    % sgtitle(sprintf('Melhores Fronteiras por Menor IGD (%s)', ...
    %                 metricFrontType));