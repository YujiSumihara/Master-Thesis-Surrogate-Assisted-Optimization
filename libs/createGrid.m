function [P] = createGrid(grid, initial, final, precision)

    dim = size(initial, 2);

    grid_delta = 1/(1 + grid);
    grid_values = 0:grid_delta:1;

    totalPoints = numel(grid_values)^dim;
    maxGridPoints = 50000;

    if totalPoints > maxGridPoints
        warning("createGrid would generate %d points. Using random sample instead.", totalPoints);

        P = initial + (final - initial) .* rand(maxGridPoints, dim);
    else
        grid_dist = permn(grid_values, dim);
        P = initial + (final - initial) .* grid_dist;
    end

    P = RoundM(P, precision);
    P = unique(P, 'rows');

end