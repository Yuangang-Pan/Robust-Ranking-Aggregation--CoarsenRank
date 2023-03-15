function auc = calc_auc(gt, mu)

N = length(gt);                 % the number of item

A=0;
B=0;                  

for i = 1:(N-1)
    for j = i+1: N
        if gt(i) ~= gt(j)
            B = B+1;
            if sign(gt(i)-gt(j)) == sign(mu(i)-mu(j))
                A = A+1;
            end
        end
    end
end
auc = A/B;