function leader = SelectLeaderAdaptive(Archive, Iter, Config)

    if isempty(Archive.X)
        error('Archive empty.');
    end

    MaxIter = Config.Iter.Max;

    % Probabilidade de escolher extremos:
    % maior no início, menor no fim
    pExtreme = 0.30 * (1 - Iter/MaxIter) + 0.05;

    % Probabilidade de escolha aleatória:
    % ajuda a evitar estagnação
    pRandom = 0.10 * (1 - Iter/MaxIter);

    r = rand;

    if r < pExtreme

        leader = SelectExtremeLeader(Archive);

    elseif r < pExtreme + pRandom

        idx = randi(size(Archive.X,1));
        leader = Archive.X(idx,:);

    else

        leader = SelectLeaderCrowding(Archive);

    end

end