function [X, m] = int_SLHD_div(N, dim, precision, initial, final, iter)

    % Check number of inputs.
    if nargin > 6
        error('Error: Too many inputs, SLHD_div() requires at most 6 inputs.');
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
    
    bounds  = [initial', final'];
    
    X = RoundM(initial + (final - initial) .* int_SLHD(N, dim), precision);
    m = metric_diversity(X, bounds);

    while (iter > 0)
        
        P_i = RoundM(initial + (final - initial) .* int_SLHD(N, dim), precision);
        m_i = metric_diversity(P_i, bounds);
        
        if (m_i > m)
            X = P_i;
            m = m_i;        
        end
        
        iter = iter - 1;
        
    end
    
end