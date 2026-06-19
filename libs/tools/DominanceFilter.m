%% Dominance Filter
%
% A filter based on dominance criteria
%
function [Frente, Conjunto]=DominanceFilter(F,C)

    Xpop=size(F,1);
    Nobj=size(F,2);
    Nvar=size(C,2);
    Frente=zeros(Xpop,Nobj);
    Conjunto=zeros(Xpop,Nvar);
    k=0;

    for xpop=1:Xpop
        Dominado=0;

        for compara=1:Xpop
            if F(xpop,:)==F(compara,:)
                if xpop > compara
                    Dominado=1;
                    break;
                end
            else
                if F(xpop,:)>=F(compara,:)
                    Dominado=1;
                    break;
                end
            end
        end

        if Dominado==0
            k=k+1;
            Frente(k,:)=F(xpop,:);
            Conjunto(k,:)=C(xpop,:);
        end
    end
    Frente=Frente(1:k,:);
    Conjunto=Conjunto(1:k,:);

end