function [data, simulationTime, setupTime] = ANSYS(N, Config)

    fprintf('\n============================\n');
    fprintf('Calling ANSYS...\n');
    %fprintf('%s\n', Config.Ansys.ExecutionCommand);
    %fprintf('============================\n');

    tic;

    outputPath = fullfile(Config.RootPath, 'ansys', char(Config.Ansys.Project), 'output.txt');

    if exist(outputPath, 'file') == 2
        delete(outputPath);
    end

    [status, cmdout] = system(Config.Ansys.ExecutionCommand);
    %disp(status)
    %disp(cmdout)

    if status ~= 0
        error("ANSYS execution failed:\n%s", cmdout);
    end

    if exist(outputPath, 'file') ~= 2
        error("ANSYS output.txt was not created.");
    end

    outputFile = fopen(outputPath, 'r');

    if outputFile < 0
        error("Could not open ANSYS output.txt.");
    end

    dataFormat = Config.Ansys.OutputFormat;
    dataSize = [Config.Ansys.NumberOfParameters N];

    data = fscanf(outputFile, dataFormat, dataSize);
    fclose(outputFile);

    if ~isequal(size(data), dataSize)
        error("Simulation failed or output size mismatch. Expected [%d %d], got [%d %d].", ...
              dataSize(1), dataSize(2), size(data,1), size(data,2));
    end

    endTime = toc;

    simulationTime = sum(data(8,:));
    setupTime = endTime - simulationTime;

end