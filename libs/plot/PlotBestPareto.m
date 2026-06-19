function PlotBestPareto(Results, PF_real_global)

    [~, bestMODE]  = min(Results.MODE.IGD);
    [~, bestMOPSO] = min(Results.MOPSO.IGD);

    PF_mode  = Results.MODE.ParetoModel{bestMODE};
    PF_mopso = Results.MOPSO.ParetoModel{bestMOPSO};

    figure;
    plot(PF_real_global(:,1), PF_real_global(:,2), 'k-', 'LineWidth', 2);
    hold on;

    scatter(PF_mode(:,1), PF_mode(:,2), 60, 'filled');
    scatter(PF_mopso(:,1), PF_mopso(:,2), 60, 'filled');

    xlabel('- Safety Factor');
    ylabel('Mass (g)');
    title('Better Pareto frontiers for lower IGD');

    legend('Real Global Pareto', ...
           sprintf('MODE - run %d', bestMODE), ...
           sprintf('MOPSO - run %d', bestMOPSO), ...
           'Location', 'best');

    grid on;

end