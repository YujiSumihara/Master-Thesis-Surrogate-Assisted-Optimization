function [Xn] = NormalizeColumn(X, Xmin, Xmax)

    denom = Xmax - Xmin;
    denom(denom == 0) = eps;

    Xn = (X - Xmin) ./ denom;

end