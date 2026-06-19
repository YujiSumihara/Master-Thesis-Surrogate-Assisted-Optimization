function PlotComparisonBoxplots(Results, outputFolder)
%PLOTCOMPARISONBOXPLOTS Generates boxplots for MODE vs MOPSO metrics.
%
% Usage:
%   PlotComparisonBoxplots(Resultados, 'figures_boxplots')

    if nargin < 2 || isempty(outputFolder)
        outputFolder = 'figures_boxplots';
    end

    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end

    metricInfo = {
        'IGD',                  'IGD';
        'HV',                   'Hypervolume';
        'Spacing',              'Spacing';
        'TotalTime',            'Total time (min)';
        'AnsysTime',            'ANSYS time (min)';
        'NewAnsysCalls',        'New ANSYS calls';
        'TotalRequestedPoints', 'Requested points';
        'NewTrainingPoints',    'New training points';
        'TrainingPointsFinal',  'Final training points'
    };

    for m = 1:size(metricInfo,1)

        metric = metricInfo{m,1};
        yLabel = metricInfo{m,2};

        if ~isfield(Results.MODE, metric) || ~isfield(Results.MOPSO, metric)
            continue;
        end

        xMODE  = Results.MODE.(metric);
        xMOPSO = Results.MOPSO.(metric);

        xMODE  = xMODE(:);
        xMOPSO = xMOPSO(:);

        values = [xMODE; xMOPSO];
        groups = [repmat({'MODE'}, numel(xMODE), 1); ...
                  repmat({'MOPSO'}, numel(xMOPSO), 1)];

        valid = ~isnan(values);
        values = values(valid);
        groups = groups(valid);

        fig = figure('Name', ['Boxplot_' metric], 'Color', 'w');

        boxplot(values, groups);
        grid on;
        ylabel(yLabel, 'Interpreter', 'none');
        title(['MODE vs MOPSO - ' yLabel], 'Interpreter', 'none');

        exportgraphics(fig, fullfile(outputFolder, ['boxplot_' metric '.png']), 'Resolution', 600);
        exportgraphics(fig, fullfile(outputFolder, ['boxplot_' metric '.pdf']), 'ContentType', 'vector');
        savefig(fig, fullfile(outputFolder, ['boxplot_' metric '.fig']));

    end

end
