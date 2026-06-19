function [X, m] = int_SLHD_pdiv(N, dim, precision, initial, final, p, iter)

    % Check number of inputs.
    if nargin > 7
        error('Error: Too many inputs, SLHD_pdiv() requires at most 7 inputs.');
    end

    % Fill in unset optional values.
    switch nargin
        case 2
            precision = ones(1, dim);
            initial   = zeros(1, dim);
            final     = ones(1, dim);
            p         = 0.1;
            iter      = 10;
        case 3
            initial   = zeros(1, dim);
            final     = ones(1, dim);
            p         = 0.1;
            iter      = 10;
        case 4
            final     = ones(1, dim);
            p         = 0.1;
            iter      = 10;
        case 5
            p         = 0.1;
            iter      = 10;
        case 6
            iter      = 10;           
    end
    
    X = RoundM(initial + (final - initial) .* int_SLHD(N, dim), precision);
    m = metric_pure_diversity(X, p);

    while (iter > 0)
        
        X_i = RoundM(initial + (final - initial) .* int_SLHD(N, dim), precision);
        m_i = metric_pure_diversity(X_i, p);
        
        if (m_i > m)
            X = X_i;
            m = m_i;        
        end
        
        iter = iter - 1;
        
    end
    
end