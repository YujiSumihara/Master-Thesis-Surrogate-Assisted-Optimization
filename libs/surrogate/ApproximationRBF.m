function S = ApproximationRBF(X, u, lambda, c)
    
    N = size(u, 1);
    S = c(1) + sum(c(2:end)' .* X);
    
    for i=1:N

        S = S + lambda(i) * norm(X - u(i,:)) ^ 3;

    end

end