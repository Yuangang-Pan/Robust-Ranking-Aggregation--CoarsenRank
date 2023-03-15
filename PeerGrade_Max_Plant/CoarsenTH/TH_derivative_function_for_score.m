function loglikelihood = TH_derivative_function_for_score(mu, Data, Idx, tau, lambda)
mu0 = 0;
Score = exp(lambda * mu);
S0 = exp(lambda * mu0);

grad_reg = lambda * (1 - 2*Score./(S0+Score));

grad_loss = [];

grad_prior = -mu;

for m = 1 : length(mu)
    temp_nume = lambda * Idx.numerator{m};
    temp_deno = Idx.denominator{m};
    temp_pair = Score(Data(temp_deno(:,1), :));
    temp_grad = lambda * Score(m) * sum( 1./ (sum( temp_pair, 2 )));
    grad_loss(m, 1) = temp_nume -  temp_grad;
end

grad = tau * grad_loss + grad_reg + grad_prior;
grad = tau * grad_loss + grad_reg;
loglikelihood = - grad;% min - log likelihood = max log likelihood