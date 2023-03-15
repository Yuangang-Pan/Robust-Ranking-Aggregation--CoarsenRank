function Idx = Rank_idx(data, M)
  
  Numerator = {};
  Denominator_Idx = {};
  Ln = sum(data>0,2);
  for m = 1 : M
      [Temp_S, Temp_O] = find(data == m);
      if isempty(Temp_S)
          Numerator{m} = [];
          Denominator_Idx{m} = [];
      else
          Numerator{m} = sum(Temp_O < Ln(Temp_S));
          Denominator_Idx{m} = [Temp_S, Temp_O];
      end
  Idx.numerator = Numerator;
  Idx.denominator = Denominator_Idx;
  Idx.Ln = Ln;
end