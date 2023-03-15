clc
clear all
close all
addpath(genpath('./read_data'));
addpath(genpath('./CrowdBT'));
addpath(genpath('./CoarsenRank'));
addpath(genpath('./CoarsenBT'));
addpath(genpath('./CoarsenTH'));
addpath(genpath('./LBFGS_PL'));
addpath(genpath('./LBFGS_BT'));
addpath(genpath('./L-BFGS-B'));
addpath(genpath('./PeerGrading'));

load('sushi.mat')
color = {'g', 'm', 'm--', 'g--', 'b--', 'r--', 'k', 'b', 'r', 'c'};
legend_cell = {};
res_idx = 1;
%% parameter initialization
n_anno = max(data(:,1));                 % the number of worker
n_obj = max(max(data(:,2:end)));           % the number of onjects

M = 5;  % go through the whole data M times for online algorithms
online_para = struct('c', 0.1, 'kappa', 1e-4, 'taylor', 1);  % taylor = 1 because we empoly taylor expansion

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Sample Level Correction methods %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% CorwdBT Online
mu = zeros( n_obj, 1); % initial parameters for scores
sigma = ones( n_obj, 1);  

a = [5,1];  %the unified initialization for all worker 
alpha = repmat(a, n_anno, 1);

CrowdBT_auc = CrowdBT(data, ground_truth, mu, sigma, alpha, M, online_para);
plot(CrowdBT_auc, color{res_idx},'LineWidth',2)
legend_cell{res_idx} = 'CrowdBT-Online';
hold on;
res_idx = res_idx + 1;

%% PeerGrading PL
mu = rand( n_obj, 1); % initial parameters for scores
theta = textread('Sushi_docscores.txt');
mu(theta(:,1)) = theta(:,2);
PeerGrading_PL_auc = calc_auc(ground_truth, mu);
plot(xlim, [PeerGrading_PL_auc, PeerGrading_PL_auc], color{res_idx}, 'LineWidth',2)
legend_cell{res_idx} = 'PeerGrading-PL';
hold on;
res_idx = res_idx + 1;

% Coarsen Rank
M = 30; % the number of EM iteration
a = [1,2]; % hyperparameter for the score
eps = 250;
tau = eps / (eps + size(data,1));
CoarsenRank_auc = CoarsenRank(data, ground_truth, a, tau, M);
plot(xlim, [CoarsenRank_auc, CoarsenRank_auc], color{res_idx}, 'LineWidth',2)
legend_cell{res_idx} = 'CoarsenRank';
hold on;
res_idx = res_idx + 1;

%% CoarsenBT
M = 10; % the number of EM iteration
a = [1,2]; % hyperparameter for the score
eps = 70;
tau = eps / (eps + size(data,1));
CoarsenBT_auc = CoarsenBT(data, ground_truth, a, tau, M);
plot(xlim, [CoarsenBT_auc, CoarsenBT_auc], color{res_idx}, 'LineWidth',2)
legend_cell{res_idx} = 'CoarsenBT';
hold on;
res_idx = res_idx + 1;

%% CoarsenTH-LBFGS
rank_list = data(:, 2:end);
eps = 500;
tau = eps / (eps + size(data,1));
% set up initial parametmers 
mu = rand(n_obj,1);
CoarsenTH_auc = CoarsenTH(rank_list, ground_truth, mu, tau);
plot(xlim, [CoarsenTH_auc, CoarsenTH_auc], color{res_idx}, 'LineWidth',2)
legend_cell{res_idx} = 'CoarsenTH';
hold on;
res_idx = res_idx + 1;

%% %%%%%%%%%%%%%%%%%% 
%% Vanilla methods %% 
%% %%%%%%%%%%%%%%%%%%

%% PL-LBFGS
C = [1, 2];
rank_list = data(:, 2:end);
% set up initial parametmers 
mu = rand(n_obj,1);
PL_LBFGS_auc = LBFGS_Plackett_Luce(rank_list, ground_truth, mu, C);
plot(xlim, [PL_LBFGS_auc, PL_LBFGS_auc], color{res_idx}, 'LineWidth',2)
legend_cell{res_idx} = 'PL-LBFGS';
hold on;
res_idx = res_idx + 1;

%% CoarsenBT-LBFGS
C = [0, 0];
rank_list = data(:, 2:end);
eps = 2900;
% set up initial parametmers 
mu = rand(n_obj,1);
BT_LBFGS_auc = LBFGS_Bradley_Terry(rank_list, ground_truth, mu, C, eps);
plot(xlim, [BT_LBFGS_auc, BT_LBFGS_auc], color{res_idx}, 'LineWidth',2)
legend_cell{res_idx} = 'CoarsenBT-LBFGS';
hold on;
res_idx = res_idx + 1;

%% CloseEM Rank
M = 30; % the number of EM iteration
a = [1,2]; % hyperparameter for the score
tau = 1;
ClosedEM_auc = EM_rank(data, ground_truth, a, tau, M);
plot(xlim, [ClosedEM_auc, ClosedEM_auc], color{res_idx}, 'LineWidth',2)
legend_cell{res_idx} = 'BT/PL-EM';
hold on;
res_idx = res_idx + 1;

%mean(CrowdBT_auc(end-5:end))
%% Figure setting
legend(legend_cell,'FontSize',14, 'Location', 'Southeast');
ylim([0.8, 1])
xlim([0, length(CrowdBT_auc)])