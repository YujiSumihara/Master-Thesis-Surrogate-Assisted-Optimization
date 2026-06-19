function [] = PlotParetoFront(Graphics, Iter, Pareto, Config)

    subplot(Graphics.m, Graphics.n, Graphics.p)

    switch Config.Operation.Type
        
        case {2, 3}
            
            scatter(Pareto.Front(:,1), Pareto.Front(:,2), 'MarkerEdgeColor','k', 'MarkerFaceColor',[0 .75 .75]);
            
            legendText = ["Current"];
            
            if (Pareto.Updated.Flag)
                hold on
                scatter(Pareto.Updated.Front(:,1), Pareto.Updated.Front(:,2), 'MarkerEdgeColor','k', 'MarkerFaceColor',[1 0 0]);
                legendText = [legendText, "Updated"];
            end
            
            if (Pareto.PoC.Flag)
                hold on
                scatter(Pareto.PoC.Front(:,1), Pareto.PoC.Front(:,2), 'MarkerEdgeColor','k', 'MarkerFaceColor',[0 1 0]);
                legendText = [legendText, "PoC"];
            end

            % Add Legend
            if (numel(legendText) > 1)
                legend(legendText, 'Location', 'best');
            end
            
            title(sprintf('Optmization Algorithm: Iteration #%d', Iter))
            
            xlabel(Config.Objectives.Label(1))
            ylabel(Config.Objectives.Label(2))
          
            xlim([Config.Graphic.Objectives.Lower(1), Config.Graphic.Objectives.Upper(1)])
            ylim([Config.Graphic.Objectives.Lower(2), Config.Graphic.Objectives.Upper(2)])           
        
    end

end