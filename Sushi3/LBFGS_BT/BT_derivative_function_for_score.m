function loglikelihood = BT_derivative_function_for_score(mu, Data, Idx, C, tau)
mu0 = 0;
Score = exp(mu);
S0 = exp(mu0);
grad_reg = C(1) - 2*C(1)*(Score./(S0+Score));
grad_loss = [];
for m = 1 : length(mu)
    temp_nume = Idx.numerator{m};
    temp_deno = Idx.denominator{m};
    
    temp_grad = sum ( Score(m) ./  sum(Score(Data(temp_deno(:, 1), :)), 2));
    grad_loss(m, 1) = temp_nume - temp_grad;
end

grad = grad_reg + tau * grad_loss - C(2)*mu;
loglikelihood = - grad;% min - log likelihood = max log likelihood