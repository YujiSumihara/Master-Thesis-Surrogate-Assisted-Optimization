function [] = PlotBenchmarkProgress(Iter, Pareto, MFEA, Config)

    if isempty(Pareto.Front)
        return;
    end

    %% ===== FIGURA 1: Pareto vs Real =====
    figure(200); clf;

    PF_true = TrueParetoZDT1(500);
    PF_true = NormalizeColumn(PF_true, [0 0], [1 1]);

    plot(PF_true(:,1), PF_true(:,2), 'k-', 'LineWidth', 2);
    hold on;

    scatter(Pareto.Front(:,1), Pareto.Front(:,2), 30, 'filled');

    xlabel('f_1');
    ylabel('f_2');
    title(sprintf('Pareto Front - Iter %d', Iter));
    legend('Pareto Real', 'Aproximado', 'Location', 'best');

    grid on;
    xlim([0 1]);
    ylim([0 1.2]);

    drawnow;

    %% ===== FIGURA 2: Evolução das métricas =====
    figure(201); clf;

    Metrics = MFEA.Metrics.Metaheuristic.OTF;

    if isempty(Metrics)
        return;
    end

    it = 1:size(Metrics,1);

    % Assumindo: [C S NR HV K IGD]
    HV  = Metrics(:,4);

    subplot(1,2,1)
    plot(it, HV, 'LineWidth', 1.5);
    xlabel('Iteração');
    ylabel('HV');
    title('Hypervolume');
    grid on;

    if size(Metrics,2) >= 6
        IGD = Metrics(:,6);

        subplot(1,2,2)
        plot(it, IGD, 'LineWidth', 1.5);
        xlabel('Iteração');
        ylabel('IGD');
        title('IGD');
        grid on;
    end

    drawnow;

end