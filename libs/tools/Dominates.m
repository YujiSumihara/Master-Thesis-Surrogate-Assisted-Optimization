function flag = Dominates(a,b)
% A é melhor ou igual em todos os objetivos
% E
% A é estritamente melhor em pelo menos um
    flag = all(a <= b) && any(a < b);

end