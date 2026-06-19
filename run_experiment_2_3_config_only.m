%% Ajusta de acordo com o coffe table - só dados
function Config = run_experiment_2_3_config_only()
    Config = struct();
    
    % Plot
    Config.Graphic = struct();
        % .Flag
        Config.Graphic.Flag = false;
        % .Objectives Lower Limit
        Config.Graphic.Objectives.Lower = [-10, 400];
        % .Objectives Upper Limit
        Config.Graphic.Objectives.Upper = [-1, 1500];
        % .Extended Objectives Lower Limit
        Config.Graphic.ExtObjectives.Lower = 0;
        % .Extended Objectives Upper Limit
        Config.Graphic.ExtObjectives.Upper = 1;
    
    % Iteration
    Config.Iter = struct();
        % .Maximum Number of Iteration
        Config.Iter.Max = 200; % 100
        
    % Operation
    Config.Operation = struct();
        % .Problem:
        % ..0: example
        % ..1: aluminium-profile  
        % ..2: coffee-table 
        % ..3: heatsink   
        % ..4: knee-coupling
        Config.Operation.Problem = 2;
        % .Surrogate Metric as Cost Function
        % ..0: None  
        % ..1: Min. Distance Towards Training Points Population
        Config.Operation.SurrogateCostFunction = 0;
        % .Type: [Optimization + Validation] (depends on the problem)
        % ..1: 3D      [Safety Factor, Mass, Deformation]  
        % ..2: 2D      [Safety Factor, Mass]   
        % ..3: 2D + 1D [Safety Factor, Mass] & [Deformation]
        Config.Operation.Type = 3;
        % .Validation Only Numbers
        Config.Operation.Validation = {3};
        Config.Operation.Mode = 'REAL';
        
    % Objectives: Cost Functions used by the Optimization Algorithm
    Config.Objectives = struct();
        % .Number
        Config.Objectives.Number      = 2;
        % .Label
        Config.Objectives.Label       = ["- Safety Factor"; "Mass"];
        % .Unit
        Config.Objectives.Unit        = [""; "g"];
        % .Scale Factor
        Config.Objectives.ScaleFactor = [1, 1e3]; %1000
        % .Image Lower Bound
        Config.Objectives.Image.Lower = [-10, 400];
        % .Image Upper Bound
        Config.Objectives.Image.Upper = [-1, 1500];
        
    % Extended Objectives: Cost Function used by the Validation Process
    Config.ExtObjectives = struct();
        % .Extended Operation
        Config.ExtObjectives.Operation   = true;
        % .Number
        Config.ExtObjectives.Number      = 1;
        % .Label
        Config.ExtObjectives.Label       = "Deformation";
        % .Unit
        Config.ExtObjectives.Unit        = "mm";
        % .Scale Factor
        Config.ExtObjectives.ScaleFactor = 1;
        % .Image Lower Bound
        Config.ExtObjectives.Image.Lower = 0;
        % .Image Upper Bound
        Config.ExtObjectives.Image.Upper = 1;
    
    % Restriction
    Config.Restriction = struct();
        % Flag
        Config.Restriction.Flag  = false;%false
        % .Objectives Lower Bound
        Config.Restriction.Lower = [-2, 300]; %original : 30
        % .Objectives Upper Bound
        Config.Restriction.Upper = [-7, 700]; %original: 70
        % .Penalty  
        % ..1: Addictive      [Independent]
        % ..2: Multiplicative [Independent]  
        % ..3: Addictive
        % ..4: Multiplicative
        Config.Restriction.Penalty = [3, 3];
        % .Weight  
        Config.Restriction.Weight  = [10^3, 10^3]; %1000
    
    % Normalization - Para o Coffe Table, 10 de SF e 400g em relação ao máximo
    % sendo 1 e 3000g. Definidos pelo projetista.
    
    Config.Normalization = struct();
        % .Objectives Minimum
        Config.Normalization.Minimum = [-10, 400]; %safe factor, mass (g)
        % .Objectives Maximum
        Config.Normalization.Maximum = [-1, 1500];
        % .Delta
        Config.Normalization.Delta   = Config.Normalization.Maximum - Config.Normalization.Minimum;
        
    % Ext Normalization
    Config.ExtNormalization = struct();
        % .Objectives Minimum
        Config.ExtNormalization.Minimum = 0;
        % .Objectives Maximum
        Config.ExtNormalization.Maximum = 1;
        % .Delta
        Config.ExtNormalization.Delta   = Config.ExtNormalization.Maximum - Config.ExtNormalization.Minimum;
                
    % Dimensions (Parameters to be Optimized)
    Config.Dimension = struct();
        % .Number
        Config.Dimension.Number = 5;
        % .Label
        Config.Dimension.Label  = ["bar1-pos"; "bar2-left"; "bar2-right"; "bar1-depth"; "bar2-depth"];
        % .Unit
        Config.Dimension.Unit   = ["mm"; "mm"; "mm"; "mm"; "mm"];  
        
    % Domain
    Config.Domain = struct();
        % .Lower Bound
        Config.Domain.Initial   = [20, 0, 0, 0, 0]; %"bar1-pos"; "bar2-left"; "bar2-right"; "bar1-depth"; "bar2-depth"
        % .Upper Bound
        Config.Domain.Final     = [35, 10, 10, 5, 5];
        % .Precision
        % ..0: [1,                   2]     N = 2
        % ..1: [1.0,  1.1,  .. 1.9,  2.0]   N = 11
        % ..2: [1.00, 1.01, .. 1.99, 2.00]  N = 101
        Config.Domain.Precision = [0, 0, 0, 0, 0];
        % .Limit of Feasible Solutions
        Config.Domain.Limit     = 150000;
        
    %% Space Filling (parte 3) (5.1.6 MasterThesis)
    Config.SpaceFilling = struct();
        % .Type
        % ..1: Fill AVG
        % ..2: Fill N-Sphere
        % ..3: Fill Tri (2D only)
        Config.SpaceFilling.Strategy    = 1;    
        % .
        Config.SpaceFilling.Loop        = 3; %3
        % .
        Config.SpaceFilling.Nadd        = 2; %2
        % .
	    Config.SpaceFilling.lower_bound = Config.Domain.Initial;
        % .
	    Config.SpaceFilling.upper_bound = Config.Domain.Final;
        % .
        Config.SpaceFilling.deep_level  = 2; %2
        % .
        Config.SpaceFilling.behavior    = 1;
        % .
        Config.SpaceFilling.grid        = 2; %2
        % .
        Config.SpaceFilling.D_factor    = 1;
        % .
        Config.SpaceFilling.R_factor    = 1;
    
    %% Surrogates (parte 2)
    Config.Surrogates = struct();
        % .Number of Tranning Points (Min: 5, Recommended: 15)
        Config.Surrogates.Initial   = 15; %15
        % .Maximum Number of Training Points
        Config.Surrogates.Limit     = 250; %250 80
        % .Population Seed
        Config.Surrogates.Seed.Flag = true; %true
        % .Population Seed File
        Config.Surrogates.Seed.File = sprintf('./seed/%d/surrogate_%d.mat' , Config.Operation.Problem, Config.Surrogates.Initial);
        % .Initial Traning Points Generation Method
        % ..1: SLHD
        % ..2: RAND
        Config.Surrogates.Method    = 1;
        % .Initial Traning Points Generation Mode
        % ..1: Reference
        % ..2: avg
        % ..3: div
        % ..4: pdiv
        Config.Surrogates.Mode      = 1;
        % .Update Curve
        % ..1: 0 updates
        % ..2: 10 updates
        % ..3: 15 updates
        % ..4: 20 updates
        Config.Surrogates.Update.Curve = 4; % 4
        % .Padding
        Config.Surrogates.Padding  = 0.2;
        % Proof of Concept (Run Real Fx in the background - REALLY SLOW)
        Config.Surrogates.PoC      = false; %true
        
    %% Proof of Concept - REALLY SLOW
    % Create a background grid of points to evaluate the surrogate model
    Config.PoC = struct();
        % Flag
        Config.PoC.Flag = false; %false true
        % Frequency
        Config.PoC.Frequency = 50; %20
        % Grid Number of Intermidiate Points
        Config.PoC.Grid = 1; %1
    
    %% Metaheuristic: Mode
    Config.Metaheuristic = struct();
        % Population Size
        Config.Metaheuristic.Size          = 30; %30
        % .Population Seed
        Config.Metaheuristic.Seed.Flag     = true; %true
        % .Population Seed File
        Config.Metaheuristic.Seed.File     = sprintf('./seed/%d/metaheuristic_%d.mat' , Config.Operation.Problem, Config.Metaheuristic.Size);
        % Scaling Factor
        Config.Metaheuristic.ScalingFactor = 0.5;
        % CrossOver Probability
        Config.Metaheuristic.CrossOver     = 0.2; %0.2
        % .Initial Population Generation Method
        % ..1: SLHD
        % ..2: RAND
        Config.Metaheuristic.Method        = 1;
        % .Initial Population Generation Mode
        % ..1: Reference
        % ..2: avg
        % ..3: div
        % ..4: pdiv
        Config.Metaheuristic.Mode          = 2;
        %Archive Size
        Config.Metaheuristic.ArchiveSize = 30;
        %Size of Leader Pool
        Config.Metaheuristic.LeaderPoolSize = 5; %5

        %% MOEA/D parameters
        Config.Metaheuristic.NeighborSize  = 10;
        Config.Metaheuristic.Decomposition = 'PBI';
        Config.Metaheuristic.PBITheta      = 3.0;
        Config.Metaheuristic.Delta         = 0.90;
        Config.Metaheuristic.Nr            = 2;
        
    %% Material Mechanical Properties
    Config.Material = struct();
        % .Tensile Yield Strength (Mpa)
        Config.Material.TensileYieldStrength = 250;
        
    %% ANSYS
    Config.Ansys = struct();
        % .Workbench Project
        Config.Ansys.Project     = "coffee-table";
        % .Number of Parameters
        Config.Ansys.NumberOfParameters = 21;
        % .Output Format
        Config.Ansys.OutputFormat       = "%d,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f";
        % .Version
        % ..180: 18.0
        % ..181: 18.1
        % ..182: 18.2
        % ..190: 19.0
        % ..191: 19.1
        Config.Ansys.Version     = 191;    
        % .Plataform
        % ..Win32   : Win 32 bits
        % ..Win64   : Win 64 bits
        % ..Linux64 : Linux 64 bits
        Config.Ansys.PlatformOS  = "Win64";
        % .Instalation Path
        Config.Ansys.InstallPath = "D:/Program Files/Ansys Inc";
        % .Number of simulations per batch
        Config.Ansys.BatchNumber = 3;
    
    %% Database
    Config.Database = struct();
        % .Overwrite Existing Database
        Config.Database.Overwrite = false;
        % .Filename
        Config.Database.Filename  = 'database_debug.mat';
        % .Path
        Config.Database.Path      = './database/' + Config.Ansys.Project + '/';
    
    % Experiment Hash
    Config.Hash = char(datetime('now','Format','yyyy-MM-dd-HH-mm-ss'));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Optimization
    %MFEAPSO_Surrogate(Config);
    %MFEAPSO_Surrogate_noChosen(Config)
    
    % Fix Database
    %Fix(Config);
    
    % Process Database Solution
    %SweepDomain(10, 500, Config)
end
