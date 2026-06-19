function Leader = SelectLeaderFromArchive(Archive, Config)

    nA = size(Archive.Position,1);

    if nA == 0
        error('Empty archive. There is no leader for MOPSO.');
    end

    if ~isfield(Config.Metaheuristic,'LeaderPoolSize')
        Config.Metaheuristic.LeaderPoolSize = 5;
    end

    PoolSize = min(Config.Metaheuristic.LeaderPoolSize, nA);

    [~,~,idxPool] = TruncateIndex(Archive.Jx, PoolSize);

    idx = idxPool(randi(PoolSize));

    Leader.Position = Archive.Position(idx,:);
    Leader.Jx       = Archive.Jx(idx,:);
    Leader.ExtJx    = Archive.ExtJx(idx,:);
    Leader.Dx       = Archive.Dx(idx,:);
end