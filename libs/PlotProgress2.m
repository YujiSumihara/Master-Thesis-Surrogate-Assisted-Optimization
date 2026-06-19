function [] = PlotProgress2(Data, MFEA, Config)

    %% Figure 1
    figure(1);
    clf('reset');
    
    % Compare
    Outdated = size(Data.JXs, 1) > 0;
    
    % Plot: Number of Columns
    Nc = 6;
    % Plot: Number of rows
    Nr = 3;
    
    % Proof of Concept
    if (Config.Surrogates.PoC)
        % Plot: Number of rows
        Nr = 4;            
    end
    
    % Population Vector
    Vp = 1:Data.Np;
		
	%% Objectives    
    for i=1:Config.Objectives.Number

        subplot(Nr, Nc, i)
        
            legendText = [];
    
            if (Config.Objectives.Image.Lower(i) ~= Inf && Config.Objectives.Image.Lower(i) ~= -Inf)
                plot(Vp, ones(Data.Np, 1) * Config.Objectives.Image.Lower(i), '.-')
                hold on
                legendText = [legendText, "LB"];
            end

            if (Config.Objectives.Image.Upper(i) ~= Inf && Config.Objectives.Image.Upper(i) ~= -Inf)
                plot(Vp, ones(Data.Np, 1) * Config.Objectives.Image.Upper(i), '.-')
                hold on
                legendText = [legendText, "UB"];
            end
        
            if (Outdated)
                plot(Vp, Data.FXs(:,i), '--x', Vp, Data.JXs(:,i), '-.')
                legendText = [legendText, "Updated", "Old"];
            else
                plot(Vp, Data.FXs(:,i), '--x')
            end
            
            if (numel(legendText))
                legend(legendText, 'Location', 'best');
            end
			
            if (Config.Objectives.Unit(i) == "")
                ylabel(sprintf('%s', Config.Objectives.Label(i))) 
            else
                ylabel(sprintf('%s (%s)', Config.Objectives.Label(i), Config.Objectives.Unit(i)))                 
            end
			
            xlabel('Population')
            %xlim([1 Data.Np])

    end	
	
	%% ExtObjectives
    for i=1:Config.ExtObjectives.Number

        subplot(Nr, Nc, i + Config.Objectives.Number)
        
            legendText = [];
    
            if (Config.ExtObjectives.Image.Lower(i) ~= Inf && Config.ExtObjectives.Image.Lower(i) ~= -Inf)
                plot(Vp, ones(Data.Np, 1) * Config.ExtObjectives.Image.Lower(i), '.-')
                hold on
                legendText = [legendText, "LB"];
            end

            if (Config.ExtObjectives.Image.Upper(i) ~= Inf && Config.ExtObjectives.Image.Upper(i) ~= -Inf)
                plot(Vp, ones(Data.Np, 1) * Config.ExtObjectives.Image.Upper(i), '.-')
                hold on
                legendText = [legendText, "UB"];
            end
        
            if (Outdated)
                plot(Vp, Data.ExtFXs(:,i), '--x', Vp, Data.ExtJXs(:,i), '-.')
                legendText = [legendText, "Updated", "Old"];
            else
                plot(Vp, Data.ExtFXs(:,i), '--x')
            end
            
            if (numel(legendText))
                legend(legendText, 'Location', 'best');
            end
			
            if (Config.ExtObjectives.Unit(i) == "")
                ylabel(sprintf('%s [EXT]', Config.ExtObjectives.Label(i))) 
            else
                ylabel(sprintf('%s (%s) [EXT]', Config.ExtObjectives.Label(i), Config.ExtObjectives.Unit(i)))                 
            end
			
            xlabel('Population')
            %xlim([1 Data.Np])

    end
    
    %% Pareto Front
    subplot(Nr,Nc,[5,6,11,12])
    
		% 3D
        if (Config.Objectives.Number == 3)
            
            if (Outdated)
                scatter3(Data.JXs(:,1), Data.JXs(:,2), Data.JXs(:,3), 'MarkerEdgeColor','k', 'MarkerFaceColor',[0 .75 .75]);
                hold on
                scatter3(Data.FXs(:,1), Data.FXs(:,2), Data.FXs(:,3), 'MarkerEdgeColor','k', 'MarkerFaceColor',[1 0 0]);
                legend('Outdated', 'Actual', 'Location', 'best')
            else
                scatter3(Data.FXs(:,1), Data.FXs(:,2), Data.FXs(:,3), 'MarkerEdgeColor','k', 'MarkerFaceColor',[0 .75 .75]);
            end
            
            title(sprintf('MODE: Iteration #%d', Data.Iter))            
            
            xlabel(Config.Objectives.Label(1))
            ylabel(Config.Objectives.Label(2))
            zlabel(Config.Objectives.Label(3))
            
            xlim([Config.Normalization.Minimum(1), Config.Normalization.Maximum(1)])
            ylim([Config.Normalization.Minimum(2), Config.Normalization.Maximum(2)])
            zlim([Config.Normalization.Minimum(3), Config.Normalization.Maximum(3)])
            
		% 2D or 2.5D
        elseif (Config.Objectives.Number == 2)
            
            if (Outdated)
                scatter(Data.JXs(:,1), Data.JXs(:,2), 'MarkerEdgeColor','k', 'MarkerFaceColor',[0 .75 .75]);
                hold on
                scatter(Data.FXs(:,1), Data.FXs(:,2), 'MarkerEdgeColor','k', 'MarkerFaceColor',[1 0 0]);
                legend('Outdated', 'Actual', 'Location', 'best')
            else
                scatter(Data.FXs(:,1), Data.FXs(:,2), 'MarkerEdgeColor','k', 'MarkerFaceColor',[0 .75 .75]);
            end
            
            title(sprintf('MODE: Iteration #%d', Data.Iter))
            
            xlabel(Config.Objectives.Label(1))
            ylabel(Config.Objectives.Label(2))
          
            xlim([Config.Normalization.Minimum(1), Config.Normalization.Maximum(1)])
            ylim([Config.Normalization.Minimum(2), Config.Normalization.Maximum(2)])
            
        end	
        
    %% Optimization Metrics
    
    % Number of Metrics
    Nm = size(MFEA.Metric, 1);
    
    % Number of Updated Metrics
    Num = size(MFEA.MetricUpdated, 1);

    % Metrics Vector
    Vm = 1:Nm;

    % Updated Metrics Vector
    Vum = 1:Num;
    
	% Cardinality
    subplot(Nr, Nc, 7)
	
        plot(Vm, MFEA.Metric(:,1), '--')
		
        if Num > 0
		
			hold on        
			plot(Vum, MFEA.MetricUpdated(:,1), '-.')
			legend('On the Fly', 'Updated', 'Location', 'best')
			
        end
		
        ylabel('Cardinality')
        xlabel('Iteration')
        xlim([0 Data.Iter])
		ylim([0, 1.1 * Config.Metaheuristic.Size])
    
	% Spacing
    subplot(Nr, Nc, 8)
	
        plot(Vm, MFEA.Metric(:,2), '--')
		
        if Num > 0
			
			hold on        
			plot(Vum, MFEA.MetricUpdated(:,2), '-.')
			legend('On the Fly', 'Updated', 'Location', 'best')
		
        end
		
        ylabel('Spacing')
        xlabel('Iteration') 
        xlim([0 Data.Iter])  
		
	% Hypervolume
    subplot(Nr, Nc, 9)
	
        plot(Vm, MFEA.Metric(:,3), '--')
		
        if Num > 0
			
			hold on        
			plot(Vum, MFEA.MetricUpdated(:,3), '-.')
			legend('On the Fly', 'Updated', 'Location', 'best')
		
        end
		
        ylabel('Hypervolume')
        xlabel('Iteration')
        xlim([0 Data.Iter])

	% Kernel
    subplot(Nr, Nc, 10)
	
        plot(Vm, MFEA.Metric(:,4), '--')
		
        if Num > 0
			
			hold on        
			plot(Vum, MFEA.MetricUpdated(:,4), '-.')
			legend('On the Fly', 'Updated', 'Location', 'best')
		
        end
		
        ylabel('Kernel')
        xlabel('Iteration')
        xlim([0 Data.Iter])	

	%% Surrogate Metrics
    
    % Number of Metrics
    Nu = size(MFEA.Updates, 1);
    
    % Update Vector
    Vu = 1:Nu;
    
    % Iteration Vector
    Vi = 1:Data.Iter;
		
	% Violations
	subplot(Nr, Nc, 13)
	
        plot(Vi, MFEA.Violation, '--')
        hold on
        plot(Vi, MFEA.ViolationAcc, '.-')
        plot(Vi, movmean(MFEA.Violation,5), ':k')
        
        ylabel('Number of Violation')
        xlabel('Iteration')
        legend('Iter', 'Acc', 'Mov', 'Location', 'best')
        xlim([0 Data.Iter])
	
	% Fx Evaluations
	subplot(Nr, Nc, 14)
	
        plot(MFEA.Evaluations(:,1), MFEA.Evaluations(:,2), '-')
		hold on
		plot(MFEA.Evaluations(:,1), MFEA.Evaluations(:,3), '--')

        ylabel('Fx Evaluations')
        xlabel('Iteration')
        legend('Total', 'Recovery', 'Location', 'best')
        xlim([0 Data.Iter])     

	% Space Filling
    subplot(Nr, Nc, 15)
	
        plot([0, Vu], MFEA.SpaceFilling(:,1), '--x')
        ylabel('Space Filling')
        xlabel('Update')
        xlim([0 Nu+1])  
        
    if (Nu > 0)
        
        % Updates
        subplot(Nr, Nc, 16)

            plot(MFEA.Updates, Vu, '-*')

            ylabel('Update')
            xlabel('Iteration')
            xlim([0 max(MFEA.Updates)])  
        
        % Error RMS
        subplot(Nr, Nc, 17)
		
        if (Config.Objectives.Number == 3)
		
            plot(Vu, MFEA.Error.RMS(:,1) * 100, '--x')
			hold on
			plot(Vu, MFEA.Error.RMS(:,2) * 100, '-.d')
			plot(Vu, MFEA.Error.RMS(:,3) * 100, '-*')
			
            legend(Config.Objectives.Label(1), Config.Objectives.Label(2), Config.Objectives.Label(3), 'Location', 'best')
        
        elseif (Config.Objectives.Number == 2 && Config.ExtObjectives.Operation)
		
            plot(Vu, MFEA.Error.RMS(:,1) * 100, '--x')
			hold on
			plot(Vu, MFEA.Error.RMS(:,2) * 100, '-.d')
			plot(Vu, MFEA.Error.RMS(:,3) * 100, '-*')
			
            legend(Config.Objectives.Label(1), Config.Objectives.Label(2), Config.ExtObjectives.Label(1), 'Location', 'best')
        
        else
        
			plot(Vu, MFEA.Error.RMS(:,1) * 100, '--x')
			hold on
			plot(Vu, MFEA.Error.RMS(:,2) * 100, '-.d')
            
			legend(Config.Objectives.Label(1), Config.Objectives.Label(2), 'Location', 'best')
        
		end
        
		ylabel('PF Error RMS_{max} (%)')
        xlabel('Update')
        xlim([0 Nu]) 
        
        % Error NORM
        subplot(Nr, Nc, 18)
		
%         plot(MFEA.Updates, MFEA.Error.NORM(:,1), '--x')
%         hold on
%         plot(MFEA.Updates, MFEA.Error.NORM(:,2), '-.d')
%         plot(MFEA.Updates, MFEA.Error.NORM(:,3), '-*')
%         plot(MFEA.Updates, MFEA.Error.NORM(:,4), '-.p')
% 
%         legend('Min', 'Med', 'Mean', 'Max', 'Location', 'best')
		
            plot(Vu, MFEA.Error.NORM(:,3), '-*')
            hold on
            plot(Vu, MFEA.Error.NORM(:,4), '-.p')

            legend('Mean', 'Max', 'Location', 'best')
        
            ylabel('PF Error NORM')
            xlabel('Update')
            xlim([0 Nu])
			
    end
    
    %% Proof of Concept
    if (Config.Surrogates.PoC && size(MFEA.PoC.Iter, 1) > 0)
        
        % Cardinality
        subplot(Nr, Nc, 19)

            plot(MFEA.PoC.Iter, MFEA.PoC.Metric(:,1), '--')

            ylabel('Cardinality [Poc]')
            xlabel('Iteration')
            xlim([0 MFEA.PoC.Iter(end)])
            ylim([0, 1.1 * Config.Metaheuristic.Size])

        % Spacing
        subplot(Nr, Nc, 20)

            plot(MFEA.PoC.Iter, MFEA.PoC.Metric(:,2), '--')

            ylabel('Spacing [Poc]')
            xlabel('Iteration') 
            xlim([0 MFEA.PoC.Iter(end)])  

        % Hypervolume
        subplot(Nr, Nc, 21)

            plot(MFEA.PoC.Iter, MFEA.PoC.Metric(:,3), '--')

            ylabel('Hypervolume [Poc]')
            xlabel('Iteration')
            xlim([0 MFEA.PoC.Iter(end)])

        % Kernel
        subplot(Nr, Nc, 22)

            plot(MFEA.PoC.Iter, MFEA.PoC.Metric(:,4), '--')

            ylabel('Kernel [Poc]')
            xlabel('Iteration')
            xlim([0 MFEA.PoC.Iter(end)])       
        
        % Error RMS
        subplot(Nr, Nc, 23)
		
        if (Config.Objectives.Number == 3)
		
            plot(MFEA.PoC.Iter, MFEA.PoC.Error.RMS(:,1) * 100, '--x')
			hold on
			plot(MFEA.PoC.Iter, MFEA.PoC.Error.RMS(:,2) * 100, '-.d')
			plot(MFEA.PoC.Iter, MFEA.PoC.Error.RMS(:,3) * 100, '-*')
			
            legend(Config.Objectives.Label(1), Config.Objectives.Label(2), Config.Objectives.Label(3), 'Location', 'best')
        
        elseif (Config.Objectives.Number == 2 && Config.ExtObjectives.Operation)
		
            plot(MFEA.PoC.Iter, MFEA.PoC.Error.RMS(:,1) * 100, '--x')
			hold on
			plot(MFEA.PoC.Iter, MFEA.PoC.Error.RMS(:,2) * 100, '-.d')
			plot(MFEA.PoC.Iter, MFEA.PoC.Error.RMS(:,3) * 100, '-*')
			
            legend(Config.Objectives.Label(1), Config.Objectives.Label(2), Config.ExtObjectives.Label(1), 'Location', 'best')
        
        else
        
			plot(MFEA.PoC.Iter, MFEA.PoC.Error.RMS(:,1) * 100, '--x')
			hold on
			plot(MFEA.PoC.Iter, MFEA.PoC.Error.RMS(:,2) * 100, '-.d')
            
			legend(Config.Objectives.Label(1), Config.Objectives.Label(2), 'Location', 'best')
        
		end
        
		ylabel('Error RMS_{max} (%) [PoC]')
        xlabel('Iteration')
        xlim([0 MFEA.PoC.Iter(end)]) 
        
        % Error NORM
        subplot(Nr, Nc, 24)
		
            plot(MFEA.PoC.Iter, MFEA.PoC.Error.NORM(:,3), '-*')
            hold on
            plot(MFEA.PoC.Iter, MFEA.PoC.Error.NORM(:,4), '-.p')

            legend('Mean', 'Max', 'Location', 'best')
        
            ylabel('Error NORM [PoC]')
            xlabel('Iteration')
            xlim([0 MFEA.PoC.Iter(end)])    
            
    end    
    
	%% Force graphic update
    drawnow
	
end