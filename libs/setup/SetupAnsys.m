function [Config] = SetupAnsys(Config)

    % Raiz do projeto MATLAB no momento da configuração
    Config.RootPath = pwd;

    % Arquivos ANSYS com caminho absoluto
    ProjectFile = fullfile(Config.RootPath, 'ansys', char(Config.Ansys.Project), ...
        [char(Config.Ansys.Project) '.wbpj']);

    ScriptingFile = fullfile(Config.RootPath, 'ansys', char(Config.Ansys.Project), ...
        'interface.py');

    % Executável do Workbench
    RunWB2 = fullfile(char(Config.Ansys.InstallPath), ...
        ['v' num2str(Config.Ansys.Version)], ...
        'Framework', 'bin', char(Config.Ansys.PlatformOS), ...
        'runwb2.exe');

    % Argumentos
    Arguments = ['-B -F "' ProjectFile '" -R "' ScriptingFile '" -X'];

    % Comando final
    Config.Ansys.ExecutionCommand = ['"' RunWB2 '" ' Arguments];

end