function Index = GetIndexNumber(Param, Config)
    
    Delta = (Param - Config.Domain.Initial) .* Config.Index.Deepness;
    
    Index = 1 + Delta(end);    

    for i=1:Config.Dimension.Number-1
        
        Index = Index + Delta(i) * prod(Config.Index.Weigth(i+1:end)); %%Produto de uma matriz de elementos

    end
    
end