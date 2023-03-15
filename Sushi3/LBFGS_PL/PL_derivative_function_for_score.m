function loglikelihood = PL_derivative_function_for_score(mu, Data, Idx, C)
mu0 = 0;
Score = exp(mu);
S0 = exp(mu0);
grad = C(1) - 2*C(1)*(Score./(S0+Score));
for m = 1 : length(mu)
    temp_nume = Idx.numerator{m};
    temp_deno = Idx.denominator{m};
    temp_grad = 0;
    for n = 1 : size(temp_deno, 1)
        list = Data(temp_deno(n, 1), :);
        list = list(list>0);
        for k = 1 : min(temp_deno(n, 2), length(list)-1)
            temp_grad = temp_grad - Score(m) / sum ( Score(list(k : end)) );
        end
    end
    grad(m) = grad(m) + temp_nume + temp_grad;
end

grad = grad - C(2)*mu;
loglikelihood = - grad;% min - log likelihood = max log likelihood