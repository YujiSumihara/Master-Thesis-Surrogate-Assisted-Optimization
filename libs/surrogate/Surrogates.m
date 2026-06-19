function [MFEA] = Surrogates(MFEA, Config)

    [N, d] = size(MFEA.Xs);
    
    % Surrogates
    MFEA.Surrogates = struct();
    
    % Objectives
    MFEA.Surrogates.Objectives.Lambda = zeros(N,     Config.Objectives.Number);
    MFEA.Surrogates.Objectives.C      = zeros(d + 1, Config.Objectives.Number);  

    for i = 1:Config.Objectives.Number
        
        [lambda, c] = GenerateSurrogate(MFEA.Xs, MFEA.FXs(:,i));
                
        MFEA.Surrogates.Objectives.Lambda(:,i) = lambda;
        MFEA.Surrogates.Objectives.C(:,i)      = c;
        
    end
    
    % Extended Objectives
    MFEA.Surrogates.ExtObjectives.Lambda = zeros(N,     Config.ExtObjectives.Number);
    MFEA.Surrogates.ExtObjectives.C      = zeros(d + 1, Config.ExtObjectives.Number); 
            
    switch Config.Operation.Type

        case Config.Operation.Validation     
            
            for i = 1:Config.ExtObjectives.Number
            
                [lambda, c] = GenerateSurrogate(MFEA.Xs, MFEA.ExtFXs(:,i));

                MFEA.Surrogates.ExtObjectives.Lambda(:,i) = lambda;
                MFEA.Surrogates.ExtObjectives.C(:,i)      = c;
            
            end
            
    end

end