function[mu_new, sigma_new] = onlinePL_update(mu, sigma, S, para)

    kappa=getOpt(para, 'kappa', 1e-4);
    taylor=getOpt(para, 'taylor', false);
    
    mu_new = mu;
    sigma_new = sigma; % updated parameters
    
    l =  sum(S>0); % number of objects in current preference S
    
    %% update Si, Sj, Sk 
    for i = 1:l 
        % update mu and sigma
        temp_mu = 1;
        temp_sigma = 0;
        for j = 1 : i
            temp_A = exp( mu(S(i)) );
            temp_B = sum(exp( mu(S(j:l)) ));
            temp_mu = temp_mu - temp_A / temp_B;
            temp_sigma = temp_sigma - temp_A * (temp_B - temp_A) / (temp_B^2);
        end
        mu_new(S(i)) = mu(S(i)) + sigma(S(i)) * temp_mu; % update mu      
        sigma_new(S(i)) = sigma(S(i)) * max( 1 + sigma(S(i)) * temp_sigma, kappa);% update sigma
    end

