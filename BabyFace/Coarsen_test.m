clc
clear all
close all
rng(915)
addpath(genpath('./read_data'));
addpath(genpath('./CoarsenRank'));
addpath(genpath('./Ablation'));
load('BabyFace.mat')
Full_data = data;
ratio = [0.01, 0.02, 0.04, 0.08, 0.16, 0.32, 0.64, 1];
for id = 1: length(ratio)
    %% select ratio% data for training
    data = Data_Selection(Full_data, ratio(id));
%% parameter initialization
n_anno = max(data(:,1));                 % the number of worker
n_obj = max(max(data(:,2:end)));           % the number of onjects

M = 5;  % go through the whole data M times for online algorithms
online_para = struct('c', 0.1, 'kappa', 1e-4, 'taylor', 1);  % taylor = 1 because we empoly taylor expansion

%% Coarsen Rank
M =30; % the number of EM iteration
a = [1,1]; % hyperparameter for the score
eps = 50;
tau = eps / (eps + size(data,1));
CoarsenRank_auc(id) = CoarsenRank(data, ground_truth, a, tau, M);
end