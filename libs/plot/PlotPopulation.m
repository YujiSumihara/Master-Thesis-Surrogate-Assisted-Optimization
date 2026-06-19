function [] = PlotPopulation(Graphics, Pareto, Config)

    for i=1:Config.Dimension.Number

        subplot(Graphics.m, Graphics.n, Graphics.p(i))
        
            nbits = min([10, Config.Domain.Delta(i)]);
        
            histfit(Pareto.Set(:,i), nbits, 'kernel')
            
            if (Config.Dimension.Unit(i) == "")
                xlabel(sprintf('%s [%0.2f - %0.2f]', Config.Dimension.Label(i), Config.Domain.Initial(i), Config.Domain.Final(i))) 
            else
                xlabel(sprintf('%s (%s) [%0.2f - %0.2f]', Config.Dimension.Label(i), Config.Dimension.Unit(i), Config.Domain.Initial(i), Config.Domain.Final(i)))                 
            end
            
            ylabel('Pareto Set')

    end
    
end