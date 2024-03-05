clear;
%% load pressure

%% calculte pressure should be applied

%% load 336 net pressure to 336 element surface

% load pressure data order to apdl element mapping relation
temp = load("pressurenumbermapping.mat");
loadElementlist = temp.pressurenumbermaping;
pressureNlist = [1:336];
clear temp;

