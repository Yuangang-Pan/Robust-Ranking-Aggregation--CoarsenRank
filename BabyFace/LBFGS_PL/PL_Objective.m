function loglikelihood = PL_Objective(mu, Data)

temp = 0;
for n = 1 : size(Data,1)
    list = Data(n, :);
    list = list(list>0);
    K = length(list)-1;
    temp_n = sum( mu(list(1 : K)) );
    for k = 1 : K
        temp_n = temp_n - log( sum ( exp(mu(list(k : end))) ) );
    end
    temp = temp + temp_n;
end
loglikelihood = temp;