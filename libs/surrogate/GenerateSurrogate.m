function [lambda, c] = GenerateSurrogate(u, F)

    [N, d] = size(u);

    % Distance Matrix
    phi = zeros(N, N);

    for i=1:N
        
        for j=1:N
            
            phi(i,j) = norm(u(i,:) - u(j,:)) ^ 3;
            
        end
        
    end

    % P Matrix
    p = ones(N, d + 1);
    p(:, 2 : end) = u;

    % Linear System: A * x = B
    A = zeros(N + d + 1, N + d + 1);
    B = zeros(N + d + 1, 1);
    
    A(1 : N, 1 : N) = phi + 1e-6*eye(N); %alterei
    A(1 : N, N + 1 : end) = p;
    A(N + 1 : end, 1 : N) = p.';
    
    B(1 : N, 1) = F;

    % Solve
    x = A \ B;

    lambda = x(1 : N, 1);
    c      = x(N + 1 : end, 1);

end