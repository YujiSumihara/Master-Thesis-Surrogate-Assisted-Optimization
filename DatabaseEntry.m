function [Entry, Param] = DatabaseEntry(k, data, Config)

    Entry = struct();
    
    Entry.Mesh.elements = data(2,k);
    Entry.Mesh.nodes    = data(3,k);

    Entry.Mesh.Metric.min = data(4,k);
    Entry.Mesh.Metric.avg = data(5,k);
    Entry.Mesh.Metric.max = data(6,k);
    Entry.Mesh.Metric.std = data(7,k);

    Entry.Solver.ElapsedTime = data(8,k);
            
    % Problem
    switch Config.Operation.Problem
        
        % ..0: example
        case {0}
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            Entry.Deformation.Total.min = data(9,k);
            Entry.Deformation.Total.avg = data(10,k);
            Entry.Deformation.Total.max = data(11,k);

            Entry.Stress.VonMises.min = data(12,k);
            Entry.Stress.VonMises.avg = data(13,k);
            Entry.Stress.VonMises.max = data(14,k);

            Entry.Solid.Mass   = data(15,k);
            Entry.Solid.Volume = data(16,k);

            Entry.Solid.Parameter.H1 = data(17,k);
            Entry.Solid.Parameter.R1 = data(18,k);
            Entry.Solid.Parameter.X  = data(19,k);
            Entry.Solid.Parameter.Y  = data(20,k);

            Param = data(17:20,k);
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % ..1: aluminium_profile
        case {1}
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        % ..2: coffee_table
        case {2}
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            Entry.Deformation.Total.min = data(9,k);
            Entry.Deformation.Total.avg = data(10,k);
            Entry.Deformation.Total.max = data(11,k);

            Entry.Stress.VonMises.min = data(12,k);
            Entry.Stress.VonMises.avg = data(13,k);
            Entry.Stress.VonMises.max = data(14,k);

            Entry.Solid.Mass   = data(15,k);
            Entry.Solid.Volume = data(16,k);

            Entry.Solid.Parameter.bar1_pos = data(17,k);
            Entry.Solid.Parameter.bar2_left = data(18,k);
            Entry.Solid.Parameter.bar2_right  = data(19,k);
            Entry.Solid.Parameter.bar1_depth  = data(20,k);
            Entry.Solid.Parameter.bar2_depth  = data(21,k);

            Param = data(17:21,k);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        % ..3: heatsink
        case {3}
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        % ..4: knee_coupling
        case {4}
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            Entry.Deformation.Total.min = data(9,k);
            Entry.Deformation.Total.avg = data(10,k);
            Entry.Deformation.Total.max = data(11,k);

            Entry.Stress.VonMises.min = data(12,k);
            Entry.Stress.VonMises.avg = data(13,k);
            Entry.Stress.VonMises.max = data(14,k);

            Entry.Solid.Mass   = data(15,k);
            Entry.Solid.Volume = data(16,k);

            Entry.Solid.Parameter.depth = data(17,k);
            Entry.Solid.Parameter.screw_r = data(18,k);
            Entry.Solid.Parameter.screw_ang  = data(19,k);
            Entry.Solid.Parameter.outer_r  = data(20,k);

            Param = data(17:20,k);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
    end
    
end