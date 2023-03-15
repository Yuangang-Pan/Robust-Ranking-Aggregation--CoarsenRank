clc
clear all
close all
addpath(genpath('../read_data'));
addpath(genpath('./CoarsenRank'));

data = dlmread('all_pair.txt');
data = data(:,2:end);

%% parameter initialization
n_anno = max(data(:,1));                 % the number of worker
n_obj = max(max(data(:,2:end)));           % the number of objects
N = size(data,1);
M = 10; % the number of EM iteration
Num = 50;
%% Rank index generation
Idx = Coarsen_idx(data, n_obj);
eps = [100 : 100 : 2000, 1100 : 500 : 50000];  % the parameter space
f_alpha = [];
g_alpha = [];
for iter = 1 : length(eps)
    a = [1,2]; % hyperparameter for the score
    tau = eps(iter) / (eps(iter) + N);
    Score = EM_rank(data, a, tau, M, Idx, Num);
    
    %% calculate the f_alpha
    temp_f = 0;
    for idx = 1 : Num
        temp_f = temp_f + Log_likelihood_Evaluation(data, Score(:,idx));
    end
    %% goodness of fit
    f_alpha(iter) = temp_f / Num;  
    
    %% model complexity
    mean_Score = sum(Score, 2);
    temp_g = Log_likelihood_Evaluation(data, mean_Score);
    g_alpha(iter) = f_alpha(iter) - temp_g;
end
%% we want select the parameter which is good fit to our data while has low model complexity
plot(g_alpha, f_alpha, '.')