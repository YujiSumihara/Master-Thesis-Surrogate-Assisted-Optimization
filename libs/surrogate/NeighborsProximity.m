function [DX] = NeighborsProximity(X, Xs, Ns, Precision)

    % Population Size
    N = size(X, 1);

    % Ajust Precision
    X = RoundM(X, Precision);
    
    % Cost Function 
    DX = zeros(N, 1);
       
    for i=1:N

        % Distance Matrix
        DistanceMatrix = zeros(Ns, 1);
        
        for j=1:Ns
            DistanceMatrix(j) = norm(X(i,:) - Xs(j,:));
        end

        DX(i) = min(DistanceMatrix);
        
    end

end