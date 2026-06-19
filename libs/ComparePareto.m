function [RMS, DataNORM] = ComparePareto(Pareto, Selector)

    A = [Pareto.FrontN, Pareto.ExtFrontN];
    
    if (Selector == 1)
        B = [Pareto.PoC.FrontN, Pareto.PoC.ExtFrontN]; 
    else
        B = [Pareto.Updated.FrontN, Pareto.Updated.ExtFrontN];        
    end

    if isempty(A) || isempty(B) || ~isequal(size(A), size(B))
        RMS = NaN;
        DataNORM = [NaN, NaN, NaN, NaN];
        return;
    end

    RMS = sqrt(mean((A(:) - B(:)).^2));                        
    NORM = zeros(size(A,1),1);

    for i = 1:size(A,1)
        NORM(i) = norm(A(i,:) - B(i,:));
    end

    DataNORM = [min(NORM), median(NORM), mean(NORM), max(NORM)];  

end