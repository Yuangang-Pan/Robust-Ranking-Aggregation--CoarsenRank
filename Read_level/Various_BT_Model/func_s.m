function [obj,grad]=func_s(s, alpha, para, pair)

    s0=getOpt(para, 's0', 0);
    reg_0=getOpt(para, 'reg_0', 1);
    reg_s=getOpt(para, 'reg_s', 1);
    reg_alpha=getOpt(para, 'reg_alpha', 0);
    uni_weight=getOpt(para, 'uni_weight', true);
    algo=getOpt(para, 'algo', 'CrowdBT');
    Idx=getOpt(para, 'Idx', []);
    
    p=exp(s);
    p0=exp(s0);
    switch algo
        case 'CrowdBT'
            obj=-reg_0*(sum(log(p0./(p0+p)))+sum(log(p./(p0+p))));
            grad=2*reg_0*(p./(p0+p))-reg_0;
        case 'HRA-G'
            obj=-reg_0*(sum(log(p0./(p0+p)))+sum(log(p./(p0+p))));
            grad=2*reg_0*(p./(p0+p))-reg_0;
        case 'HRA-N'
            x = s - s0;
            temp_cdf = normcdf(x);
            obj = - reg_0*sum(log(temp_cdf));
            v = 1. ./ temp_cdf .* normpdf(x);
            grad =  -reg_0*v;
            
            x = s0 - s;
            temp_cdf = normcdf(x);
            obj = obj - reg_0*sum(log(temp_cdf));
            v = 1. ./ temp_cdf .* normpdf(x);
            grad = grad + reg_0*v;
            
        case 'HRA-E'
            x = s - s0;
            pos = 1/4 * exp(-x).*(x+2);
            neg = 1/4 * exp( x).*(x-2)+1;
            tot = (sign(x) + 1)/2.*pos + (sign(x) - 1)/(-2).*neg;
            obj = - reg_0 * sum(log(tot));
            
            pv = (x+1)./(x+2);
            nv = -exp(x).*(x -1)./(exp(x).*(x -2) + 4);
            tot = (sign(x) + 1)/2.*pv + (sign(x) - 1)/(-2).*nv; 
            grad = reg_0 * tot;
            
            x = s0 - s;
            pos = 1/4 * exp(-x).*(x+2);
            neg = 1/4 * exp( x).*(x-2)+1;
            tot = (sign(x) + 1)/2.*pos + (sign(x) - 1)/(-2).*neg;
            obj = obj - reg_0 * sum(log(tot));
            
            pv = (x+1)./(x+2);
            nv = -exp(x).*(x -1)./(exp(x).*(x -2) + 4);
            tot = (sign(x) + 1)/2.*pv + (sign(x) - 1)/(-2).*nv; 
            grad = grad - reg_0 * tot;
       case 'Vanilla-PL'
            obj=-reg_0*(sum(log(p0./(p0+p)))+sum(log(p./(p0+p))));
            grad=2*reg_0*(p./(p0+p))-reg_0;
    end

    for k=1:length(pair)
   
        if (uni_weight)
            s_k=1;
        else
            s_k=size(pair{k},1);
        end

        switch algo
            case 'CrowdBT'
                obj=obj-sum(log((alpha(k)*p(pair{k}(:,1))+(1-alpha(k))*p(pair{k}(:,2))))-...
                    log(p(pair{k}(:,1))+p(pair{k}(:,2))))/s_k;
                for idx=1:size(pair{k},1)
                    winner=pair{k}(idx,1);
                    loser=pair{k}(idx,2);
                    v=(p(winner)/(p(winner)+p(loser))...
                        -alpha(k)*p(winner)/(alpha(k)*p(winner)+(1-alpha(k))*p(loser)))/s_k;
                    grad(winner)=grad(winner)+v;
                    grad(loser)=grad(loser)-v;
                end

            case 'HRA-G'
                s_i = s(pair{k}(:,1)); % winner
                s_j = s(pair{k}(:,2)); % loser
                gamma = alpha(k);
                obj = obj - sum(log(exp(s_i * gamma) ./ ...
                    (exp(s_i * gamma) + exp(s_j * gamma))))/s_k;

                for idx=1:size(pair{k},1)
                    i = pair{k}(idx,1); % winner
                    j = pair{k}(idx,2); % loser
                    v = gamma * exp(gamma * s(j)) ./ ...
                        (exp(s(j) * gamma) + exp(s(i) * gamma));
                    grad(i) = grad(i) - v;
                    grad(j) = grad(j) + v;
                end
               
            case 'HRA-N'
                s_i = s(pair{k}(:,1)); % winner
                s_j = s(pair{k}(:,2)); % loser
                gamma = alpha(k);
                temp_cdf = normcdf((s_i-s_j)*gamma);
                obj = obj - sum(log(temp_cdf))/s_k;

                for idx=1:size(pair{k},1)
                    i = pair{k}(idx,1); % winner
                    j = pair{k}(idx,2); % loser
                    v = gamma ./ temp_cdf(idx) * normpdf((s(i)-s(j))*gamma);
                    grad(i) = grad(i) - v;
                    grad(j) = grad(j) + v;
                end

            case 'HRA-E'
                s_i = s(pair{k}(:,1)); % winner
                s_j = s(pair{k}(:,2)); % loser
                gamma = alpha(k);
                x = s_j - s_i;
                pos = 1/4 * exp(-gamma.*x).*(gamma.*x+2);
                neg = 1/4 * exp( gamma.*x).*(gamma.*x-2)+1;
                tot = (sign(x) + 1)/2.*pos + (sign(x) - 1)/(-2).*neg;
                obj = obj - sum(log(tot))/s_k;

                for idx=1:size(pair{k},1)
                    i = pair{k}(idx,1); % winner
                    j = pair{k}(idx,2); % loser
                    x = s(j) - s(i); 
                    % negative log likelihood for f(x)
                    pv = gamma.*(gamma*x+1)./(gamma*x+2);
                    nv = -gamma.*exp(gamma*x).*(gamma*x-1)./(exp(gamma.*x).*(gamma*x-2) + 4);
                    tot = (sign(x) + 1)/2.*pv + (sign(x) - 1)/(-2).*nv; 
                    grad(i) = grad(i) - tot;
                    grad(j) = grad(j) + tot;
                end
            case 'Vanilla-PL'
                Data = pair{1};
                for n = 1 : size(Data,1)
                    list = Data(n, :);
                    list = list(list>0);
                    K = length(list)-1;
                    temp_n = sum( s(list(1 : K)) );
                    for k = 1 : K
                        temp_n = temp_n - log( sum ( p(list(k : end))  ) );
                    end
                    obj = obj - temp_n;
                end
                
                for m = 1 : length(grad)
                    temp_nume = Idx.numerator{m};
                    temp_deno = Idx.denominator{m};
                    for n = 1 : size(temp_deno, 1)
                        list = Data(temp_deno(n, 1), :);
                        list = list(list>0);
                        for k = 1 : temp_deno(n, 2)
                            temp_nume = temp_nume - p(m) / sum ( p(list(k : end)) );
                        end
                    end
                    grad(m) = grad(m) - temp_nume;                    
                end
        end
    end

    obj=obj+reg_s/2*norm(s,2).^2+reg_alpha/2*norm(alpha,2).^2;
    grad=grad+reg_s.*s;
end
