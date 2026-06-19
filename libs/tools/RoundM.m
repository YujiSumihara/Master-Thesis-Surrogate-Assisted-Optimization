% Round with Multiple Precision
function [X] = RoundM(X, N)

    Nj = size(N, 2);

    for j=1:Nj
        X(:,j) = round(X(:,j), N(j));
    end

end