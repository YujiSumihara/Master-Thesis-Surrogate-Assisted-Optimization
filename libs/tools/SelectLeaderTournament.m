function leader = SelectLeaderTournament(Archive, tournamentSize)
% SelectLeaderTournament selects a leader favoring high crowding distance.
% This helps MOPSO preserve diversity along the Pareto front.

    if isempty(Archive.X)
        error('Archive empty. It is not possible to select a leader.');
    end

    nA = size(Archive.X,1);

    if nargin < 2 || isempty(tournamentSize)
        tournamentSize = 3;
    end

    tournamentSize = min(tournamentSize, nA);

    idx = randperm(nA, tournamentSize);

    if isfield(Archive, 'Crowding') && ~isempty(Archive.Crowding)
        crowd = Archive.Crowding(:);
    else
        crowd = ones(nA,1);
    end

    c = crowd(idx);

    % Valores Inf representam extremos da frente e devem ser favorecidos.
    if any(isinf(c))
        candidates = idx(isinf(c));
        winner = candidates(randi(numel(candidates)));
    else
        [~, k] = max(c);
        winner = idx(k);
    end

    leader = Archive.X(winner,:);

end
