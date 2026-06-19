function [Rx, Restrictions] = Restriction(Fx, Config)

    N = size(Fx,1);
    M = Config.Objectives.Number;

    Restrictions = zeros(N, M);
    Rx = Fx;

    for j = 1:M %Varia com o numero do objetivo

        R = [];
        R = [R; find(Config.Restriction.Lower(j) > Fx(:,j))];
        R = [R; find(Config.Restriction.Upper(j) < Fx(:,j))];

        R = unique(R, 'rows');

        Restrictions(R,j) = 1;

        for k = 1:numel(R)

            i = R(k);

            switch Config.Restriction.Penalty(j)

                case 1
                    Rx(i,j) = Fx(i,j) + Config.Restriction.Weight(j);

                case 2
                    Rx(i,j) = Fx(i,j) * Config.Restriction.Weight(j);

                case 3
                    Rx(i,:) = Fx(i,:) + Config.Restriction.Weight(j);

                case 4
                    Rx(i,:) = Fx(i,:) * Config.Restriction.Weight(j);
            end
        end
    end

end