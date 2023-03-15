function f = Log_likelihood_Evaluation(data, theta)

N = size(data, 1);
L = sum(data>0, 2);
f = 0;
for n = 1 : N
    for i = 1 : L(n)-1
        f = f + log(theta(data(n,i))) - log( sum ( theta ( data (n, i:L(n)) ) ) );
    end
end