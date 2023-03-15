function Acc = accuracy_calcu(w, Crowd_task, Data)


%% record the correct prediction
r=0;
for i = 1 : size(Crowd_task,1)
    x1 = [Data(Crowd_task(i,1), :, Crowd_task(i,2)),1]';
    x2 = [Data(Crowd_task(i,1), :, Crowd_task(i,3)),1]';
    temp_a = 1 / (1 + exp( w' * (x2-x1)));
    if temp_a > 0.5
       r = r + 1;
    end
end
Acc = r/i;
