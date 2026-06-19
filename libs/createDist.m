function [PopDist] = createDist(N, dim, method, mode)
    
    if dim > 10
        PopDist = rand(N,dim);
        return;
    end
    
    switch method
        
        %% SLHD-based Distribution
        case 1

            switch mode
                % Mode: reference
                case 1
                    PopDist = int_SLHD(N, dim);  
                % Mode: avg
                case 2
                    PopDist = int_SLHD_avg(N, dim);  
                % Mode: div
                case 3
                    PopDist = int_SLHD_div(N, dim);  
                % Mode: pdiv
                case 4
                    PopDist = int_SLHD_pdiv(N, dim);
            end
        
        %% RAND-based Distribution
        case 2

            switch mode
                % Mode: reference
                case 1
                    PopDist = rand(N, dim);  
                % Mode: avg
                case 2
                    PopDist = int_RAND_avg(N, dim);  
                % Mode: div
                case 3
                    PopDist = int_RAND_div(N, dim);  
                % Mode: pdiv
                case 4
                    PopDist = int_RAND_pdiv(N, dim);
            end
      
    end
    
end