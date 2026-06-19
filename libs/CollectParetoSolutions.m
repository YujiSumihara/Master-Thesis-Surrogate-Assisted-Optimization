function Selected = CollectParetoSolutions(matFile, algName, problemName)

    if nargin < 2
        algName = 'MODE';
    end

    if nargin < 3
        problemName = 'Problema';
    end

    S = load(matFile);

    if isfield(S,'Output')
        Output = S.Output;
    else
        error('The .mat file does not contain the Output variable.');
    end

    if isfield(Output,'Pareto') && isfield(Output.Pareto,'Real')
        PF = Output.Pareto.Real.Front;
        X  = Output.Pareto.Real.Set;
        frontType = 'Real';
    elseif isfield(Output,'Pareto') && isfield(Output.Pareto,'Model')
        PF = Output.Pareto.Model.Front;
        X  = Output.Pareto.Model.Set;
        frontType = 'Model';
    else
        error('I couldnt find Output.Pareto.Real or Output.Pareto.Model.');
    end

    valid = all(~isnan(PF),2);
    PF = PF(valid,:);
    X  = X(valid,:);

    if isempty(PF)
        error('The Pareto frontier is empty.');
    end

    % Conversão correta:
    % PF(:,1) = -Safety Factor
    % PF(:,2) = Massa
    SafetyFactor_all = -PF(:,1);
    Mass_all         = PF(:,2);

    % Seleção dos pontos
    [~, idxMinMass] = min(Mass_all);
    [~, idxMaxFS]   = max(SafetyFactor_all);

    [~, idxSortMass] = sort(Mass_all);
    idxMid = idxSortMass(round(numel(idxSortMass)/2));

    idxSelected = unique([idxMinMass, idxMid, idxMaxFS], 'stable');

    Xsel = X(idxSelected,:);
    PFsel = PF(idxSelected,:);

    SafetyFactor = -PFsel(:,1);
    Mass         = PFsel(:,2);

    SolutionType = strings(length(idxSelected),1);

    for i = 1:length(idxSelected)
        if idxSelected(i) == idxMinMass
            SolutionType(i) = "Less Mass";
        elseif idxSelected(i) == idxMid
            SolutionType(i) = "Intermediate solution";
        elseif idxSelected(i) == idxMaxFS
            SolutionType(i) = "Greater safety factor";
        else
            SolutionType(i) = "Selected";
        end
    end

    Selected = table(SolutionType, Mass, SafetyFactor);

    for j = 1:size(Xsel,2)
        Selected.(sprintf('x%d',j)) = Xsel(:,j);
    end

    fprintf('\n=============================================\n');
    fprintf('Collection of solutions - %s - %s\n', problemName, algName);
    fprintf('Pareto front used: %s\n', frontType);
    fprintf('Archive: %s\n', matFile);
    fprintf('=============================================\n\n');

    disp(Selected);

    figure;
    scatter(Mass_all, SafetyFactor_all, 40, 'filled');
    hold on;

    scatter(Mass, SafetyFactor, 120, 'r', ...
        'filled', ...
        'MarkerEdgeColor','k');

    for i = 1:length(Mass)
        text(Mass(i), SafetyFactor(i), ...
            sprintf('  %s', SolutionType(i)), ...
            'FontSize', 10, ...
            'FontWeight','bold');
    end

    xlabel('Mass');
    ylabel('Safety Factor');
    title(sprintf('%s - Selected solutions from the Pareto frontier (%s)', ...
        problemName, algName));

    grid on;
    box on;

    outName = sprintf('SelectedSolutions_%s_%s.csv', problemName, algName);
    writetable(Selected, outName);

    fprintf('\nTable saved in: %s\n', outName);

end