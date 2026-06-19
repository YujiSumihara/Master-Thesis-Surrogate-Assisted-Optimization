function igd = IGD(PF_true, PF_approx)

    N = size(PF_true,1);
    dist = zeros(N,1);

    for i = 1:N
        d = sqrt(sum((PF_approx - PF_true(i,:)).^2, 2));
        dist(i) = min(d);
    end

    igd = mean(dist);

end