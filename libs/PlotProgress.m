function [] = PlotProgress(Iter, Pareto, MFEA, Config)

    close all;
    
    %% Figure 1: Subplot Dimensions
    f(1) = figure('units','normalized','outerposition',[0 0 1 1]);
    %f(1) = figure(1);
	Graphics = struct();
    Graphics.m = 1;
    Graphics.n = Config.Dimension.Number;   
    
        % Pareto Set
        Graphics.p = [1:Config.Dimension.Number];
        PlotPopulation(Graphics, Pareto, Config);

        % Force graphic update
        drawnow  
    
    %% Figure 2: Subplot Dimensions
    f(2) = figure('units','normalized','outerposition',[0 0 1 1]);
    %f(2) = figure(2);
	Graphics = struct();
    Graphics.m = 1;
    Graphics.n = 1; 
    
        % Pareto Front
        Graphics.p = [1];
        PlotParetoFront(Graphics, Iter, Pareto, Config);

        % Force graphic update
        drawnow  
    
    %% Figure 3: Subplot Dimensions
    f(3) = figure('units','normalized','outerposition',[0 0 1 1]);
    %f(3) = figure(3);
	Graphics = struct();
    Graphics.m = 1;
    Graphics.n = Config.Objectives.Number + Config.ExtObjectives.Number + 1;     
        
        % Objectives
        Graphics.p = [1:Config.Objectives.Number + 1];
        PlotObjectives(Graphics, Pareto, Config);

        % Extended Objectives
        Graphics.p = [Config.Objectives.Number + 2 : Config.Objectives.Number + Config.ExtObjectives.Number + 1];    
        if Config.ExtObjectives.Number > 0
            Graphics.p = [Config.Objectives.Number + 2 : ...
                            Config.Objectives.Number + Config.ExtObjectives.Number + 1];    
            PlotExtObjectives(Graphics, Pareto, Config);
        end

        % Force graphic update
        drawnow
    
    %% Figure 4: Subplot Dimensions
	f(4) = figure('units','normalized','outerposition',[0 0 1 1]);
    %f(4) = figure(4);
    Graphics = struct();
    Graphics.m = 2;
    Graphics.n = 4; 
    
        % Optimization Metrics
        Graphics.p = [1:4];
        PlotOptMetrics(Graphics, Iter, MFEA, Config);

        % Model Metrics
        Graphics.p = [5:8];
        PlotModelMetrics(Graphics, Iter, MFEA, Config);

        % Force graphic update
        drawnow
	
end