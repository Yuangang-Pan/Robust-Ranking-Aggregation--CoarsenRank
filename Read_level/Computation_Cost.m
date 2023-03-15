clc
clear all
close all
addpath(genpath('./read_data'));
addpath(genpath('./OnlineBT_OnlineCrowdBT'));
addpath(genpath('./OnlinePL'));
addpath(genpath('./CoarsenTH'));
addpath(genpath('./CoarsenBT'));
addpath(genpath('./CoarsenRank'));
addpath(genpath('./LBFGS_PL'));
addpath(genpath('./LBFGS_BT'));
addpath(genpath('./L-BFGS-B'));
addpath(genpath('./Various_BT_Model'));
addpath(genpath('./Various_BT_Model/minFunc_2012'));
addpath(genpath('./Various_BT_Model/minConf'));
addpath(genpath('./PeerGrading'));

data=dlmread('all_pair.txt');
doc_diff=dlmread('doc_info.txt');
ground_truth=doc_diff(:,2);
%% parameter initialization
n_anno = max(data(:,1));                 % the number of worker
n_obj = max(max(data(:,2:end)));           % the number of onjects

online_para = struct('c', 0.1, 'kappa', 1e-4, 'taylor', 1);  % taylor = 1 because we empoly taylor expansion
PL_LBFGS_time = [];
ClosedEM_time = [];
CrowdBT_time = [];
CoarsenRank_time = [];
CoarsenBT_time = [];
CoarsenTH_time = [];
%% %%%%%%%%%%%%%%%%%% 
%% Vanilla methods %% 
%% %%%%%%%%%%%%%%%%%%
for iter = 1 : 50
%% PL-LBFGS
tic
C = [1, 2];
rank_list = data(:, 2:end);
% set up initial parametmers 
mu = rand(n_obj,1);
PL_LBFGS_auc = LBFGS_Plackett_Luce(rank_list, ground_truth, mu, C);
PL_LBFGS_time(iter) = toc;
%% CloseEM Rank
tic
M = 15; % the number of EM iteration
a = [1,2]; % hyperparameter for the score
tau = 1;
ClosedEM_auc = EM_rank(data, ground_truth, a, tau, M);
ClosedEM_time(iter) = toc;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Sample Level Correction methods %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% CorwdBT Online
tic
mu = zeros( n_obj, 1); % initial parameters for scores
sigma = ones( n_obj, 1);  

a = [5,4];  %the unified initialization for all worker 
alpha = repmat(a, n_anno, 1);

CrowdBT_auc = CrowdBT(data, ground_truth, mu, sigma, alpha, M, online_para);
CrowdBT_time(iter) = toc;
%% Coarsen Rank
tic
a = [1,2]; % hyperparameter for the score
eps = 200;
tau = eps / (eps + size(data,1));
CoarsenRank_auc = CoarsenRank(data, ground_truth, a, tau, M);
CoarsenRank_time(iter) = toc;
%% CoarsenBT
tic
a = [1,2]; % hyperparameter for the score
eps = 200;
tau = eps / (eps + size(data,1));
CoarsenBT_auc = CoarsenBT(data, ground_truth, a, tau, M);
CoarsenBT_time(iter) = toc;

%% CoarsenTH-LBFGS
tic
rank_list = data(:, 2:end);
eps = 4000;
tau = eps / (eps + size(data,1));
% set up initial parametmers 
mu = ones(n_obj,1);
CoarsenTH_auc = CoarsenTH(rank_list, ground_truth, mu, tau);
CoarsenTH_time(iter) = toc;
end