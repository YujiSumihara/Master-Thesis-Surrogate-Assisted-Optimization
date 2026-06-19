function PF_n = NormalizeByReference(PF, PF_ref)

    fmin = min(PF_ref, [], 1);
    fmax = max(PF_ref, [], 1);

    denom = fmax - fmin;
    denom(denom == 0) = eps;

    PF_n = (PF - fmin) ./ denom;

end