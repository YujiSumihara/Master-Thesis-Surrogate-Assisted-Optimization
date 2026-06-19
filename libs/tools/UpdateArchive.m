function Archive = UpdateArchive(Archive, X, Jx, ExtJx, Dx, Config)

    if isempty(Archive.Position)
        Pop = X;
        Cost = Jx;
        Ext = ExtJx;
        Dist = Dx;
    else
        Pop = [Archive.Position; X];
        Cost = [Archive.Jx; Jx];
        Ext = [Archive.ExtJx; ExtJx];
        Dist = [Archive.Dx; Dx];
    end

    % Remove duplicates in design space
    PopRM = RoundM(Pop, Config.Domain.Precision);
    [~, ia] = unique(PopRM, 'rows');

    Pop = Pop(ia,:);
    Cost = Cost(ia,:);
    Ext = Ext(ia,:);
    Dist = Dist(ia,:);

    % Ranking cost may include surrogate distance objective
    CostRank = Cost;

    if Config.Restriction.Flag
        [CostRank, ~] = Restriction(CostRank, Config);
    end

    switch Config.Operation.SurrogateCostFunction
        case {1}
            CostRank = [CostRank, Dist];
    end

    %[rank, ~, index] = TruncateIndex(CostRank, Config.Metaheuristic.Size);
    ArchiveSize = min(Config.Metaheuristic.ArchiveSize, size(Pop,1));
    [rank, ~, index] = TruncateIndex(CostRank, ArchiveSize);

    Archive.Position = Pop(index,:);
    Archive.Jx = Cost(index,1:Config.Objectives.Number);
    Archive.ExtJx = Ext(index,:);
    Archive.Dx = Dist(index,:);
    Archive.Rank = rank;
end