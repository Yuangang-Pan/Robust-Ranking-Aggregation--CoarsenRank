function loglikelihood = BT_Objective_function_for_score(mu, Data, C, tau)
mu0 = 0;
temp = 0;
Score = exp(mu);
S0 = exp(mu0);
for n = 1 : size(Data,1)
    list = Data(n, :);
    temp_n = mu(list(1))- log( sum ( Score(list)  ) ); 
    temp = temp + temp_n;
end

Reg = C(1)*(sum(log(S0./(S0+Score)))+sum(log(Score./(S0+Score))));

temp = tau * temp + Reg - C(2)/2 * norm(mu,2).^2;
loglikelihood = -temp; % min - log likelihood = max log likelihood