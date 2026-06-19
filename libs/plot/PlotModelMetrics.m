function [] = PlotModelMetrics(Graphics, Iter, MFEA, Config)

    V  = 1:Iter;
    
	% Violations
    subplot(Graphics.m, Graphics.n, Graphics.p(1))
	
        plot(V, MFEA.Validation.Iteration, '--')
        legendText = ["Iteration"];
            
        hold on
        plot(V, MFEA.Validation.Accumulative, '.-')
        legendText = [legendText, "Accumulative"];
            
        hold on
        plot(V, mov_mean(MFEA.Validation.Iteration, 3), ':k')
        legendText = [legendText, "Mov Mean"];
        
        % Add Legend
        if (numel(legendText) > 1)
            legend(legendText, 'Location', 'best');
        end
            
        ylabel('Number of Violation')
        xlabel('Iteration')
        xlim([0 Iter])
		ylim([0, 1.1 * Config.Metaheuristic.Size])
	
	% Fx Evaluations
    subplot(Graphics.m, Graphics.n, Graphics.p(2))
	
        plot(MFEA.Evaluations(:,1), MFEA.Evaluations(:,2), '-')
		hold on
		plot(MFEA.Evaluations(:,1), MFEA.Evaluations(:,3), '--')

        ylabel('Fx Evaluations')
        xlabel('Iteration')
        legend('Total', 'Recovery', 'Location', 'best')
        xlim([0 1.1 * Iter])     
        
    % Space Filling
    subplot(Graphics.m, Graphics.n, Graphics.p(3))

        plot([0; MFEA.Updates.Iteration], MFEA.Metrics.Surrogate.SpaceFilling(:,1), '--x')
        ylabel('Space Filling')
        xlabel('Iteration')
        iter_end = max([1; MFEA.Updates.Iteration]);
        xlim([0 1.1 * iter_end]) 

    if (MFEA.Updates.N || MFEA.PoC.N)

        % NORM
        subplot(Graphics.m, Graphics.n, Graphics.p(4))

            legendText = [];
            
            if (MFEA.Updates.N)
                plot(MFEA.Updates.Iteration, MFEA.Metrics.Surrogate.NORM(:,3), '--x')
                legendText = [legendText, "Update"];
            end

            if (MFEA.PoC.N)
                hold on
                plot(MFEA.PoC.Iteration, MFEA.PoC.Pareto.NORM(:,3), '-.d')
                legendText = [legendText, "PoC"];
            end
            
            % Add Legend
            if (numel(legendText) > 1)
                legend(legendText, 'Location', 'best');
            end
            
            ylabel('Norm_N (AVG)')
            xlabel('Iteration')
            xlim([0 1.1 * Iter])
        
%         for i=1:(Config.Objectives.Number + Config.ExtObjectives.Number)
%             
%             % RMS
%             subplot(Graphics.m, Graphics.n, Graphics.p(5 + i - 1))
% 
%                 legendText = [];
% 
%                 if (MFEA.Updates.N)
%                     plot(MFEA.Updates.Iteration, MFEA.Metrics.Surrogate.RMS(:,i), '--x')
%                     legendText = [legendText, "Update"];
%                 end
% 
%                 if (MFEA.PoC.N)
%                     hold on
%                     plot(MFEA.PoC.Iteration, MFEA.PoC.Pareto.RMS(:,i), '-.d')
%                     legendText = [legendText, "PoC"];
%                 end
% 
%                 % Add Legend
%                 if (numel(legendText) > 1)
%                     legend(legendText, 'Location', 'best');
%                 end
% 
%                 ylabel('RMS_N')
%                 xlabel('Iteration')
%                 xlim([0 1.1 * Iter])
%             
%         end
        
    end
    
end

