function [] = OutputResults(Parent, JxParent, ExtJxParent, MFEA, Database, Config)

	% Ajust precision
    X = RoundM(Parent, Config.Domain.Precision);

    % Remove dupes
    [~, ia] = unique(X, 'rows');
    X       = X(ia,:);
    FXs     = JxParent(ia,:);
    ExtFXs  = ExtJxParent(ia,:);
    
    % Truncate Population: Rank solutions
    [ParetoSet_s, ParetoFront_s, rank, ~, index] = truncate(X, FXs, Config.Metaheuristic.Size);   
    ParetoExtFront_s = ExtFXs(index,:);
    
    % Pareto
    Pareto_Index_s   = find(rank == 1);
    ParetoSet_s      = ParetoSet_s(Pareto_Index_s,:);
    ParetoFront_s    = ParetoFront_s(Pareto_Index_s,:);
    ParetoExtFront_s = ParetoExtFront_s(Pareto_Index_s,:);
    
    % Evaluate Training Points
	[FX, ~, ~, ExtFX] = CostFunction(X, Database, Config);
    
    % Truncate Population: Rank solutions
    [ParetoSet, ParetoFront, rank, ~, index] = truncate(X, FX, Config.Metaheuristic.Size);      
    ParetoExtFront = ExtFX(index,:);
    
    % Pareto
    Pareto_Index   = find(rank == 1);
    ParetoSet      = ParetoSet(Pareto_Index,:);
    ParetoFront    = ParetoFront(Pareto_Index,:);
    ParetoExtFront = ParetoExtFront(Pareto_Index,:);
    
    % Plot Setup
    f(2) = figure('units','normalized','outerposition',[0 0 1 1]);
    
    if (Config.Objectives.Number == 3)
        
        subplot(1,4,1)
        scatter3(FXs(:,1), FXs(:,2), FXs(:,3), 'MarkerEdgeColor','k', 'MarkerFaceColor',[0 .75 .75]);
        title(sprintf('Model Function - N = %d', size(FXs, 1)))                        
        xlabel(Config.Objectives.Label(1));
        ylabel(Config.Objectives.Label(2));
        zlabel(Config.Objectives.Label(3));
        
        subplot(1,4,2)      
        scatter3(ParetoFront_s(:,1), ParetoFront_s(:,2), ParetoFront_s(:,3), 'MarkerEdgeColor','k', 'MarkerFaceColor',[0 .75 .75]); 
        title(sprintf('Model Pareto Front - N = %d', size(ParetoFront_s, 1)))                        
        xlabel(Config.Objectives.Label(1));
        ylabel(Config.Objectives.Label(2));
        zlabel(Config.Objectives.Label(3));
        
        subplot(1,4,3)
        scatter3(FX(:,1), FX(:,2), FX(:,3), 'MarkerEdgeColor','k', 'MarkerFaceColor',[0 .75 .75]);
        title(sprintf('Real Function - N = %d', size(FX, 1)))                        
        xlabel(Config.Objectives.Label(1));
        ylabel(Config.Objectives.Label(2));
        zlabel(Config.Objectives.Label(3));
        
        subplot(1,4,4)      
        scatter3(ParetoFront(:,1), ParetoFront(:,2), ParetoFront(:,3), 'MarkerEdgeColor','k', 'MarkerFaceColor',[0 .75 .75]); 
        title(sprintf('Real Pareto Front - N = %d', size(ParetoFront, 1)))                        
        xlabel(Config.Objectives.Label(1));
        ylabel(Config.Objectives.Label(2));
        zlabel(Config.Objectives.Label(3));
        
    elseif (Config.Objectives.Number == 2)
        
        subplot(1,4,1)
        scatter(FXs(:,1), FXs(:,2), 'MarkerEdgeColor','k', 'MarkerFaceColor',[0 .75 .75]);
        title(sprintf('Model Function - N = %d', size(FXs, 1)))
        % ylim([30 100]);
        % xlim([-10 0]);            
        xlabel(Config.Objectives.Label(1));
        ylabel(Config.Objectives.Label(2));
        
        subplot(1,4,2)
        scatter(ParetoFront_s(:,1), ParetoFront_s(:,2), 'MarkerEdgeColor','k', 'MarkerFaceColor',[0 .75 .75]);
        title(sprintf('Model Pareto Front - N = %d', size(ParetoFront_s, 1))) 
        % ylim([30 100]);
        % xlim([-10 0]);            
        xlabel(Config.Objectives.Label(1));
        ylabel(Config.Objectives.Label(2));
        
        subplot(1,4,3)
        scatter(FX(:,1), FX(:,2), 'MarkerEdgeColor','k', 'MarkerFaceColor',[0 .75 .75]);
        title(sprintf('Real Function - N = %d', size(FX, 1)))
        % ylim([30 100]);
        % xlim([-10 0]);            
        xlabel(Config.Objectives.Label(1));
        ylabel(Config.Objectives.Label(2));
        
        subplot(1,4,4)
        scatter(ParetoFront(:,1), ParetoFront(:,2), 'MarkerEdgeColor','k', 'MarkerFaceColor',[0 .75 .75]);
        title(sprintf('Real Pareto Front - N = %d', size(ParetoFront, 1))) 
        % ylim([30 100]);
        % xlim([-10 0]);            
        xlabel(Config.Objectives.Label(1));
        ylabel(Config.Objectives.Label(2));
        
    end
    
    hash = char(datetime('now','Format','yyyy-MM-dd-HH-mm-ss'));
    
    eval(sprintf('save(''data_%s.mat'',''MFEA'', ''Config'');', hash));
    eval(sprintf('savefig(f(2),''plot_%s.fig'');', hash));

end