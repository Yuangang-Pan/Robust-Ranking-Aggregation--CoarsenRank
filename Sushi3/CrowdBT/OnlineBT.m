function auc = OnlineBT(data, ground_truth, mu, sigma, M, online_para)

n_data = size(data,1);                   % the size of sample

auc=[];
count = 1;  

%% random shuffle the data
for m = 1 : M
    idx = randperm(n_data);
    data_rand = data(idx,:);
    
    for r = 1:  n_data
        p = data_rand(r, 1);  % extract the index of worker
        S = data_rand(r, 2:end);  % extract the K-ary    
        
        
        %% Split each k-ary preference into pairwise preferences
        l = sum(S>0);
        for i = 1:l-1
            for j = i+1:l
                [mu(S(i)), mu(S(j)), sigma(S(i)), sigma(S(j))] = onlineBT_update(mu(S(i)), mu(S(j)), sigma(S(i)), sigma(S(j)), online_para);
            end
        end
        
        %% calculate the accuracy 
        if mod(r, 50) == 0 
            auc(count) = calc_auc(ground_truth, mu);
            count = count + 1;
        end
    end
end