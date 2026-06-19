function Summary = BuildSummaryTable(Results)

    algorithms = fieldnames(Results);
    metrics = {'IGD','HV','Spacing','Time'};

    rows = {};

    for a = 1:numel(algorithms)

        alg = algorithms{a};

        for m = 1:numel(metrics)

            metric = metrics{m};
            x = Results.(alg).(metric);

            rows(end+1,:) = {alg, metric, ...
                min(x,[],'omitnan'), ...
                max(x,[],'omitnan'), ...
                mean(x,'omitnan'), ...
                median(x,'omitnan'), ...
                std(x,'omitnan')};
        end
    end

    Summary = cell2table(rows, ...
        'VariableNames', {'Algorithm','Metric','Min','Max','Mean','Median','Std'});

    %writetable(Summary, 'summary_MODE_MOPSO.csv');
    writetable(Summary, fullfile('Results','Tables','summary_MODE_MOPSO.csv'));

end