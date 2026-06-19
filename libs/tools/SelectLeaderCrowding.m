function leader = SelectLeaderCrowding(Archive)
    % força escolher extremos, regiões vazias, partes pouco exploradas da
    % fronteira
    if isempty(Archive.X)
        error('Archive empty.');
    end

    %distancia entre soluções vizinhas
    crowd = Archive.Crowding;

    % Remove Inf sem perder preferência pelos extremos
    finiteCrowd = crowd(isfinite(crowd));
    

    if isempty(finiteCrowd)
        prob = ones(size(crowd)) / numel(crowd);
    else
        %evita quebrar os extremos
        maxFinite = max(finiteCrowd);
        crowd(~isfinite(crowd)) = 2 * maxFinite;
        crowd = crowd - min(crowd);
        crowd = crowd + eps; % eps é um valor muito pequeno
        prob = crowd / sum(crowd); %transforma o crowding em uma distribuição probabilistica
    end

    % Se Crowding A = 10 B = 5 e C = 1 então A = 0.6 B = 0.3 e C = 0.1
    r = rand;
    cumProb = cumsum(prob);

    idx = find(r <= cumProb, 1, 'first');
    % Se r = 0.25 -> A, se r = 0.75 -> B e se r = 0.95 -> C
    leader = Archive.X(idx,:);
    % Escolhe lideres diversos

end