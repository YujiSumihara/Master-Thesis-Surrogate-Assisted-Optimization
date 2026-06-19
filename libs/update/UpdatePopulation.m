function [MFEA] = UpdatePopulation(Iter, Pop, MFEA, Config)

    if Config.Operation.Problem >= 5

        Nadd = Config.SpaceFilling.Nadd;

        Xs = Config.Domain.Initial + ...
             (Config.Domain.Final - Config.Domain.Initial) .* ...
             rand(Nadd, Config.Dimension.Number);

    else

        if (Iter < Config.Iter.Max * 0.35)
            Xs = GlobalImprovement(MFEA, Config);
        else
            Xs = LocalImprovement(Pop, MFEA, Config);
        end

    end

    MFEA.Xs = unique([MFEA.Xs; Xs], 'rows');

    newPoints = size(MFEA.Xs,1) - MFEA.Ns;
    
    MFEA.Statistics.NewTrainingPoints = MFEA.Statistics.NewTrainingPoints + newPoints;

    MFEA.Statistics.NewTrainingPointsHistory = [MFEA.Statistics.NewTrainingPointsHistory; Iter, newPoints, MFEA.Statistics.NewTrainingPoints];
    
    fprintf('Number of new training points: %d\n\n', newPoints);

    MFEA.Ns = size(MFEA.Xs, 1);

    MFEA.FXs = zeros(MFEA.Ns, Config.Objectives.Number);

    if Config.Operation.Problem < 5

        [~, metric_SF, metric_SF_n] = fill_avg(MFEA.Xs, 5, Config.Domain.Precision, ...
                                               Config.Domain.Initial, ...
                                               Config.Domain.Final, ...
                                               Config.SpaceFilling.lower_bound, ...
                                               Config.SpaceFilling.upper_bound, ...
                                               Config.SpaceFilling.deep_level, ...
                                               Config.SpaceFilling.behavior, ...
                                               Config.SpaceFilling.grid, ...
                                               Config.SpaceFilling.D_factor, ...
                                               Config.SpaceFilling.R_factor);

        MFEA.Metrics.Surrogate.SpaceFilling = ...
            [MFEA.Metrics.Surrogate.SpaceFilling; metric_SF, metric_SF_n];

    end

end