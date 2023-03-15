clc
clear all
close all
addpath(genpath('./read_data'));
addpath(genpath('./CrowdBT'));
addpath(genpath('./CoarsenRank'));
addpath(genpath('./CoarsenBT'));
addpath(genpath('./CoarsenTH'));
addpath(genpath('./LBFGS_PL'));
addpath(genpath('./L-BFGS-B'));
addpath(genpath('./PeerGrading'));

load('BabyFace.mat')
%% parameter initialization
n_anno = max(data(:,1));                 % the number of worker
n_obj = max(max(data(:,2:end)));           % the number of onjects

M = 15;  % go through the whole data M times for online algorithms
online_para = struct('c', 0.1, 'kappa', 1e-4, 'taylor', 1);  % taylor = 1 because we empoly taylor expansion

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Sample Level Correction methods %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iter = 1 : 50
%% %%%%%%%%%%%%%%%%%% 
%% Vanilla methods %% 
%% %%%%%%%%%%%%%%%%%%
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
a = [4,6]; % hyperparameter for the score
tau = 1;
ClosedEM_auc = EM_rank(data, ground_truth, a, tau, M);
ClosedEM_time(iter) = toc;
%% CorwdBT
tic
mu = zeros( n_obj, 1); % initial parameters for scores
sigma = ones( n_obj, 1);  

a = [5,3];  %the unified initialization for all worker 
alpha = repmat(a, n_anno, 1);

CrowdBT_auc = CrowdBT(data, ground_truth, mu, sigma, alpha, M, online_para);
CrowdBT_time(iter) = toc;

%% %%%%%%%%%%%%%%%%%% 
%% Our methods     %% 
%% %%%%%%%%%%%%%%%%%%
%% Coarsen Rank
tic

a = [6,6]; % hyperparameter for the score
eps = 100;
tau = eps / (eps + size(data,1));
CoarsenRank_auc = CoarsenRank(data, ground_truth, a, tau, M);
CoarsenRank_time(iter) = toc;
%% CoarsenBT
tic
a = [3,3]; % hyperparameter for the score
eps = 700;
tau = eps / (eps + size(data,1));
CoarsenBT_auc = CoarsenBT(data, ground_truth, a, tau, M);
CoarsenBT_time(iter) = toc;


%% CoarsenTH-LBFGS
tic
rank_list = data(:, 2:end);
eps = 8;
tau = eps / (eps + size(data,1));
% set up initial parametmers 
mu = ones(n_obj,1);
CoarsenTH_auc(iter) = CoarsenTH(rank_list, ground_truth, mu, tau);
CoarsenTH_time(iter) = toc;
end