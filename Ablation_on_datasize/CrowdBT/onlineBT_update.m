function [mu1_new, mu2_new, sigma1_new, sigma2_new] = onlineBT_update(mu1, mu2, sigma1, sigma2, para)

    kappa=getOpt(para, 'kappa', 1e-4);
    taylor=getOpt(para, 'taylor', false);

    e1 = exp(mu1);
    e2 = exp(mu2);
    e12 = e1+e2;
    
    tmp1 = 1-e1/e12;
    mu1_new = mu1+sigma1*tmp1;
    mu2_new = mu2-sigma2*tmp1;

    tmp2 = -e1*e2/(e12^2);
    sigma1_new = sigma1*max(1+sigma1*tmp2, kappa);
    sigma2_new = sigma2*max(1+sigma2*tmp2, kappa);
end

