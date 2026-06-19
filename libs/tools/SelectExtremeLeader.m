function leader = SelectExtremeLeader(Archive)

    F = Archive.F;
    X = Archive.X;

    nObj = size(F,2);

    % Escolhe aleatoriamente um objetivo
    obj = randi(nObj);

    % Para minimização: extremo = menor valor naquele objetivo
    [~, idx] = min(F(:,obj));

    leader = X(idx,:);

end