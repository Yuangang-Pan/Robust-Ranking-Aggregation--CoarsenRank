function delta = Coarsen_Exp(data, score)

  [N, K] = size(data);
  delta = zeros(N, K);
  L = sum(data > 0, 2);
  
  for n = 1 : N
      for k = 1 : L(n)-1
          list = data(n, k:L(n));
          delta(n,k) = 1 / (sum( score(list)  )  );
      end
  end
end