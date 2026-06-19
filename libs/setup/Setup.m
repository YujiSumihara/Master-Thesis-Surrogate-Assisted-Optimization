function [MFEA, Database, Config] = Setup(Config)

    if Config.Operation.Problem >= 5   % benchmark
        
        % NÃO usa index
        % NÃO usa ANSYS
        % NÃO usa database real
        Database = [];
        Config.Domain.Delta = Config.Domain.Final - Config.Domain.Initial;
        [MFEA, Database] = SetupSurrogate([], Config);
        
    else


    %% INDEX
    [Config] = SetupIndex(Config); %% Precisão ,Delta, Intervalo incremental, número de soluções possíveis.

    %% ANSYS
    [Config] = SetupAnsys(Config); %% configura o caminho e dados para o ANSYS

    %% Database
    Database = SetupDatabase(Config); %% Salva os dados utilizados como base inicial
    
    %% Surrogate Data
    [MFEA, Database] = SetupSurrogate(Database, Config);
    end
end