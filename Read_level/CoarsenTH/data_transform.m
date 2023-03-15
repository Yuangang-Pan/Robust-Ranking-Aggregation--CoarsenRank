function data_pair = data_transform(data_list)
  data_pair = [];
 for n = 1 : size(data_list, 1)
     Ln = sum(data_list(n,:) > 0);
     for i = 1 : Ln-1
         for j = i+1 : Ln
             temp = [data_list(n,i), data_list(n,j)];
             data_pair = [data_pair; temp];
         end
     end
 end