function theta = Rank_Max(Idx, alpha, delta, tau)

   theta = [];
   M = size(alpha, 1);
   phi = zeros(size(alpha,1),1);
   psi = zeros(size(alpha,1),1);
  for m = 1 : M
      phi(m) = Idx.numerator{m};
      temp = Idx.denominator{m};
      temp_psi = 0;
      for n = 1 : size(temp, 1)
          temp_psi = temp_psi + sum(delta(temp(n,1), 1 : temp(n,2)));
      end
      psi(m) = temp_psi;
  end
  
  theta = (tau*phi + alpha(:,1) -1) ./ (tau*psi + alpha(:,2));
  
end