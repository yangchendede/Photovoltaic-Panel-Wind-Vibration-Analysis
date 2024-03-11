clc;
clear;
close all;

g = 2.5;
phi = 0.25;

% every condition
inclinationlist=5:5:30;
ww = 0:10:180;
paralist = ["U", "velo", "acce"];
directionlist = ["X_", "Y_", "Z_"];
% selected condition
inclination = inclinationlist(6);
wangle = ww(4);

% read the data
inputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/");
outputdir = strcat(inputdir,"nodestatiCoe/");
tstart = tic;
% disp
for para = paralist
    for direct = directionlist
        inputfilename = strcat(inputdir,"matrix_",para,direct,num2str(wangle), ".csv");
        M = readmatrix(inputfilename);
        size(M)
        avgM = mean(M,1);
        stdM = std(M,1);
%         vibcoe_disp3=1+g.*disp_std./abs(disp_avg);
        newFileName1 = strcat(outputdir,"avg",para,direct,num2str(wangle), ".csv");
        newFileName2 = strcat(outputdir,"std",para,direct,num2str(wangle), ".csv");
        writematrix(avgM,newFileName1);
        writematrix(stdM,newFileName2);
    end
end
tEnd = toc(tstart);
