function out = mov_mean(P,k)

    n = size(P, 1);

    if (n > k)
        out = mean(P(n-k:end));

    else
        out = mean(P);

    end

end