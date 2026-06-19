function [rank, CD, index] = TruncateIndex(PopFit, N)

    rank  = [];
    CD    = [];
    index = [];

    n_Var = 0;
    r = nonDominatedRank(PopFit);
    n_ranks = max(r);

    

    for i=1:n_ranks

        % sols. do rank = i 
        ind_r   = r == i;
        n_ind_r = sum(ind_r);    
        rFit    = PopFit(ind_r,:);

        % Index
        index_i = find(ind_r == 1);

        % calcula CD
        cf = computecf(rFit);
        [~, I] = sort(cf,'descend');

        % sort de acordo com CD
        rFit    = rFit(I,:);
        cf      = cf(I);
        index_i = index_i(I);

        % concatena sols  
        rank  = [rank; ones(n_ind_r,1) * i];
        CD    = [CD; cf];
        index = [index; index_i];

        % atualiza counter
        n_Var = n_Var + n_ind_r;

        % sai se já tem o no. de sols maximo
        if n_Var > N
            
            rank  = rank(1:N,:);
            CD    = CD(1:N,:);
            index = index(1:N,:);
            
            break;
            
        end

    end
    
end