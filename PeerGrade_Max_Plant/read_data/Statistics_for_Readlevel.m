clc
clear all 
close all
load('PeerGrader.mat');

N = size(data, 1);
M = max(data(:,1));

L = [];
for m = 1 : M
    L(m) = sum(data(:,1) == m);
end

min(L) 
max(L)