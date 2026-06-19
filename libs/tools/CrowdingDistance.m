function CD = CrowdingDistance(F)

    [N, M] = size(F);
    CD = zeros(N,1);

    if N == 0
        CD = [];
        return;
    end

    if N <= 2
        CD(:) = inf;
        return;
    end

    for m = 1:M

        [fm, idx] = sort(F(:,m));

        CD(idx(1)) = inf;
        CD(idx(end)) = inf;

        fmin = fm(1);
        fmax = fm(end);

        if fmax == fmin
            continue;
        end

        for i = 2:N-1
            CD(idx(i)) = CD(idx(i)) + ...
                (fm(i+1) - fm(i-1)) / (fmax - fmin);
        end

    end

end