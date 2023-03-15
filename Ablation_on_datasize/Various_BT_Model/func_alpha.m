function [obj,grad, H]=func_alpha(alpha, s, para, pair)
  
    s0=getOpt(para, 's0', 0);
    reg_0=getOpt(para, 'reg_0', 0);
    reg_alpha=getOpt(para, 'reg_alpha', 0);
    reg_s=getOpt(para, 'reg_s', 0);
    uni_weight=getOpt(para, 'uni_weight', true);
    algo=getOpt(para, 'algo', 'CrowdBT');
    Idx=getOpt(para, 'Idx', []);
    
    n_anno=length(alpha);
    p=exp(s);
    p0=exp(s0);
    
    switch algo
        case 'CrowdBT'
            obj=-reg_0*(sum(log(p0./(p0+p)))+sum(log(p./(p0+p))));
        case 'HRA-G'
            obj=-reg_0*(sum(log(p0./(p0+p)))+sum(log(p./(p0+p))));
        case 'HRA-N'
            obj=-reg_0*(sum(log(normcdf(s0-s))))+sum(log(normcdf(s-s0)));
        case 'HRA-E'
            x = s - s0;
            pos = 1/4 * exp(-x).*(x+2);
            neg = 1/4 * exp( x).*(x-2)+1;
            tot = (sign(x) + 1)/2.*pos + (sign(x) - 1)/(-2).*neg;
            obj = -reg_0 * sum(log(tot));
            
            x = s0 - s;
            pos = 1/4 * exp(-x).*(x+2);
            neg = 1/4 * exp( x).*(x-2)+1;
            tot = (sign(x) + 1)/2.*pos + (sign(x) - 1)/(-2).*neg;
            obj = obj - reg_0 * sum(log(tot)); 
        case 'Vanilla-PL'
            obj=-reg_0*(sum(log(p0./(p0+p)))+sum(log(p./(p0+p))));
    end
    
    grad=zeros(n_anno,1);
    h=zeros(n_anno,1);
       
    for k=1:length(pair)
        if (uni_weight)
            s_k=1;
        else
            s_k=size(pair{k},1);
        end
        
        switch algo
            case 'CrowdBT'
                alpha_tmp=(alpha(k)*p(pair{k}(:,1))+(1-alpha(k))*p(pair{k}(:,2)));
                diff_tmp=p(pair{k}(:,1))-p(pair{k}(:,2));
                obj=obj-sum(log(alpha_tmp)-log(p(pair{k}(:,1))+p(pair{k}(:,2))))/s_k;        
                grad(k)=-sum(diff_tmp./alpha_tmp)/s_k+reg_alpha*alpha(k);
                h(k)=sum((diff_tmp./alpha_tmp).^2)/s_k+reg_alpha;
                
            case 'HRA-G'
                s_j = s(pair{k}(:,2));
                s_i = s(pair{k}(:,1));
                gamma = alpha(k);
                obj = obj - sum(log(exp(s_i * gamma)./(exp(s_i * gamma) + exp(s_j * gamma))))/s_k;
                grad(k)=sum((s_j - s_i)./(1 + exp(gamma * (s_i - s_j))))/s_k + reg_alpha * gamma;
                h(k)=sum((s_j - s_i).^2.* exp(gamma * (s_i + s_j)) ./ ...
                    (exp(gamma * s_i) + exp(gamma * s_j)).^2)/s_k + reg_alpha;

            case 'HRA-N'
                s_j = s(pair{k}(:,2));
                s_i = s(pair{k}(:,1));
                gamma = alpha(k);
                temp_cdf = normcdf((s_i-s_j)*gamma);
                obj = obj - sum(log(temp_cdf))/s_k;
                grad(k)=sum(-1. ./ temp_cdf .* normpdf((s_i-s_j)*gamma) .* (s_i - s_j))/s_k + reg_alpha * gamma;

            case 'HRA-E'
                s_j = s(pair{k}(:,2));
                s_i = s(pair{k}(:,1));
                gamma = alpha(k);
                x = s_j - s_i;
                
                pos = 1/4 * exp(-gamma.*x).*(gamma.*x+2);
                neg = 1/4 * exp( gamma.*x).*(gamma.*x-2)+1;
                tot = (sign(x) + 1)/2.*pos + (sign(x) - 1)/(-2).*neg;
                obj = obj - sum(log(tot))/s_k;
              
                pv = x.*(gamma*x+1)./(gamma*x+2);
                nv = -x.*exp(gamma*x).*(gamma*x -1)./(exp(gamma.*x).*(gamma*x -2) +4);
                tot = (sign(x) + 1)/2.*pv + (sign(x) - 1)/(-2).*nv; 
                grad(k)=sum(tot);
            case 'Vanilla-PL'
                Data = pair{1};
                for n = 1 : size(Data,1)
                    list = Data(n, :);
                    list = list(list>0);
                    K = length(list)-1;
                    temp_n = sum( mu(list(1 : K)) );
                    for k = 1 : K
                        temp_n = temp_n - log( sum ( Score(list(k : end))  ) );
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
                            temp_nume = temp_nume - Score(m) / sum ( Score(list(k : end)) );
                        end
                    end
                    grad(m) = grad(m) - temp_nume;
                    
                end
        end
    end
    
    obj=obj+reg_s*norm(s,2).^2/2+reg_alpha*norm(alpha,2).^2/2;
    H=sparse(1:n_anno, 1:n_anno, h);
    
end

