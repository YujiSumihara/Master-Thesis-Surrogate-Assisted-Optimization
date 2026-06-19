function [X_min, X_max] = IdentifyRegion(X, Initial, Final, Dimension, Precision, Padding)

    % Add some padding
    X_min = RoundM(min(X) * (1 - Padding), Precision);
    X_max = RoundM(max(X) * (1 + Padding), Precision);

    % Verify Domain Bounds
    for i = 1:Dimension

        % Lower Bound
        if X_min(i) < Initial(i)                   
            X_min(i) = Initial(i);
        end

        % Upper Bound
        if X_max(i) > Final(i)                    
            X_max(i) = Final(i);
        end

    end

end