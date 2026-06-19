function [R] = NRatio(X, Initial, Final, Precision)   
    
    % Number of Possible Configurations of the Domain
    Rt = prod(1 + (Final - Initial) .* 10 .^ Precision);  

    % Add some padding
    X_min = min(X);
    X_max = max(X);
    
    % Number of Possible Configurations of the Set
    Ri = prod(1 + (X_max - X_min) .* 10 .^ Precision);    

    R = Ri / Rt;

end