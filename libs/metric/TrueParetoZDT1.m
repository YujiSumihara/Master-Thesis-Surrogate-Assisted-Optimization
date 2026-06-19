function PF = TrueParetoZDT1(N)

    % True Pareto Front for ZDT1
    % Input:
    %   N  - number of points
    %
    % Output:
    %   PF - N x 2 matrix [f1, f2]

    f1 = linspace(0, 1, N)';
    f2 = 1 - sqrt(f1);

    PF = [f1, f2];

end