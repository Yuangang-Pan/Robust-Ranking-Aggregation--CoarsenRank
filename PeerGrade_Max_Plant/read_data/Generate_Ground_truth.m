clc
clear all
close all

%% generate ground truth
Ta_Grad = xlsread('ta.csv');

Task_Id = unique(Ta_Grad(:,1));
Task_num = length(Task_Id);
item_num = unique(Ta_Grad(:,3));
item_num = length(item_num);
Ta_data = zeros(item_num, Task_num);
for t = 1 : Task_num
    id_t = find(Ta_Grad(:,1) == Task_Id(t));
    max_grad = max(Ta_Grad(id_t,4));
    min_grad = min(min(Ta_Grad(id_t,4)), 1);
    Ta_data(Ta_Grad(id_t,3), t) = (Ta_Grad(id_t,4) - min_grad)* 9 / (max_grad - min_grad) + 1;
end

ground_truth = sum(Ta_data, 2) ./ sum(Ta_data>0, 2);

%% generate rating data
Self_Grad = xlsread('self.csv');
Peer_Grad = xlsread('peer.csv');

Task_Id = unique(Self_Grad(:,1));
Task_num = length(Task_Id);

Item_Id = unique(Self_Grad(:,2));
Item_num = length(Item_Id);

data = zeros(1, 4);
count = 1;

for t = 1 : Task_num
    for i = 1 : Item_num
        Self_idx = intersect(find(Self_Grad(:,1) == Task_Id(t)), find(Self_Grad(:,2) == Item_Id(i)));
        Peer_idx = intersect(find(Peer_Grad(:,1) == Task_Id(t)), find(Peer_Grad(:,2) == Item_Id(i)));
        if ~isempty(Peer_idx)
           if ~isempty(Self_idx) && (length(Peer_idx) == 1) 
              if Self_Grad(Self_idx,4) > Peer_Grad(Peer_idx,4)
                  data(count,1:3) = [Self_Grad(Self_idx,2), Self_Grad(Self_idx,3), Peer_Grad(Peer_idx,3)];
                  count = count + 1;
              elseif Self_Grad(Self_idx,4) < Peer_Grad(Peer_idx,4)
                  data(count,1:3) = [Self_Grad(Self_idx,2), Peer_Grad(Peer_idx,3), Self_Grad(Self_idx,3)];
                  count = count + 1;
              end
           end
           if ~isempty(Self_idx) && (length(Peer_idx) == 2) 
               if  Peer_Grad(Peer_idx(1),4) == Peer_Grad(Peer_idx(2),4)
                   if Self_Grad(Self_idx,4) > Peer_Grad(Peer_idx(1),4)
                       data(count,1:3) = [Self_Grad(Self_idx,2), Self_Grad(Self_idx,3), Peer_Grad(Peer_idx(1),3)];
                       count = count + 1;
                       data(count,1:3) = [Self_Grad(Self_idx,2), Self_Grad(Self_idx,3), Peer_Grad(Peer_idx(2),3)];
                       count = count + 1;
                   elseif Self_Grad(Self_idx,4) < Peer_Grad(Peer_idx(1),4)
                       data(count,1:3) = [Self_Grad(Self_idx,2), Peer_Grad(Peer_idx(1),3), Self_Grad(Self_idx,3)];
                       count = count + 1;
                       data(count,1:3) = [Self_Grad(Self_idx,2), Peer_Grad(Peer_idx(2),3), Self_Grad(Self_idx,3)];
                       count = count + 1;
                   end
               elseif Self_Grad(Self_idx,4) == Peer_Grad(Peer_idx(1),4)
                   if Self_Grad(Self_idx,4) > Peer_Grad(Peer_idx(2),4)
                       data(count,1:3) = [Self_Grad(Self_idx,2), Self_Grad(Self_idx,3), Peer_Grad(Peer_idx(2),3)];
                       count = count + 1;
                       data(count,1:3) = [Self_Grad(Self_idx,2), Peer_Grad(Peer_idx(1),4), Peer_Grad(Peer_idx(2),3)];
                       count = count + 1;
                   elseif Self_Grad(Self_idx,4) < Peer_Grad(Peer_idx(2),4)
                       data(count,1:3) = [Self_Grad(Self_idx,2), Peer_Grad(Peer_idx(2),3), Self_Grad(Self_idx,3)];
                       count = count + 1;
                       data(count,1:3) = [Self_Grad(Self_idx,2), Peer_Grad(Peer_idx(2),3), Peer_Grad(Peer_idx(1),4)];
                       count = count + 1;
                   end
               elseif Self_Grad(Self_idx,4) == Peer_Grad(Peer_idx(2),4)
                   if Self_Grad(Self_idx,4) > Peer_Grad(Peer_idx(1),4)
                       data(count,1:3) = [Self_Grad(Self_idx,2), Self_Grad(Self_idx,3), Peer_Grad(Peer_idx(1),3)];
                       count = count + 1;
                       data(count,1:3) = [Self_Grad(Self_idx,2), Peer_Grad(Peer_idx(2),4), Peer_Grad(Peer_idx(1),3)];
                       count = count + 1;
                   elseif Self_Grad(Self_idx,4) < Peer_Grad(Peer_idx(1),4)
                       data(count,1:3) = [Self_Grad(Self_idx,2), Peer_Grad(Peer_idx(1),3), Self_Grad(Self_idx,3)];
                       count = count + 1;
                       data(count,1:3) = [Self_Grad(Self_idx,2), Peer_Grad(Peer_idx(1),3), Peer_Grad(Peer_idx(2),4)];
                       count = count + 1;
                   end
               else
                   item = [Self_Grad(Self_idx,3), Peer_Grad(Peer_idx(1),3), Peer_Grad(Peer_idx(2),3)];
                   score = [Self_Grad(Self_idx,4), Peer_Grad(Peer_idx(1),4), Peer_Grad(Peer_idx(2),4)];
                   [~, order_id] = sort(score, 'descend');
                   data(count,:) = [Self_Grad(Self_idx,2), item(order_id)];
                   count = count + 1;
               end
           end
           
           if isempty(Self_idx) && (length(Peer_idx) == 2)
               if Peer_Grad(Peer_idx(1),4) ~= Peer_Grad(Peer_idx(2),4)
                   
                   item = [Peer_Grad(Peer_idx(1),3), Peer_Grad(Peer_idx(2),3)];
                   score = [Peer_Grad(Peer_idx(1),4), Peer_Grad(Peer_idx(2),4)];
                   [~, order_id] = sort(score, 'descend');
                   data(count,1:3) = [Peer_Grad(Peer_idx(1),2), item(order_id)];
                   count = count + 1;
               end
           end
           
        end
    end
end
data(:,1) = data(:,1) - 6;

save PeerGrader.mat data ground_truth 