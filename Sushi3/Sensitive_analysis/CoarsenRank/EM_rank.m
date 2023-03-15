function Score = EM_rank(data, ground_truth, a, tau, M, Idx, S_Num)
n_item = max(max(data)); % the number of items

%% EM train to converge
alpha = repmat(a, n_item, 1);% initial parameters for scores,
theta = alpha(:,1) ./ alpha(:,2);
for iter = 1: M  % repeat the experiments M times
    %% Expectation Step
    delta = Coarsen_Exp(data, theta);
    
    %% Maximum Step
    theta = Coarsen_Max(Idx, alpha, delta, tau);
    
    %% calculate the accuracy
    theta = 80 * theta / sum(theta);
end
calc_auc(ground_truth, theta)
%% Gibbs Sampling
Score = [];
[N, K] = size(data);
L = sum(data > 0, 2);
for s = 1 : S_Num 
    
    eta = zeros(N, K);
    for n = 1 : N
        for k = 1 : L(n)-1
            list = data(n, k:L(n));
            eta(n,k) = sum( theta(list)  );
        end
    end
    delta = gamrnd(1, eta);
    
    phi = zeros(size(alpha,1),1);
    psi = zeros(size(alpha,1),1);
    for m = 1 : size(alpha, 1)
        phi(m) = Idx.numerator{m};
        temp = Idx.denominator{m};
        temp_psi = 0;
        for n = 1 : size(temp, 1)
            temp_psi = temp_psi + sum(delta(temp(n,1), 1 : temp(n,2)));
        end
        psi(m) = temp_psi;
    end
  
    temp_score = gamrnd(tau*phi + alpha(:,1) - 1, tau*psi + alpha(:,2));
    theta = 80 * temp_score / sum(temp_score);
    Score = [Score, temp_score];  
end