function [Config] = SetupIndex(Config)

    %% Index
    Config.Index = struct();
    
    % Precision Increment
    Config.Index.Deepness = 10 .^ Config.Domain.Precision;
    
    % Delta
    Config.Domain.Delta = Config.Domain.Final - Config.Domain.Initial;
    
    % Interval Increment
    Config.Index.Weigth = ones(1,Config.Dimension.Number) + Config.Domain.Delta .* Config.Index.Deepness;
    
    % Identify number of possible solution
    Config.Index.Size = GetIndexNumber(Config.Domain.Final, Config);
    
    % Warning
    if (Config.Index.Size > Config.Domain.Limit)
 
        button = questdlg('The maximum number of feasible solutions was exceeded. As such, would you like to refine the search domain?',...
                          'Warning',...
                          'Yes','No',...
                          'Yes');
        
        if (button == "Yes")
        	error('Experiment interrupted!');  
        end       

    end
    
end