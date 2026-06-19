function [out] = kernel_metric(X, nadir)

    n = size(X, 1);

    out_d = 0;
    out_n = 0;
    
    for i=1:n
        
        D = norm(nadir - X(i,:));       
        out_n = out_n + [1/D^3];
        
        if (i < n)            
            Di = norm(X(i+1,:) - X(i,:));            
            out_d = out_d + [1/Di];            
        end
    end
    
    out_n = n / (out_n + 1e-10);
    out_d = n / (out_d + 1e-10);
    
    out = out_d / out_n;

end