function auc = CoarsenTH(data, Ground_truth, mu, tau)
%% output parameters
% Score_new: the score parameter for each object
% Log_likelihood: the objective function
% data = data_transform(data); 
% save data.mat data
load('data')
N_obj = max(max(data));
Idx = Rank_idx(data, N_obj);
lambda = 2 / sqrt(pi);

%% Optimization w.r.t. score
fcn_score = @(x) TH_Objective_function_for_score(x, data, tau, lambda);
grad_score = @(x) TH_derivative_function_for_score(x, data, Idx, tau, lambda);

% There are no constraints
l = -inf(size(mu));
u = inf(size(mu));

% LBFGS
fun_score = @(x)fminunc(x, fcn_score, grad_score); 
Score = LBFGSB(fun_score, mu, l, u, []);

auc = calc_auc(Ground_truth, Score);   
