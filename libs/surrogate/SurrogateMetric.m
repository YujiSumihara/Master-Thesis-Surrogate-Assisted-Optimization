function [unreliable, recluse, popular, riser, metrics] = SurrogateMetric(x, u, dTrust, dReclusion)

    N  = size(x, 1);
    Ns = size(u, 1);    
    
    % Trust Distance Matrix: 
    %  Distance between the candidate solution and the set of traning points
    trustDistance = zeros(N, Ns);            

    % Trust Number Matrix
    %  Number of traning points within a dTrust distance to the candidate
    %  solution
    trustNumber = zeros(N, 1);

    for i = 1:N

        for j = 1:Ns
            trustDistance(i, j) = norm(x(i,:) - u(j,:));

        end

        trustNumber(i) = numel(find(trustDistance(i,:) <= dTrust));

    end
        
    %%%%%

    % Identify the set of unreliable candidates
    %unreliableSet_id = find(trustNumber == 0);
    unreliableSet_id = find(trustNumber == min(trustNumber) & trustNumber <= 3);
    unreliableSet    = x(unreliableSet_id,:);
    
    % Identify the minimum distance to a traning point
    unreliableDistance = min(trustDistance(unreliableSet_id,:),[],2);

    % Identify the most unreliable candidate
	unreliable_id = find(unreliableDistance == max(unreliableDistance));         
    unreliable    = unreliableSet(unreliable_id,:);  
    
    %%%%%

    % Neighbors Distance Matrix
    %  Distance between each candidate solution
    neighborsDistance = zeros(N, N);

    % Recluse Distance Matrix
    %  Distance to the closest neighbors
    recluseDistance = zeros(N, 1);  

    % Popular Distance Matrix
    %  Mean distance to the closest unreliable neighbors
    popularDistance = zeros(N, 1);             

    % Popular Number Matrix
    %  Number of candidate solutions within a dReclusion distance to a given candidate solution
    popularNumber = zeros(N, 1);            

    % Improvement Number Matrix
    %  Number of candidate solutions that are unreliable within a dReclusion distance to a given candidate solution
    improvementNumber = zeros(N, 1);

    for i = 1:N

        for j = 1:N
            
            % Ignore Diagonal
            if (i ~= j)
                neighborsDistance(i, j) = norm(x(i,:) - x(j,:));
            else
                neighborsDistance(i, j) = 1e10;
            end
            
        end
        
        neighbors_id         = find(neighborsDistance(i,:) <= dReclusion);
                
        popularNumber(i)     = numel(neighbors_id);     
        
        neighborsTrust       = trustNumber(neighbors_id,:);
 
        %unrealibleNeighbors  = find(neighborsTrust == 0);
        unrealibleNeighbors  = find(neighborsTrust == min(trustNumber) & neighborsTrust <= 3);
                
        improvementNumber(i) = numel(unrealibleNeighbors);
        
        if improvementNumber(i) == 0
            popularDistance(i) = 1e10;
        else
            unrealibleNeighbors_id = neighbors_id(unrealibleNeighbors);
            popularDistance(i)     = mean(neighborsDistance(i, unrealibleNeighbors_id));            
        end
        
    end
        
    %%%%%
    
    % Recluse Distance Matrix
    recluseDistance = min(neighborsDistance, [], 2);
           
    % Identify the most recluse candidates
	recluse_id = find(recluseDistance == max(recluseDistance));
    
    n = min(2, size(recluse_id,1));
    recluse = x(recluse_id(1:n),:);
    
    % Identify the most popular candidates
    popularSet_id = find(popularNumber == max(popularNumber));
    popularSet = x(popularSet_id,:);

    % Identify the most popular candidate
    popular_id = find(popularDistance(popularSet_id) == min(popularDistance(popularSet_id))); 
    
    n = min(2, size(popular_id,1));
    popular = popularSet(popular_id(1:n),:);
    
    % Identify the most riser candidates
    riserSet_id = find(improvementNumber == max(improvementNumber));
    riserSet = x(riserSet_id,:);

    % Identify the most riser candidate
    riser_id = find(popularDistance(riserSet_id) == min(popularDistance(riserSet_id))); 
    
    n = min(2, size(riser_id,1));
    riser = riserSet(riser_id(1:n),:);  
    
    % Metrics
    metrics = [trustNumber, popularNumber, improvementNumber];

end