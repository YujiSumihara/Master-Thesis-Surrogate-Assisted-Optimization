function [FX, ExtFX] = CostFunctionRBF(X, MFEA, Config)
    
    % Population Size
    N = size(X, 1);

    % Ajust Precision
    X = RoundM(X, Config.Domain.Precision);
    
    % Cost Function 
    FX    = zeros(N, Config.Objectives.Number);
    % Extended Cost Function 
    ExtFX = zeros(N, Config.ExtObjectives.Number);

    for i=1:N
        
        % Objectives Surrogates
        for j = 1:Config.Objectives.Number

            lambda = MFEA.Surrogates.Objectives.Lambda(:,j);
            c      = MFEA.Surrogates.Objectives.C(:,j);
            
            FX(i,j) = ApproximationRBF(X(i,:), MFEA.Xs, lambda, c);

        end      
        
        % Extended Objectives Surrogates
        switch Config.Operation.Type

            case Config.Operation.Validation % caso for do tipo 3
                
                for j = 1:Config.ExtObjectives.Number
                    lambda = MFEA.Surrogates.ExtObjectives.Lambda(:,j);
                    c      = MFEA.Surrogates.ExtObjectives.C(:,j);

                    ExtFX(i,j) = ApproximationRBF(X(i,:), MFEA.Xs, lambda, c);

                end
                
        end
        
    end

end