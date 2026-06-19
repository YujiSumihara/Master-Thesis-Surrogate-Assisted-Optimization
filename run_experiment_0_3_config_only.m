function Config = run_experiment_0_3_config_only()

    % Plot
    Config.Graphic = struct();
        % .Flag
        Config.Graphic.Flag = false;
        % .Objectives Lower Limit
        Config.Graphic.Objectives.Lower = [-10, 20];
        % .Objectives Upper Limit
        Config.Graphic.Objectives.Upper = [0, 100];
        % .Extended Objectives Lower Limit
        Config.Graphic.ExtObjectives.Lower = -0.1;
        % .Extended Objectives Upper Limit
        Config.Graphic.ExtObjectives.Upper = 0.5;
    
    % Iteration
    Config.Iter = struct();
        % .Maximum Number of Iteration
        Config.Iter.Max = 200; %600
        
    % Operation
    Config.Operation = struct();
        % .Problem:
        % ..0: example
        % ..1: aluminium-profile  
        % ..2: coffee-table 
        % ..3: heatsink   
        % ..4: knee-coupling
        Config.Operation.Problem = 0;
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
        Config.Operation.Mode = 'REAL'; %'Real' 'BENCHMARK'
    
    % Objectives: Cost Functions used by the Optimization Algorithm
    Config.Objectives = struct();
        % .Number
        Config.Objectives.Number      = 2;
        % .Label
        Config.Objectives.Label       = ["- Safety Factor"; "Mass"];
        % .Unit
        Config.Objectives.Unit        = [""; "g"];
        % .Scale Factor
        Config.Objectives.ScaleFactor = [1, 1e3];
        % .Image Lower Bound
        Config.Objectives.Image.Lower = [-inf, 0];
        % .Image Upper Bound
        Config.Objectives.Image.Upper = [0, inf];
        
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
        Config.Restriction.Flag  = false;
        % .Objectives Lower Bound
        Config.Restriction.Lower = [-2, 30];
        % .Objectives Upper Bound
        Config.Restriction.Upper = [-7, 70];
        % .Penalty  
        % ..1: Addictive      [Independent]
        % ..2: Multiplicative [Independent]  
        % ..3: Addictive
        % ..4: Multiplicative
        Config.Restriction.Penalty = [2, 2];
        % .Weight  
        Config.Restriction.Weight  = [0.3, 1.7];
    
    % Normalization
    Config.Normalization = struct();
        % .Objectives Minimum
        Config.Normalization.Minimum = [-10, 0]; %[0,0]
        % .Objectives Maximum
        Config.Normalization.Maximum = [-1, 100]; %[-10,100]
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
        Config.Dimension.Number = 4;
        % .Label
        Config.Dimension.Label  = ["H1"; "R1"; "X"; "Y"];
        % .Unit
        Config.Dimension.Unit   = ["mm"; "mm"; "mm"; "mm"];  
        % .Type
        % ..0: Addictive (Volume)
        % ..1: Subtractive (Volume)
        % ..2: Position
        % ..3: Boolean
        %Config.SpaceSearch.Type = [0, 1, 2, 2];
    
    % Domain
    Config.Domain = struct();
        % .Lower Bound
        Config.Domain.Initial   = [2, 5, 17, 17];
        % .Upper Bound
        Config.Domain.Final     = [5, 15, 115, 28];
        % .Precision
        % ..0: [1,                   2]     N = 2
        % ..1: [1.0,  1.1,  .. 1.9,  2.0]   N = 11
        % ..2: [1.00, 1.01, .. 1.99, 2.00]  N = 101
        Config.Domain.Precision = [0, 0, 0, 0];
        % .Limit of Feasible Solutions
        Config.Domain.Limit     = 150000; %500000
        
    % Space Filling
    Config.SpaceFilling = struct();
        % .Type
        % ..1: Fill AVG
        % ..2: Fill N-Sphere
        % ..3: Fill Tri (2D only)
        Config.SpaceFilling.Strategy    = 1;    
        % .
        Config.SpaceFilling.Loop        = 3;
        % .
        Config.SpaceFilling.Nadd        = 2;
        % .
	    Config.SpaceFilling.lower_bound = Config.Domain.Initial;
        % .
	    Config.SpaceFilling.upper_bound = Config.Domain.Final;
        % .
        Config.SpaceFilling.deep_level  = 2;
        % .
        Config.SpaceFilling.behavior    = 1;
        % .
        Config.SpaceFilling.grid        = 2;
        % .
        Config.SpaceFilling.D_factor    = 1;
        % .
        Config.SpaceFilling.R_factor    = 1;
    
    % Surrogates
    Config.Surrogates = struct();
        % .Number of Tranning Points (Min: 5, Recommended: 15)
        Config.Surrogates.Initial   = 15;
        % .Maximum Number of Tranning Points
        Config.Surrogates.Limit     = 250; %250
        % .Population Seed
        Config.Surrogates.Seed.Flag = true;
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
        Config.Surrogates.Update.Curve = 4;
        % .Padding
        Config.Surrogates.Padding  = 0.2;
        % Proof of Concept (Run Real Fx in the background - REALLY SLOW)
        Config.Surrogates.PoC      = false; %true %ainda não implementado
        
    % Proof of Concept (Run Real Fx in the background - REALLY SLOW)
    Config.PoC = struct();
        % Flag
        Config.PoC.Flag = false; %true
        % Frequency
        Config.PoC.Frequency = 50;
        % Grid Number of Intermidiate Points
        Config.PoC.Grid = 1; %4
    
    % Metaheuristic: Mode
    Config.Metaheuristic = struct();
        % Population Size
        Config.Metaheuristic.Size          = 30; %30
        % .Population Seed
        Config.Metaheuristic.Seed.Flag     = true;
        % .Population Seed File
        Config.Metaheuristic.Seed.File     = sprintf('./seed/%d/metaheuristic_%d.mat' , Config.Operation.Problem, Config.Metaheuristic.Size);
        % Scaling Factor
        Config.Metaheuristic.ScalingFactor = 0.5;
        % CrossOver Probability
        Config.Metaheuristic.CrossOver     = 0.2;
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
        
        
    % Material Mechanical Properties
    Config.Material = struct();
        % .Tensile Yield Strength (Mpa)
        Config.Material.TensileYieldStrength = 280;
        
    % ANSYS
    Config.Ansys = struct();
        % .Workbench Project
        Config.Ansys.Project     = "Example";
        % .Number of Parameters
        Config.Ansys.NumberOfParameters = 20;
        % .Output Format
        Config.Ansys.OutputFormat       = "%d,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f";
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
    
    % Database
    Config.Database = struct();
        % .Overwrite Existing Database
        Config.Database.Overwrite = false;
        % .Filename
        Config.Database.Filename  = 'Example_debug.mat';
        % .Path
        Config.Database.Path      = './database/' + Config.Ansys.Project + '/';
    
    % Experiment Hash
    Config.Hash = char(datetime('now','Format','yyyy-MM-dd-HH-mm-ss'));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Optimization
    %MFEA(Config);
    
    % Fix Database
    %Fix(Config);
    
    % Process Database Solution
    %SweepDomain(10, 500, Config)
end
