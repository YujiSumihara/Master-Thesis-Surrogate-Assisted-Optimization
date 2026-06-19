function [Database] = SetupDatabase(Config)

    % Operation Flag: Turn On
    createDatabase = true;
    
    % Database struct
    Database = struct();

    % Experiment Setting
    Setting = struct();
    Setting.Dimension = Config.Dimension;
    Setting.Domain    = Config.Domain;
    Setting.Material  = Config.Material;
    Setting.Ansys     = Config.Ansys.Project;
        
    %% Load Database    
    if (Config.Database.Overwrite == false && ...
        exist([Config.Database.Path + Config.Database.Filename], 'file') == 2)

        % Load Existing Database
        load([Config.Database.Path + Config.Database.Filename], 'Database');
        
        % Compare Experiment Setting against Loaded Setting
        if (isequaln(Database.Setting, Setting) == false)
            
            button = questdlg('The configuration stored in the database file doesn`t match with the algorithm''s current setting. As such, would you like to verify it by yourself? Otherwise, the mismatched database file will be overwritten.',...
                              'Warning', 'Yes', 'No', 'Yes');

            if (button == "Yes")
                error('Error: Mismatching setting!');            
            end
            
        else
            
            % Operation Flag: Turn Off
            createDatabase = false;
               
            % Log Utilization
            Database.Usage = [string(Database.Usage); string(Config.Hash)];
            
            % Backup Database
            copyfile(char(Config.Database.Path + Config.Database.Filename), ...
                     char(Config.Database.Path + 'backup/' + Config.Hash + ".mat"));
             
        end
    
    end
    
    %% Create Database
    if (createDatabase == true)
        
        % Generate Index
        Database.Index = zeros(Config.Index.Size,1);

        % Generate Data
        Database.Data = struct();
        
        % Populate Data
        for i=1:Config.Index.Size
            Database.Data.([sprintf("D%d", i)]) = struct();
        end
        
        % Append Setting
        Database.Setting = Setting;
               
        % Log Utilization
        Database.Usage = string(Config.Hash);
        
        save([Config.Database.Path + Config.Database.Filename], 'Database');
        
    end

end