function loglikelihood = Objective_function_for_score(mu, Data, C)
mu0 = 0;
temp = 0;
Score = exp(mu);
S0 = exp(mu0);
for n = 1 : size(Data,1)
    list = Data(n, :);
    list = list(list>0);
    K = length(list)-1;
    temp_n = sum( mu(list(1 : K)) );
    for k = 1 : K
        temp_n = temp_n - log( sum ( Score(list(k : end))  ) );
    end
    temp = temp + temp_n;
end

Reg = C(1)*(sum(log(S0./(S0+Score)))+sum(log(Score./(S0+Score))));

temp = temp + Reg - C(2)/2 * norm(mu,2).^2;
loglikelihood = -temp; % min - log likelihood = max log likelihood