function [] = PlotProgress3(Iter, Pareto, MFEA, Config)

    %% Select Figure
    figure(1);
    clf('reset');
    
    % Subplot Dimensions
    Graphics = struct();
    Graphics.m = 4;
    Graphics.n = 6;
    
    % Pareto Set
    Graphics.p = [1:5];
    %Graphics.p = [1:4];
    PlotPopulation(Graphics, Pareto, Config);  
    
    % Pareto Front
    Graphics.p = [6, 7, 12, 13, 18, 19, 24, 25];
    %Graphics.p = [5, 6, 11, 12, 17, 18, 23, 24];
    PlotParetoFront(Graphics, Iter, Pareto, Config);    
        
    % Objectives
    Graphics.p = [8:10];
    %Graphics.p = [7:9];
    PlotObjectives(Graphics, Pareto, Config);
    
    % Extended Objectives
    Graphics.p = [11];
    %Graphics.p = [10];
    PlotExtObjectives(Graphics, Pareto, Config);
    
    % Optimization Metrics
    Graphics.p = [14:17];
    %Graphics.p = [13:16];
    PlotOptMetrics(Graphics, Iter, MFEA, Config);
    
    % Model Metrics
    Graphics.p = [20:23];
    %Graphics.p = [19:22];
    PlotModelMetrics(Graphics, Iter, MFEA, Config);

	%% Force graphic update
    drawnow
	
end