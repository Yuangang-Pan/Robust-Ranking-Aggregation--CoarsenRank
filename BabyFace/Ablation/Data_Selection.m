function full_data = Data_Selection(data, ratio)

full_data = [];
n_anno = max(data(:,1));  % the number of worker
for n = 1 : n_anno
  Idx = data(:,1)==n;
  full_size = sum(Idx);
  temp_data = data(Idx,:);
  select_size = round(full_size * ratio);
  Id = randperm(full_size, select_size);
  new_data = temp_data(Id, :);
  full_data = [full_data; new_data];
end