function auc = CrowdBT(data, ground_truth, mu, sigma, alpha, M, online_para)

n_anno = max(data(:,1));                 % the number of worker
n_obj = max(max(data(:,2:end)));           % the number of onjects
n_data = size(data,1);                   % the size of sample
K = size(data,2)-1;                    % the largest length of the k-ary preference
M = 5;

auc=[];
count = 1;                  

for iter = 1: M  % repeat the experiments M times
    idx=randperm(n_data); % random shuffle the data
    for r = 1: n_data
        p = data(idx(r), 1);  % extract the index of worker
        S=data(idx(r), 2:end);  % extract the K-ary 
        
        %% Split each k-ary preference into 
        l = sum(S>0);
        for i = 1:l-1
            for j = i+1:l
                [mu(S(i)), mu(S(j)), sigma(S(i)), sigma(S(j)), alpha(p, 1), alpha(p, 2)] = CrowdBT_online_update(mu(S(i)), mu(S(j)), sigma(S(i)), sigma(S(j)), alpha(p, 1), alpha(p, 2), online_para);
            end
        end
        %% calculate the accuracy 
        if mod(r, 50) == 0 
            auc(count) = calc_auc(ground_truth, mu);
            count = count + 1;
        end
    end
end