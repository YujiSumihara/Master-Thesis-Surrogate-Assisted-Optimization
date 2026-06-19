function [MFEA, Database] = UpdateModels(Iter, MFEA, Database, Config)

    % Cost Function Evaluation
    [MFEA.FXs, MFEA.FxEvaluations, Database, MFEA.ExtFXs, CostStats] = CostFunction(MFEA.Xs, Database, Config);

    MFEA.Statistics.TotalCostFunctionCalls = MFEA.Statistics.TotalCostFunctionCalls + 1;
    MFEA.Statistics.TotalRequestedPoints   = MFEA.Statistics.TotalRequestedPoints + CostStats.TotalRequestedPoints;
    MFEA.Statistics.NewAnsysCalls          = MFEA.Statistics.NewAnsysCalls + CostStats.NewAnsysCalls;
    MFEA.Statistics.ReusedDatabasePoints   = MFEA.Statistics.ReusedDatabasePoints + CostStats.ReusedDatabasePoints;
    MFEA.Statistics.TotalAnsysTime         = MFEA.Statistics.TotalAnsysTime + CostStats.TotalAnsysTime;
    MFEA.Statistics.TotalSimulationTime    = MFEA.Statistics.TotalSimulationTime + CostStats.TotalSimulationTime;
    
    % Log Number of Evaluations
    MFEA.Evaluations = [MFEA.Evaluations; [Iter, MFEA.FxEvaluations]];

    % Update Surrogates Models
    [MFEA] = Surrogates(MFEA, Config);

    % Log Update
    MFEA.Updates.Iteration = [MFEA.Updates.Iteration; Iter];
    MFEA.Updates.N = MFEA.Updates.N + 1;
            
end