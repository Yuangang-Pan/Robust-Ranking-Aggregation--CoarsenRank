function loglikelihood = TH_Objective_function_for_score(mu, Data, tau, lambda)
mu0 = 0;
Score = exp(lambda * mu);
S0 = exp(lambda * mu0);
delta_theta = exp(lambda * (mu(Data(:,2)) - mu(Data(:,1))));

Log_like = - sum(log(1 + delta_theta)); 

Log_Reg = sum(log(S0./(S0+Score)))+sum(log(Score./(S0+Score)));

Log_Prior = - 1/2 * mu' * mu; 

loglikelihood = - Log_Prior - tau * Log_like - Log_Reg; 
loglikelihood = - tau * Log_like - Log_Reg;% min - log likelihood = max log likelihood