function auc = LBFGS_Bradley_Terry(data, Ground_truth, mu, C)
%% output parameters
% Score_new: the score parameter for each object
% Log_likelihood: the objective function

N_obj = max(max(data));
Idx = Rank_idx(data, N_obj);

%% Optimization w.r.t. score
fcn_score = @(x) Objective_function_for_score(x, data, C);
grad_score = @(x) derivative_function_for_score(x, data, Idx, C);

% There are no constraints
l = -inf(size(mu));
u = inf(size(mu));

% LBFGS
fun_score = @(x)fminunc(x, fcn_score, grad_score); 
Score = LBFGSB(fun_score, mu, l, u, []);
auc = calc_auc(Ground_truth, Score);
