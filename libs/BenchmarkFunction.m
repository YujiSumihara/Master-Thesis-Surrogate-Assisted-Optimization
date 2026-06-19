function [Fx, ExtFx] = BenchmarkFunction(X, Config)

    N = size(X,1);
    
    Fx    = zeros(N, Config.Objectives.Number);
    ExtFx = zeros(N, Config.ExtObjectives.Number);
    
    switch Config.Benchmark.Function
        
        case 'ZDT1'
            
            n = size(X,2);
            
            for i = 1:N
                
                f1 = X(i,1);
                g  = 1 + 9*sum(X(i,2:end))/(n-1);
                f2 = g * (1 - sqrt(f1/g));
                
                Fx(i,:) = [f1, f2];
                
            end
            
        case 'DTLZ1'
            
            M = Config.Objectives.Number;
            n = size(X,2);
            k = n - M + 1;
            
            for i = 1:N
                
                g = 100*(k + sum((X(i,end-k+1:end)-0.5).^2 - cos(20*pi*(X(i,end-k+1:end)-0.5))));
                
                f = zeros(1,M);
                
                for m = 1:M
                    f(m) = 0.5*(1+g);
                    
                    for j = 1:M-m
                        f(m) = f(m)*X(i,j);
                    end
                    
                    if m > 1
                        f(m) = f(m)*(1 - X(i,M-m+1));
                    end
                end
                
                Fx(i,:) = f;
                
            end
            
    end

end