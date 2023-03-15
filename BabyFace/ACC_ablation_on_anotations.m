clc
clear all
close all
rng(915)
addpath(genpath('./read_data'));
addpath(genpath('./CrowdBT'));
addpath(genpath('./CoarsenRank'));
addpath(genpath('./CoarsenBT'));
addpath(genpath('./CoarsenTH'));
addpath(genpath('./LBFGS_PL'));
addpath(genpath('./L-BFGS-B'));
addpath(genpath('./PeerGrading'));
addpath(genpath('./Ablation'));
load('BabyFace.mat')
Full_data = data;
ratio = [0.01, 0.02, 0.04, 0.08, 0.16, 0.32, 0.64, 1];
color = {'g', 'm', 'b', 'k', 'r--', 'k--', 'b--', 'c--'};
for id = 1: length(ratio)
    %% select ratio% data for training
    data = Data_Selection(Full_data, ratio(id));
%% parameter initialization
n_anno = max(data(:,1));                 % the number of worker
n_obj = max(max(data(:,2:end)));           % the number of onjects

M = 5;  % go through the whole data M times for online algorithms
online_para = struct('c', 0.1, 'kappa', 1e-4, 'taylor', 1);  % taylor = 1 because we empoly taylor expansion

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Sample Level Correction methods %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% CorwdBT
mu = zeros( n_obj, 1); % initial parameters for scores
sigma = ones( n_obj, 1);  

a = [5,3];  %the unified initialization for all worker 
alpha = repmat(a, n_anno, 1);

CrowdBT_auc = CrowdBT(data, ground_truth, mu, sigma, alpha, M, online_para);
CrowdBT_acc(id) = CrowdBT_auc(end);

%% PeerGrading PL
load('PeerGrading_PL_auc.mat')

%% %%%%%%%%%%%%%%%%%% 
%% Our methods     %% 
%% %%%%%%%%%%%%%%%%%%
%% Coarsen Rank
M = 30; % the number of EM iteration
a = [1,1]; % hyperparameter for the score
eps = 50;
tau = eps / (eps + size(data,1));
CoarsenRank_auc(id) = CoarsenRank(data, ground_truth, a, tau, M);

%% Coarsen BT
M = 30; % the number of EM iteration
a = [3,3]; % hyperparameter for the score
eps = 700;
tau = eps / (eps + size(data,1));
CoarsenBT_auc(id) = CoarsenBT(data, ground_truth, a, tau, M);


%% CoarsenTH-LBFGS
rank_list = data(:, 2:end);
eps = 8;
tau = eps / (eps + size(data,1));
% set up initial parametmers 
mu = rand(n_obj,1);
CoarsenTH_auc(id) = CoarsenTH(rank_list, ground_truth, mu, tau);

%% %%%%%%%%%%%%%%%%%% 
%% Vanilla methods %% 
%% %%%%%%%%%%%%%%%%%%
%% PL-LBFGS
C = [1, 2];
rank_list = data(:, 2:end);
% set up initial parametmers 
mu = rand(n_obj,1);
PL_LBFGS_auc(id) = LBFGS_Plackett_Luce(rank_list, ground_truth, mu, C);

%% CloseEM Rank
M = 30; % the number of EM iteration
a = [4,6]; % hyperparameter for the score
tau = 1;
ClosedEM_auc(id) = EM_rank(data, ground_truth, a, tau, M);
end
semilogx(ratio, CrowdBT_acc, color{1}, ratio, PeerGrading_PL_auc, color{2}, ...
    ratio, ClosedEM_auc, color{3}, ratio, PL_LBFGS_auc, color{4}, ...
    ratio, CoarsenBT_auc, color{5}, ratio, CoarsenTH_auc, color{6}, ratio, ...
    CoarsenRank_auc, color{7})
legend_cell = {'CrodwBT', 'PeerGrader', 'BT/PL-EM', 'PL-LBFGS', 'CoarsenBT', 'CoarsenTH', 'CoarsenPL'};
legend(legend_cell,'FontSize',14, 'Location', 'Southeast');