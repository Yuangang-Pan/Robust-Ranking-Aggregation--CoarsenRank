function loglikelihood = derivative_function_for_score(mu, Data, Idx, C)
mu0 = 0;
Score = exp(mu);
S0 = exp(mu0);
grad = C(1) - 2*C(1)*(Score./(S0+Score));
for m = 1 : length(mu)
    temp_nume = Idx.numerator{m};
    temp_deno = Idx.denominator{m};
    
    temp_grad = sum ( Score(m) ./  sum(Score(Data(temp_deno(:, 1), :)), 2));
    grad(m) = grad(m) + temp_nume - temp_grad;
end

grad = grad - C(2)*mu;
loglikelihood = - grad;% min - log likelihood = max log likelihood