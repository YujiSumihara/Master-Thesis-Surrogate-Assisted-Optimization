% pf is the pareto front (in the decision space), each row is a solution

% pf = [1.2 7.8
%       2.8 5.1
%       4.0 2.8
%       7.0 2.2
%       8.4 1.2];
function S = spacing(pf)

    absQ = size(pf,1);

    if (absQ == 1)
        S = 0;
        return;
    end
    
    d = [];
    all_sols = 1:absQ;  
    M = size(pf,2);

    for i=1:absQ
        
        sol = pf(i,:);
        ind_outros = setdiff(all_sols,i);
        % outros = pf(all((pf ~= repmat(sol,absQ,1))')',:); % dá problema
        % quando os fitness são iguais
        outros = pf(ind_outros,:);
        somatorio = [];
        
        for j=1:M
            somatorio(:,j) = abs(repmat(sol(1,j),absQ-1,1) - outros(:,j));
        end
        
        d(i) = min(sum(somatorio'));
        
    end

    d_barra = sum(d)/absQ;

    S = sqrt(1/absQ*sum((d-d_barra).^2));

end