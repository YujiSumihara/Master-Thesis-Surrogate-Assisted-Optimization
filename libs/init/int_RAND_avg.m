function [X, m] = int_RAND_avg(N, dim, precision, initial, final, iter)

    % Check number of inputs.
    if nargin > 6
        error('Error: Too many inputs, SLHD_pdiv() requires at most 6 inputs.');
    end

    % Fill in unset optional values.
    switch nargin
        case 2
            precision = ones(1, dim);
            initial   = zeros(1, dim);
            final     = ones(1, dim);
            iter      = 10;
        case 3
            initial   = zeros(1, dim);
            final     = ones(1, dim);
            iter      = 10;
        case 4
            final     = ones(1, dim);
            iter      = 10;
        case 5
            iter      = 10;
    end
    
    X = RoundM(initial + (final - initial) .* rand(N, dim), precision);
    [~, m, ~, ~] = fill_avg(X, 5, precision, initial, final); 

    while (iter > 0)
        
        X_i = RoundM(initial + (final - initial) .* rand(N, dim), precision);
        [~, m_i, ~, ~] = fill_avg(X, 5, precision, initial, final);
        
        if (m_i < m)
            X = X_i;
            m = m_i;        
        end
        
        iter = iter - 1;
        
    end
    
end