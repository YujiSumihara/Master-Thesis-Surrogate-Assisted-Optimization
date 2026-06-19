% Space Filling: Fill N-Sphere
% Parameters: 
%    P:           Initial Population
%  Optional:
%    Nadd:        Maximum Number of New Points [1 ~ 50]
%    initial:     Initial Space Domain         [I_1;...; I_dim]
%    final:       Final Space Domain           [F_1;...; F_dim]
%    precision:   Precision                    [P_1;...; P_dim]
%    lower_bound: Lower Bound Space Domain     [LB_1;...; LB_dim]
%    upper_bound: Upper Bound Space Domain     [UB_1;...; UB_dim]
%    deep_level:  Deepness Level               [1 ~ 50]
%    behavior:    Behavior                     [0 ~ 1]
%    grid:        Grid Coverage                [0 ~ 10]
%    D_factor:    D Factor                     [0 ~ 10]
%    R_factor:    R Factor                     [0 ~ 10]
%
function [Cr, Sr, Nr, debug] = fill_Nsphere(P, Nadd, precision, initial, final, lower_bound, upper_bound, deep_level, behavior, grid, D_factor, R_factor)

[n, dim] = size(P);
    
% Check number of inputs.
if nargin > 12
    error('Error: Too many inputs, fill_Nsphere() requires at most 12 inputs.');
end

% Fill in unset optional values.
switch nargin
    case 1
        Nadd        = 5;
        precision   = zeros(1, dim);
        initial     = zeros(1, dim);
        final       = ones(1, dim);
        lower_bound = initial;
        upper_bound = final;
        deep_level  = 3;
        behavior    = 1;
        grid        = 1;
        D_factor    = 1;
        R_factor    = 1;
    case 2
        precision   = zeros(1, dim);
        initial     = zeros(1, dim);
        final       = ones(1, dim);
        lower_bound = initial;
        upper_bound = final;
        deep_level  = 3;
        behavior    = 1;
        grid        = 1;
        D_factor    = 1;
        R_factor    = 1;
    case 3
        initial     = zeros(1, dim);
        final       = ones(1, dim);
        lower_bound = initial;
        upper_bound = final;
        deep_level  = 3;
        behavior    = 1;
        grid        = 1;
        D_factor    = 1;
        R_factor    = 1;
    case 4
        final       = ones(1, dim);
        lower_bound = initial;
        upper_bound = final;
        deep_level  = 3;
        behavior    = 1;
        grid        = 1;
        D_factor    = 1;
        R_factor    = 1;
    case 5
        lower_bound = initial;
        upper_bound = final;
        deep_level  = 3;
        behavior    = 1;
        grid        = 1;
        D_factor    = 1;
        R_factor    = 1;
    case 6
        deep_level  = 3;
        behavior    = 1;
        grid        = 1;
        D_factor    = 1;
        R_factor    = 1;
    case 7
        behavior    = 1;
        grid        = 1;
        D_factor    = 1;
        R_factor    = 1;
    case 8
        grid        = 1;
        D_factor    = 1;
        R_factor    = 1;
    case 9
        grid        = 1;
        D_factor    = 1;
        R_factor    = 1;
    case 10
        D_factor    = 1;
        R_factor    = 1;
    case 11
        R_factor    = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Delta Space Domain
    delta = mean(final - initial);

    % Minimum Distance between points
    d_min = D_factor / (n * sqrt(Nadd));

	% Minimum Radius
	r_min = R_factor / (n + Nadd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Grid Values
    grid_values = 0 : 2^-grid : 1;

    % Grid Population
    F = initial + (final - initial) .* permn(grid_values, dim);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Extended Population
    ExtP = [F; P];

    % Ajust Precision
    %ExtP = roundM(ExtP, Precision);

    % Filter: Remove dupes
    ExtP = unique(ExtP, 'rows');

    % Number of points
    NP = size(ExtP, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Euclidian Distance between points in the extended population
    D = zeros(NP, NP);

    for i = 1:NP

        for k = i:NP

            % Ignore Diagonal: Zero Distance Problem
            if (i ~= k)
                D(i, k) = norm(ExtP(i,:) - ExtP(k,:));
            else
                D(i, k) = 1e1;
            end

            D(k, i) = D(i, k);

        end

    end

    % Sort Distances
    [~, D_index] = sort(D, 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Def: [P1_index, P2_index, ..., Pdim_index]
    points_group = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Run all points
    for i = 1:NP

        fill = struct();

        % Choose P1
        fill.lvl0 = i;

        % Choose P2 ... Pdim
        for j=1:dim

            fill.([sprintf('lvl%d', j)]) = fill_level(j, NP, deep_level, fill, D, D_index);

        end

        % Store points
        points_group = [points_group; fill.([sprintf('lvl%d', dim)])];

    end

    % Sort Points: Order of the points doesn`t matter
    points_group = sort(points_group, 2);

    % Filter: Remove dupes
    points_group = unique(points_group, 'rows');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    metric = [];
    center = [];

    % N-Sphere Center
    % https://www.ece.utah.edu/eceCTools/Triangulation/TriangulationSphereCntr.pdf
    for i=1:size(points_group,1)

        v = [];
        u = [];

        X0 = ExtP(points_group(i,1),:);

        group_i = X0;

        for j=2:dim+1

            Xi      = ExtP(points_group(i,j),:);
            group_i = [group_i; Xi];

        end

        if (rank(group_i) == dim)

            for j=2:dim+1

                % Vi = Xi - X0
                Xi      = ExtP(points_group(i,j),:);
                Vi      = Xi - X0;

                Vi_norm = norm(Vi);

                % V = |Vi| / 2
                v = [v; Vi_norm / 2];

                % U = Vi / |Vi|
                u = [u; (Vi / Vi_norm)];

            end

            % Solve
            r = u \ v;
            
            % Radius            
            %r_norm = norm(r);

            % Center
            Ci = X0 + r';

            % Ajust Precision
            Ci = roundM(Ci, precision);

            % Radius
            C_r = [];

            for k=1:size(P,1)

                Ri = norm(P(k,:) - Ci);
                C_r  = [C_r; Ri];

            end

            center = [center; Ci];
            %metric = [metric; r_norm];
            metric = [metric; min(C_r)];

        end

    end
    
    % Debug
    debug.p1 = size(center, 1);

    % Filter: Remove small ones
    S_index = find(metric > r_min);
    center = center(S_index, :);
    metric = metric(S_index, :);
    
    % Debug
    debug.p2 = size(center, 1);

    % Filter: Remove dupes
    [center, IA, ~] = unique(center, 'rows', 'stable');
    metric = metric(IA, :);
    
    % Debug
    debug.p3 = size(center, 1);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Zero solutions
    if (size(center, 1) == 0)
        Cr = [];
        Sr = 10e3;
        Nr = 0; 
        return;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    lower_bound_i = find(center(:,1) >= lower_bound(1));
    upper_bound_i = find(center(:,1) <= upper_bound(1));

    bound_index = intersect(lower_bound_i, upper_bound_i);

    % Respect Bounds
    for i=2:dim
        
        lower_bound_i = find(center(:,i) >= lower_bound(i));
        upper_bound_i = find(center(:,i) <= upper_bound(i));        
        bound_index_i = intersect(lower_bound_i, upper_bound_i);
        
        bound_index = intersect(bound_index, bound_index_i);

    end
    
    % Update
    center = center(bound_index, :);
    metric = metric(bound_index, :);
    
    % Debug
    debug.p4 = size(center, 1);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Sort metric
    [metric, IA] = sort(metric, 'descend');

    % Sort center
    center = center(IA,:);

    % Remove Very Near Points
    Cc = [];
    Cc_index = [];

    for i = 1:size(center,1)

        if (size(Cc,1) > 0)

            % Test the position with element above in the list
            if (norm(center(i-1,:) - center(i,:)) < d_min)
                continue;
            end

        end

        Cc = [Cc; center(i,:)];
        Cc_index = [Cc_index; i];

    end
    
    % Debug
    debug.p5 = size(Cc, 1);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Zero solutions
    if (size(Cc_index, 1) == 0)
        Cr = [];
        Sr = 10e3;
        Nr = 0; 
        return;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Update Metric
    [metric_sort, metric_index] = sort(metric(Cc_index,:), 'descend');

    % Update Order
    Cc = Cc(metric_index,:);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Choose Incircles
    Cr = Cc(1,:);
    Mr = metric_sort(1);
    
    N_Cc = size(Cc,1);
    i = 2;
    
    while (size(Cr,1) < Nadd && i <= N_Cc)

        skip = false;

        % Test the position with the already choosen incircles   
        for j=1:size(Cr,1)
            if (norm(Cr(j,:) - Cc(i,:)) < (Mr(j) + metric_sort(i)) * behavior)
                skip = true;
                continue;
            end       
        end

        if (skip == false)

            Cr = [Cr; Cc(i,:)];
            Mr = [Mr; metric_sort(i)];
            
        end
        
        i = i + 1;
        
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Nr = size(Cr, 1);
    Sr = 1;

    for i=1:Nr

        Sr = Sr + ((1+Mr(i)/delta)^(Nr - i + 1) - 1);

    end
        
    % Punish: Fail to add the require number of individuals
    Sr = Sr * (1 + log(1 + (Nadd - Nr))) + exp((Nadd - Nr) / n);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = fill_level(j, NP, deep_level, fill, D, D_index)

    out = [];

    for k=1:size(fill.([sprintf('lvl%d', j-1)]), 1)

        P = fill.([sprintf('lvl%d', j-1)])(k,:);
        
        % Distance between the points P1 and P2 
        if (j == 1)

            % Sorting index
            D_lvl_index = D_index(P,:);

        % Distance between the points P1, ..., P(j+1) and P(j+2)   
        else
            
            % Distance matrix
            D_dim = sum(D(P,:));

            % Sort Distances
            [~, D_lvl_index] = sort(D_dim, 2);

        end

        % Deepness: Limit Search
        deepness = min([NP-j, deep_level, size(D_lvl_index,2)]);
    
        for m=1:deepness
            out = [out; P, D_lvl_index(m)];
        end
    
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Round with Multiple Precision
function [X] = roundM(X, N)

    Nj = size(N, 2);

	for j=1:Nj
        X(:,j) = round(X(:,j), N(j));
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [M, I] = permn(V, N, K)
% PERMN - permutations with repetition
%   Using two input variables V and N, M = PERMN(V,N) returns all
%   permutations of N elements taken from the vector V, with repetitions.
%   V can be any type of array (numbers, cells etc.) and M will be of the
%   same type as V.  If V is empty or N is 0, M will be empty.  M has the
%   size numel(V).^N-by-N. 
%
%   When only a subset of these permutations is needed, you can call PERMN
%   with 3 input variables: M = PERMN(V,N,K) returns only the K-ths
%   permutations.  The output is the same as M = PERMN(V,N) ; M = M(K,:),
%   but it avoids memory issues that may occur when there are too many
%   combinations.  This is particulary useful when you only need a few
%   permutations at a given time. If V or K is empty, or N is zero, M will
%   be empty. M has the size numel(K)-by-N. 
%
%   [M, I] = PERMN(...) also returns an index matrix I so that M = V(I).
%
%   Examples:
%     M = permn([1 2 3],2) % returns the 9-by-2 matrix:
%              1     1
%              1     2
%              1     3
%              2     1
%              2     2
%              2     3
%              3     1
%              3     2
%              3     3
%
%     M = permn([99 7],4) % returns the 16-by-4 matrix:
%              99     99    99    99
%              99     99    99     7
%              99     99     7    99
%              99     99     7     7
%              ...
%               7      7     7    99
%               7      7     7     7
%
%     M = permn({'hello!' 1:3},2) % returns the 4-by-2 cell array
%             'hello!'        'hello!'
%             'hello!'        [1x3 double]
%             [1x3 double]    'hello!'
%             [1x3 double]    [1x3 double]
%
%     V = 11:15, N = 3, K = [2 124 21 99]
%     M = permn(V, N, K) % returns the 4-by-3 matrix:
%     %        11  11  12
%     %        15  15  14
%     %        11  15  11
%     %        14  15  14
%     % which are the 2nd, 124th, 21st and 99th permutations
%     % Check with PERMN using two inputs
%     M2 = permn(V,N) ; isequal(M2(K,:),M)
%     % Note that M2 is a 125-by-3 matrix
%
%     % PERMN can be used generate a binary table, as in
%     B = permn([0 1],5)  
%
%   NB Matrix sizes increases exponentially at rate (n^N)*N.
%
%   See also PERMS, NCHOOSEK
%            ALLCOMB, PERMPOS on the File Exchange

% tested in Matlab 2016a
% version 6.1 (may 2016)
% (c) Jos van der Geest
% Matlab File Exchange Author ID: 10584
% email: samelinoa@gmail.com

    narginchk(2,3) ;

    if fix(N) ~= N || N < 0 || numel(N) ~= 1 ;
        error('permn:negativeN','Second argument should be a positive integer') ;
    end
    nV = numel(V) ;

    if nargin==2, % PERMN(V,N) - return all permutations

        if nV==0 || N == 0,
            M = zeros(nV,N) ;
            I = zeros(nV,N) ;

        elseif N == 1,
            % return column vectors
            M = V(:) ;
            I = (1:nV).' ;
        else
            % this is faster than the math trick used for the call with three
            % arguments.
            [Y{N:-1:1}] = ndgrid(1:nV) ;
            I = reshape(cat(N+1,Y{:}),[],N) ;
            M = V(I) ;
        end
    else % PERMN(V,N,K) - return a subset of all permutations
        nK = numel(K) ;
        if nV == 0 || N == 0 || nK == 0
            M = zeros(numel(K), N) ;
            I = zeros(numel(K), N) ;
        elseif nK < 1 || any(K<1) || any(K ~= fix(K))
            error('permn:InvalidIndex','Third argument should contain positive integers.') ;
        else

            V = reshape(V,1,[]) ; % v1.1 make input a row vector
            nV = numel(V) ;
            Npos = nV^N ;
            if any(K > Npos)
                warning('permn:IndexOverflow', ...
                    'Values of K exceeding the total number of combinations are saturated.')
                K = min(K, Npos) ;
            end

            % The engine is based on version 3.2 with the correction
            % suggested by Roger Stafford. This approach uses a single matrix
            % multiplication.
            B = nV.^(1-N:0) ;
            I = ((K(:)-.5) * B) ; % matrix multiplication
            I = rem(floor(I),nV) + 1 ;
            M = V(I) ;
        end
    end
end