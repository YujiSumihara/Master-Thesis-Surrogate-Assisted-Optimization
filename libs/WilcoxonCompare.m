function Stats = WilcoxonCompare(Results)
%WILCOXONCOMPARE Statistical comparison between MODE and MOPSO.
%
% This function compares quality and computational-cost metrics using
% paired Wilcoxon signed-rank tests (signrank), assuming that MODE and MOPSO
% were executed with the same run ids/seeds.
%
% Output:
%   Stats table with mean, std, median, min, max, p-value, significance,
%   winner by mean and relative difference.

    alpha = 0.05;

    % Metric name, optimization direction
    % direction = "min" means lower values are better
    % direction = "max" means higher values are better
    metricInfo = {
        'IGD',                  'min';
        'HV',                   'max';
        'Spacing',              'min';
        'TotalTime',            'min';
        'AnsysTime',            'min';
        'NewAnsysCalls',        'min';
        'ReusedDatabasePoints', 'min';
        'TotalRequestedPoints', 'min';
        'TrainingPointsInitial','none';
        'NewTrainingPoints',    'min';
        'TrainingPointsFinal',  'min'
    };

    rows = {};

    for m = 1:size(metricInfo,1)

        metric = metricInfo{m,1};
        direction = metricInfo{m,2};

        if ~isfield(Results.MODE, metric) || ~isfield(Results.MOPSO, metric)
            continue;
        end

        x = Results.MODE.(metric);
        y = Results.MOPSO.(metric);

        x = x(:);
        y = y(:);

        valid = ~isnan(x) & ~isnan(y);

        xv = x(valid);
        yv = y(valid);

        nValid = numel(xv);

        if nValid < 2
            p = NaN;
        else
            % Paired non-parametric test. Appropriate when run ids/seeds match.
            p = signrank(xv, yv);
        end

        meanMODE   = mean(xv, 'omitnan');
        meanMOPSO  = mean(yv, 'omitnan');
        stdMODE    = std(xv, 'omitnan');
        stdMOPSO   = std(yv, 'omitnan');
        medMODE    = median(xv, 'omitnan');
        medMOPSO   = median(yv, 'omitnan');
        minMODE    = min(xv);
        minMOPSO   = min(yv);
        maxMODE    = max(xv);
        maxMOPSO   = max(yv);

        if isnan(p)
            significant = "Insufficient data";
        elseif p < alpha
            significant = "Yes";
        else
            significant = "No";
        end

        switch direction
            case 'min'
                if meanMODE < meanMOPSO
                    bestMean = "MODE";
                elseif meanMOPSO < meanMODE
                    bestMean = "MOPSO";
                else
                    bestMean = "Tie";
                end

            case 'max'
                if meanMODE > meanMOPSO
                    bestMean = "MODE";
                elseif meanMOPSO > meanMODE
                    bestMean = "MOPSO";
                else
                    bestMean = "Tie";
                end

            otherwise
                bestMean = "Not applicable";
        end

        % Relative difference using MODE as reference.
        % Positive means MOPSO is larger than MODE.
        if abs(meanMODE) > eps
            relDiffPercent = 100 * (meanMOPSO - meanMODE) / abs(meanMODE);
        else
            relDiffPercent = NaN;
        end

        absMedianDiff = abs(medMODE - medMOPSO);

        rows(end+1,:) = { ...
            string(metric), string(direction), nValid, ...
            meanMODE, stdMODE, medMODE, minMODE, maxMODE, ...
            meanMOPSO, stdMOPSO, medMOPSO, minMOPSO, maxMOPSO, ...
            p, string(significant), string(bestMean), ...
            relDiffPercent, absMedianDiff ...
        };

    end

    Stats = cell2table(rows, ...
        'VariableNames', { ...
            'Metric','Direction','N', ...
            'Mean_MODE','Std_MODE','Median_MODE','Min_MODE','Max_MODE', ...
            'Mean_MOPSO','Std_MOPSO','Median_MOPSO','Min_MOPSO','Max_MOPSO', ...
            'p_value','Significant_005','BestByMean', ...
            'RelativeDiff_MOPSO_vs_MODE_percent','AbsMedianDifference' ...
        });

    writetable(Stats, fullfile('Results','Tables','wilcoxon_MODE_MOPSO.csv'));

end
