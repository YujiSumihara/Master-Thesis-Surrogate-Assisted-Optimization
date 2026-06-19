function [Pareto] = Sanitization(X, FX, ExtFX, DX, rank, Violations, Precision, NormMin, NormMax, ExtNormMin, ExtNormMax)
    %Remove soluções que violam o limite e monta a estrutura PARETO
    Pareto = struct();

    % Critical Failure
    if (size(Violations, 1) == size(X, 1))
        
        %warning("Critial Failure: Not a good surrogate!");
        warning("Violations equal to the number of relatives! - Sanitization");
        % Dirty Fix: The Show Cannot Stop
        % Set the first Violation as Rank 1
        rank(Violations(1)) = 1;
        Violations = Violations(Violations~=1);
        
    end
        
    % Identify Rank 1 solutions
    Index = find(rank == 1);

    % Remove solutions that failed Validation
    Index = setdiff(Index, Violations);

    % Generate ParetoSet and ParetoFront
    Pareto.Set      = X(Index,:);
    Pareto.Front    = FX(Index,:);  
    Pareto.ExtFront = ExtFX(Index,:);  
    Pareto.Distance = DX(Index,:);       

    % Ajust precision
    Pareto.Set = RoundM(Pareto.Set, Precision);
    
    % Ajust precision
    Pareto.Np = size(Pareto.Set, 1);
    
    % Normalized Pareto Front
	Pareto.FrontN    = NormalizeColumn(Pareto.Front, NormMin, NormMax);

    if size(Pareto.ExtFront,2) > 0
        Pareto.ExtFrontN = NormalizeColumn(Pareto.ExtFront, ExtNormMin, ExtNormMax);
    else
        Pareto.ExtFrontN = [];
    end
    
    % Updated
    Pareto.Updated = struct();
    Pareto.Updated.Flag = false;
    Pareto.Updated.Front = [];
    Pareto.Updated.ExtFront = [];  
    Pareto.Updated.Distance = [];
    Pareto.Updated.FrontN = [];
    Pareto.Updated.ExtFrontN = [];
    
    % Proof of Concept
    Pareto.PoC = struct();
    Pareto.PoC.Flag = false;
    Pareto.PoC.Front = [];
    Pareto.PoC.ExtFront = []; 
    Pareto.PoC.FrontN = [];
    Pareto.PoC.ExtFrontN = [];
            
end