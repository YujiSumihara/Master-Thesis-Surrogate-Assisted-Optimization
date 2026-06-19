function [Fx, ExtFx] = CostFunctionSelection(k, Fx, ExtFx, Results, Config)

    % Problem
    switch Config.Operation.Problem
        
        % ..0: example
        % ..1: aluminium-profile
        % ..2: coffee-table
        % ..4: knee-coupling
        case {0, 1, 2, 4}
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Cost Function: Fx
            switch Config.Operation.Type

                % ..1: 3D      [Safety Factor, Mass, Deformation] 
                case {1}               
                    Fx(k,1) = Results.Deformation.Total.max * Config.Objectives.ScaleFactor(1);
                    Fx(k,2) = - Config.Material.TensileYieldStrength / (Results.Stress.VonMises.max * Config.Objectives.ScaleFactor(2));
                    Fx(k,3) = Results.Solid.Mass * Config.Objectives.ScaleFactor(3);

                % ..2: 2D      [Safety Factor, Mass]   
                % ..3: 2D + 1D [Safety Factor, Mass] & [Deformation]
                otherwise                               
                    Fx(k,1) = - Config.Material.TensileYieldStrength / (Results.Stress.VonMises.max * Config.Objectives.ScaleFactor(1)); %fator de segurança
                    Fx(k,2) = Results.Solid.Mass * Config.Objectives.ScaleFactor(2); %massa

            end

            % External Cost Function: ExtFX
            switch Config.Operation.Type

                % ..3: 2D + 1D [Safety Factor, Mass] & [Deformation]
                case {3}                                              
                    ExtFx(k,1) = Results.Deformation.Total.max * Config.ExtObjectives.ScaleFactor(1);

            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        % ..3: heatsink
        case {3}
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
    end
    
end