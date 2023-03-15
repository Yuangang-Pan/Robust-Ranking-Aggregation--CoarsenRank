clc
clear all
close all

path('./L-BFGS-B', path);
path('./Ground_truth_With_EM', path);
Data = load('./sushi3b.5000.10.order');
Data = Data(:, 3:end) + 1;

n_item = max(max(Data)); % the number of items
n_data = size(Data,1);  % the size of sample
M = 25; % the number of EM iteration
%% parameter initialization
a = [1,2];
alpha = repmat(a, n_item, 1);% initial parameters for scores,
theta = alpha(:,1) ./ alpha(:,2);
auc = []; 
Log_likelihood = [];
tau = 1;
%% Rank index generation
Idx = Rank_idx(Data, n_item);
for iter = 1: M  % repeat the experiments M times
    fprintf('iter %d\n', iter)
    %% Expectation Step
    delta = Rank_Exp(Data, theta);
    
    %% Maximum Step
    theta = Rank_Max(Idx, alpha, delta, tau);
    
    %% calculate the accuracy
    Log_likelihood(iter) = Log_likelihood_Evaluation(Data, theta);
    theta = 10 * theta / sum(theta);
end
plot(Log_likelihood)
ground_truth = theta;

%% Generate the new data
N = 3000;   %the size of the new data
L = size(Data, 2);
Id = randperm(n_data, N);
Temp_data = Data(Id, :); % select partial dataset 
data = zeros(n_data, L); % generate incomplete ranking list
for n = 1 : N
    rand_L = randi(L-3) + 3; % random generate the length of each ranking list
    Idx = randperm(L, rand_L); 
    data(n, 1: rand_L) = Temp_data(n, sort(Idx));
end
for n = N+1 : n_data
    rand_L = randi(L-3) + 3; % random generate the length of each ranking list
    Idx = randperm(n_item, rand_L); 
    data(n, 1: rand_L) = Idx;
end
%% add the user id 
data = [(1:n_data)', data];
Id = randperm(n_data);
data = data(Id, :);
save sushi.mat data Data ground_truth 