function [] = PlotOptMetrics(Graphics, Iter, MFEA, Config)

    V  = 1:Iter;
    
    if (MFEA.Updates.N)
        Vu = 1:MFEA.Updates.Iteration(end);
    end
    
	% Cardinality
    subplot(Graphics.m, Graphics.n, Graphics.p(1))
	
        plot(V, MFEA.Metrics.Metaheuristic.OTF(:,1), '--*')
            
        legendText = ["On the Fly"];
		
        if (MFEA.Updates.N)
            hold on
            plot(Vu, MFEA.Metrics.Metaheuristic.Updated(:,1), '-.')
            legendText = [legendText, "Updated"];
        end          

        % Add Legend
        if (numel(legendText) > 1)
            legend(legendText, 'Location', 'best');
        end
		
        ylabel('Cardinality')
        xlabel('Iteration')
        xlim([0 1.1 * Iter])
		ylim([0, 1.1 * Config.Metaheuristic.Size])
    
	% Spacing
    subplot(Graphics.m, Graphics.n, Graphics.p(2))
	
        plot(V, MFEA.Metrics.Metaheuristic.OTF(:,2), '--*')
            
        legendText = ["On the Fly"];
		
        if (MFEA.Updates.N)
            hold on
            plot(Vu, MFEA.Metrics.Metaheuristic.Updated(:,2), '-.')
            legendText = [legendText, "Updated"];
        end          

%         % Add Legend
%         if (numel(legendText) > 1)
%             legend(legendText, 'Location', 'best');
%         end
		
        ylabel('Spacing')
        xlabel('Iteration')
        xlim([0 1.1 * Iter])
    
	% NRatio
    subplot(Graphics.m, Graphics.n, Graphics.p(3))
	
        plot(V, MFEA.Metrics.Metaheuristic.OTF(:,3), '--*')
            
        legendText = ["On the Fly"];
		
        if (MFEA.Updates.N)
            hold on
            plot(Vu, MFEA.Metrics.Metaheuristic.Updated(:,3), '-.')
            legendText = [legendText, "Updated"];
        end          

%         % Add Legend
%         if (numel(legendText) > 1)
%             legend(legendText, 'Location', 'best');
%         end
		
        ylabel('NRatio')
        xlabel('Iteration')
        xlim([0 1.1 * Iter])
		ylim([0, 1.1])
    
	% Hypervolume
    subplot(Graphics.m, Graphics.n, Graphics.p(4))
	
        plot(V, MFEA.Metrics.Metaheuristic.OTF(:,4), '--*')
            
        legendText = ["On the Fly"];
		
        if (MFEA.Updates.N)
            hold on
            plot(Vu, MFEA.Metrics.Metaheuristic.Updated(:,4), '-.')
            legendText = [legendText, "Updated"];
        end          

%         % Add Legend
%         if (numel(legendText) > 1)
%             legend(legendText, 'Location', 'best');
%         end
		
        ylabel('Hypervolume')
        xlabel('Iteration')
        xlim([0 1.1 * Iter])
		ylim([0, 1.1])
    
% 	% Kernel
%     subplot(Graphics.m, Graphics.n, Graphics.p(5))
% 	
%         plot(V, MFEA.Metrics.Metaheuristic.OTF(:,5), '--*')
%             
%         legendText = ["On the Fly"];
% 		
%         if (MFEA.Updates.N)
%             hold on
%             plot(Vu, MFEA.Metrics.Metaheuristic.Updated(:,5), '-.')
%             legendText = [legendText, "Updated"];
%         end          
% 
% %         % Add Legend
% %         if (numel(legendText) > 1)
% %             legend(legendText, 'Location', 'best');
% %         end
% 		
%         ylabel('Kernel')
%         xlabel('Iteration')
%         xlim([0 1.1 * Iter])

end

