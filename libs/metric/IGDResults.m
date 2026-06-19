function igd = IGDResults(PF_real, PF_sur)

    % Normalização usando a fronteira real como referência
    fmin = min(PF_real, [], 1);
    fmax = max(PF_real, [], 1);

    denom = fmax - fmin;
    denom(denom == 0) = eps;

    PF_real_n = (PF_real - fmin) ./ denom;
    PF_sur_n  = (PF_sur  - fmin) ./ denom;

    % IGD: para cada ponto real, acha o ponto surrogate mais próximo
    dist_min = zeros(size(PF_real_n,1),1);

    for i = 1:size(PF_real_n,1)
        d = sqrt(sum((PF_sur_n - PF_real_n(i,:)).^2, 2));
        dist_min(i) = min(d);
    end

    igd = mean(dist_min);

end