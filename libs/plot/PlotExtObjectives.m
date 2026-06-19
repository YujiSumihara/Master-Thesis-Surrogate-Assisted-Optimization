function [] = PlotExtObjectives(Graphics, Pareto, Config)

    V = 1:Pareto.Np;
    
    for i=1:Config.ExtObjectives.Number

        subplot(Graphics.m, Graphics.n, Graphics.p(i))
        
            plot(V, Pareto.ExtFront(:,i), '--x');
            
            legendText = ["Current"];
            
            if (Pareto.Updated.Flag)
                hold on
                plot(V, Pareto.Updated.ExtFront(:,i), '-.')
                legendText = [legendText, "Updated"];
            end
            
            if (Pareto.PoC.Flag)
                hold on
                plot(V, Pareto.PoC.ExtFront(:,i), '-d')
                legendText = [legendText, "PoC"];
            end
    
            if (Config.ExtObjectives.Image.Lower(i) ~= Inf && Config.ExtObjectives.Image.Lower(i) ~= -Inf)
                hold on
                plot(V, ones(Pareto.Np, 1) * Config.ExtObjectives.Image.Lower(i), '.-')
                legendText = [legendText, "LB"];
            end

            if (Config.ExtObjectives.Image.Upper(i) ~= Inf && Config.ExtObjectives.Image.Upper(i) ~= -Inf)
                hold on
                plot(V, ones(Pareto.Np, 1) * Config.ExtObjectives.Image.Upper(i), '.-')
                legendText = [legendText, "UB"];
            end

            % Add Legend
            if (numel(legendText) > 1)
                legend(legendText, 'Location', 'best');
            end
            
			% Add Label
            if (Config.ExtObjectives.Unit(i) == "")
                ylabel(sprintf('%s', Config.ExtObjectives.Label(i))) 
            else
                ylabel(sprintf('%s (%s)', Config.ExtObjectives.Label(i), Config.ExtObjectives.Unit(i)))                 
            end
			
            xlabel('Pareto Set')
            
            % Limits           
            ylim([Config.Graphic.ExtObjectives.Lower(i), Config.Graphic.ExtObjectives.Upper(i)])

    end	

end