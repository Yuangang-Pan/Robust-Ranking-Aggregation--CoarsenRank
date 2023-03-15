clc
clear all
close all

load('data.mat')
data = FARM;
index = [9 3 6 15 18 4 12 11 10 8 2 16 1 14 5 17 7 13];
n_obj = length(index);
ground_truth = zeros(n_obj, 1);


doc_diff = n_obj : -1 : 1;
ground_truth(index) = doc_diff;

save BabyFace.mat data ground_truth 