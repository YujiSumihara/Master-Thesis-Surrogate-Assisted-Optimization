clc; clear; close all;

    addpath('libs');
    addpath('libs/fill');
    addpath('libs/init');
    addpath('libs/metric');
    addpath('libs/plot');
    addpath('libs/setup');
    addpath('libs/surrogate');
    addpath('libs/strategy');
    addpath('libs/tools');
    addpath('libs/update');

%% Configurações
N   = 30;   % número de pontos
dim = 4;    % exemplo bidimensional

rng(1);     % reprodutibilidade

%% Domínio normalizado
initial   = zeros(1,dim);
final     = ones(1,dim);
precision = ones(1, dim);
iter      = 10;

%% 1) Amostragem aleatória
X_rand = rand(N,dim);

%% 2) SLHD simples
X_slhd = int_SLHD(N,dim);

%% 3) SLHD + AVG usado no trabalho
[X_slhd_avg, metric_avg] = int_SLHD_avg( ...
    N, dim, precision, initial, final, iter);

%% Métricas AVG para comparação
[~, metric_rand, ~, ~] = fill_avg(X_rand,5,precision,initial,final);
[~, metric_slhd, ~, ~] = fill_avg(X_slhd,5,precision,initial,final);

%% Figura comparativa
figure('Position',[100 100 1400 430]);

subplot(1,3,1)
scatter(X_rand(:,1),X_rand(:,2),80,'filled')
xlim([0 1]); ylim([0 1]);
grid on; box on;
xlabel('$x_1$','Interpreter','latex')
ylabel('$x_2$','Interpreter','latex')
title(sprintf('Rand'),'Interpreter','latex')
set(gca,'FontSize',12)

subplot(1,3,2)
scatter(X_slhd(:,1),X_slhd(:,2),80,'filled')
xlim([0 1]); ylim([0 1]);
grid on; box on;
xlabel('$x_1$','Interpreter','latex')
ylabel('$x_2$','Interpreter','latex')
title(sprintf('SLHD'),'Interpreter','latex')
set(gca,'FontSize',12)

subplot(1,3,3)
scatter(X_slhd_avg(:,1),X_slhd_avg(:,2),80,'filled')
xlim([0 1]); ylim([0 1]);
grid on; box on;
xlabel('$x_1$','Interpreter','latex')
ylabel('$x_2$','Interpreter','latex')
title(sprintf('SLHD + AVG'),'Interpreter','latex')
set(gca,'FontSize',12)

sgtitle('Comparison of population startup strategies', ...
    'Interpreter','latex','FontSize',14)

%% Salvar figura
exportgraphics(gcf,'Comparacao_Inicializacao_SLHD_AVG.png','Resolution',300);

fprintf('\nFigure saved as: Comparacao_Inicializacao_SLHD_AVG.png\n');
fprintf('AVG Random    = %.6f\n',metric_rand);
fprintf('AVG SLHD      = %.6f\n',metric_slhd);
fprintf('AVG SLHD+AVG  = %.6f\n',metric_avg);