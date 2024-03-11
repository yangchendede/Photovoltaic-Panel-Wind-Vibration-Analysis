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
paralist = ["U"]; %位移风振系数只需要位移

inputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/", "nodestatiCoe/");
outputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/", "vibCoe/");
for para = paralist
    for direct = directionlist
        inputfilename1 = strcat(inputdir,"avg",para,direct,num2str(wangle), ".csv");
        inputfilename2 = strcat(inputdir,"std",para,direct,num2str(wangle), ".csv");
        disp_avg = readmatrix(inputfilename1);
        disp_std = readmatrix(inputfilename2);
        
        vibcoe_disp = 1+g.*disp_std./abs(disp_avg);
        newFileName = strcat(outputdir,"vibCoe",direct,num2str(wangle), ".csv")

%         writematrix(avgM,newFileName);
    end
end