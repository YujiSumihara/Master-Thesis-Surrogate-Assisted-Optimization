function [] = PlotObjectives(Graphics, Pareto, Config)

    V = 1:Pareto.Np;
    
    subplot(Graphics.m, Graphics.n, Graphics.p(1))

        plot(V, Pareto.Distance, '--x');
        legendText = ["Current"];
            
        if (Pareto.Updated.Flag)
            hold on
            plot(V, Pareto.Updated.Distance, '-.')
            legendText = [legendText, "Updated"];
        end        

        % Add Legend
        if (numel(legendText) > 1)
            legend(legendText, 'Location', 'best');
        end
        
        ylabel('Distance_{MIN}') 
        xlabel('Pareto Set')
        
    for i=1:Config.Objectives.Number

        subplot(Graphics.m, Graphics.n, Graphics.p(i+1))
        
            plot(V, Pareto.Front(:,i), '--x');
            
            legendText = ["Current"];
            
            if (Pareto.Updated.Flag)
                hold on
                plot(V, Pareto.Updated.Front(:,i), '-.')
                legendText = [legendText, "Updated"];
            end
            
            if (Pareto.PoC.Flag)
                hold on
                plot(V, Pareto.PoC.Front(:,i), '-d')
                legendText = [legendText, "PoC"];
            end
    
            if (Config.Objectives.Image.Lower(i) ~= Inf && Config.Objectives.Image.Lower(i) ~= -Inf)
                hold on
                plot(V, ones(Pareto.Np, 1) * Config.Objectives.Image.Lower(i), '.-')
                legendText = [legendText, "LB"];
            end

            if (Config.Objectives.Image.Upper(i) ~= Inf && Config.Objectives.Image.Upper(i) ~= -Inf)
                hold on
                plot(V, ones(Pareto.Np, 1) * Config.Objectives.Image.Upper(i), '.-')
                legendText = [legendText, "UB"];
            end

            if (Config.Restriction.Lower(i) ~= Inf && Config.Restriction.Lower(i) ~= -Inf)
                hold on
                plot(V, ones(Pareto.Np, 1) * Config.Restriction.Lower(i), '.-')
                legendText = [legendText, "LR"];
            end

            if (Config.Restriction.Upper(i) ~= Inf && Config.Restriction.Upper(i) ~= -Inf)
                hold on
                plot(V, ones(Pareto.Np, 1) * Config.Restriction.Upper(i), '.-')
                legendText = [legendText, "UR"];
            end          

            % Add Legend
            if (numel(legendText) > 1)
                legend(legendText, 'Location', 'best');
            end
            
			% Add Label
            if (Config.Objectives.Unit(i) == "")
                ylabel(sprintf('%s', Config.Objectives.Label(i))) 
            else
                ylabel(sprintf('%s (%s)', Config.Objectives.Label(i), Config.Objectives.Unit(i)))                 
            end
			
            xlabel('Pareto Set')
            
            % Limits           
            ylim([Config.Graphic.Objectives.Lower(i), Config.Graphic.Objectives.Upper(i)])

    end
            
end