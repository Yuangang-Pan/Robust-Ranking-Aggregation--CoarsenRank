clc
clear all
close all
addpath(genpath('../read_data'));
addpath(genpath('./CoarsenRank'));

load('PeerGrader.mat')
data = data(:,2:end);

%% parameter initialization
n_obj = max(max(data));           % the number of objects
N = size(data,1);
M = 10; % the number of EM iteration
Num = 50;
%% Rank index generation
Idx = Coarsen_idx(data, n_obj);
%% our alpha is set to 800 in the experiment
eps = [100 : 100 : 3000, 3100: 1000 : 20000];  % the parameter space
f_alpha = [];
g_alpha = [];
for iter = 1 : length(eps)
    a = [1,2]; % hyperparameter for the score
    tau = eps(iter) / (eps(iter) + N);
    Score = EM_rank(data, ground_truth, a, tau, M, Idx, Num);
    
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
plot(log(eps), 2*g_alpha - 4*f_alpha, '.')
save Result.mat eps f_alpha g_alpha