function auc = OnlinePL(data, ground_truth, mu, sigma, M, online_para)

data = data(:,2:end);

n_data = size(data,1);                   % the size of sample

auc=[];
count = 1;   

for iter = 1: M  % repeat the experiments M times
    idx = randperm(n_data); % random shuffle the data
    for r = 1:  n_data
        S = data(idx(r), :);  % extract the K-ary 
        [mu, sigma] = onlinePL_update(mu, sigma, S, online_para);
     
        %% calculate the accuracy 
        if mod(r, 50) == 0 
            auc(count) = calc_auc(ground_truth, mu);
            count = count + 1;
        end  
    end
end