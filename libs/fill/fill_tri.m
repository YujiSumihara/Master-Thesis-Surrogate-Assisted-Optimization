% Space Filling: Fill Tri
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
function [Cr, Sr, Nr, debug] = fill_tri(P, Nadd, precision, initial, final, lower_bound, upper_bound, deep_level, behavior, grid, D_factor, R_factor)

[n, dim] = size(P);
    
% Check number of inputs.
if nargin > 12
    error('Error: Too many inputs, fill_tri() requires at most 12 inputs.');
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
    %ExtP = roundM(ExtP, precision);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Def: [P1, P2, P3, Area]
    triangle = [];

    % Def: [Ox, Oy, Radius]
    C = [];

    % Sort Distances
    [D_sort, D_index] = sort(D, 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for i = 1:NP

        % Choose P1
        P1_index = i;
        P1       = ExtP(P1_index,:);

        % Restrict Search
        deep_level_1 = min([NP, deep_level]);

        for j=1:deep_level_1

            % Choose P2 as the closest point to P1
            P2_index = D_index(i,j);
            P2       = ExtP(P2_index,:);

            % Distance to the points P1 and P2
            D_aux = sum(D([P1_index, P2_index],:));

            % Sort Distances
            [D_aux_sort, D_aux_index] = sort(D_aux, 2);

            area = [];

            % Found Possible Combinations
            for k = 1:NP-2

                % Choose P3 as the closest point to P1 and P2
                P3_index = D_aux_index(k);
                P3       = ExtP(P3_index,:);

                % Shoelace Formula Matrix
                shoelace = [ones(1,3); P1', P2', P3'];
                
                [s_row, s_column] = size(shoelace);
                
                if (s_row ~= s_column)
                    error('Houston we have a problem!');
                end
                
                area_k = abs(det(shoelace)) / 2;
                
                % Area: Shoelace Formula 
                area = [area; area_k];

            end

            % Filter Triangles with null area
            area_index = find(area > 0);

            % Restrict Search
            deep_level_2 = min([size(area_index,1), deep_level]);

            for k = 1:deep_level_2

                % Choose the two closet points with 
                P3_index = D_aux_index(area_index(k));
                P3       = ExtP(P3_index,:);

                % Add triangle
                triangle = [triangle; P1_index, P2_index, P3_index, area(area_index(k))];

                % Incenter of a Triangle
                % https://www.mathopenref.com/coordincenter.html

                % Side Lengths
                a = D(P2_index, P3_index);
                b = D(P3_index, P1_index); 
                c = D(P1_index, P2_index);
                
                % Perimeter
                p = a + b + c;

                Ox = (a * P1(1) + b * P2(1) + c * P3(1)) / p;
                Oy = (a * P1(2) + b * P2(2) + c * P3(2)) / p;

                % Center
                Ci = [Ox, Oy];
                
                % Ajust Precision
                Ci = roundM(Ci, precision);

                % Circle Radius
                % https://math.stackexchange.com/questions/1413372/find-cartesian-coordinates-of-the-incenter
                % r = 2 * area(area_index(k)) / p;

                % Radius
                C_r = [];

                for k=1:size(P,1)

                    Ri = norm(P(k,:) - Ci);
                    C_r  = [C_r; Ri];

                end

                %C = [C; Ci, r];
                C = [C; Ci, min(C_r)];

            end

        end

    end
    
    % Debug
    debug.p1 = size(C, 1);

    % Filter: Remove small ones
    S_index = find(C(:,3) > r_min);
    C = C(S_index, :);
    
    % Debug
    debug.p2 = size(C, 1);

    % Filter: Remove dupes
    C = unique(C, 'rows');
    
    % Debug
    debug.p3 = size(C, 1);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Zero solutions
    if (size(C, 1) == 0)
        Cr = [];
        Sr = 10e3;
        Nr = 0; 
        return;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    lower_bound_i = find(C(:,1) >= lower_bound(1));
    upper_bound_i = find(C(:,1) <= upper_bound(1));

    bound_index = intersect(lower_bound_i, upper_bound_i);

    % Respect Bounds
    for i=2:dim
        
        lower_bound_i = find(C(:,i) >= lower_bound(i));
        upper_bound_i = find(C(:,i) <= upper_bound(i));        
        bound_index_i = intersect(lower_bound_i, upper_bound_i);
        
        bound_index = intersect(bound_index, bound_index_i);

    end
    
    % Update
    C = C(bound_index, :);
    
    % Debug
    debug.p4 = size(C, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Sort incircles by radius
    [~, R_index] = sort(C(:,3), 'descend');

    % Sort incircles
    C_sort = C(R_index,:);

    % Remove Very Near Incircles
    Cc = [];

    for i = 1:size(C_sort,1)

        if (size(Cc,1) > 0)

            % Test the position with the incircle above in the list
            if (norm(C_sort(i-1,1:end-1) - C_sort(i,1:end-1)) < d_min)
                continue;
            end

        end

        skip = false;

        % Test the position with the population: remove point if the input population is inside the incircle   
        for j=1:n
            if (norm(P(j,:) - C_sort(i,1:end-1)) < C_sort(i,end))
                skip = true;
                continue;
            end       
        end

        if (skip == false)    
            Cc = [Cc; C_sort(i,:)];    
        end

    end
    
    % Debug
    debug.p5 = size(Cc, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Zero solutions
    if (size(Cc, 1) == 0)
        CR = [];
        Sr = 10e3;
        Nr = 0; 
        return;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Choose Incircles
    Cr = Cc(1,:);

    N_Cc = size(Cc,1);
    i = 2;
    
    while (size(Cr,1) < Nadd && i <= N_Cc)

        skip = false;

        % Test the position with the already choosen incircles   
        for j=1:size(Cr,1)
            if (norm(Cr(j,1:end-1) - Cc(i,1:end-1)) < (Cr(j,end) + Cc(i,end)) * behavior)
                skip = true;
                continue;
            end       
        end

        if (skip == false)

            Cr = [Cr; Cc(i,:)]; 
            
        end
        
        i = i + 1;
        
    end

    Mr = Cr(:, end);
    Cr = Cr(:,1:end-1);
    
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