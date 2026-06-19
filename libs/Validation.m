function [Violations, MFEA] = Validation(Iter, FX, ExtFX, MFEA, Config, Log)
    %Verifica quando os objetivos saem das faixas admissiveis, e aciona
    %atualizações do surrogate no loop principal.
    if Config.Operation.Problem >= 5
        Violations = [];
        return;
    end

    % Fill in unset optional values.
    switch nargin
        case 5
            Log = true;
    end
    
    %% Identidy Cost Function Image Domain Violations
    Violations = [];

    for j=1:Config.Objectives.Number
        Violations = [Violations; find(Config.Objectives.Image.Lower(j) > FX(:,j))]; %retorna o indice onde ocorreu a violação
        Violations = [Violations; find(Config.Objectives.Image.Upper(j) < FX(:,j))];
    end

    % Extended Operation 
    if (Config.ExtObjectives.Operation)
        for j=1:Config.ExtObjectives.Number
            Violations = [Violations; find(Config.ExtObjectives.Image.Lower(j) > ExtFX(:,j))];
            Violations = [Violations; find(Config.ExtObjectives.Image.Upper(j) < ExtFX(:,j))];
        end
    end 

    % Remove dupes
    Violations = unique(Violations, 'rows'); %filtra linhas de violações unicas
    
    % Log Data
    if (Log == true)

        % Count violations
        NumberOfViolation = numel(Violations);%retorna o numero total de violações unicas

        % Store Validation
        MFEA.Validation.Iteration = [MFEA.Validation.Iteration; NumberOfViolation];

        if (Iter == 1)
            MFEA.Validation.Accumulative = [MFEA.Validation.Accumulative; NumberOfViolation];
        else
            MFEA.Validation.Accumulative = [MFEA.Validation.Accumulative; MFEA.Validation.Accumulative(end) + NumberOfViolation];
        end
    
    end

end