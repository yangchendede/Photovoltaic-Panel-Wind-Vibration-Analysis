clc;
clear;
close all;

% every condition
inclinationlist=5:5:30;
ww = 0:10:180;
directionlist = ["X_", "Y_", "Z_"];

% selected condition
inclination = inclinationlist(4);

% input output dir
inputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/", "vibCoe/");
outputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/", "vibCoe/");
fileName95 = strcat(outputdir,"vibCoe95value.txt");
fileID95 = fopen(fileName95, 'w');
for wangle = 1:numel(ww)
    w = ww(wangle);
    for direct = directionlist
        inputfilename = strcat(inputdir,"vibCoe",direct,num2str(w), ".csv");
        nodevibCoe = readmatrix(inputfilename);
        
        fprintf(fileID95, "%s%dangle95%%value:%f\n",direct, w, quantile(nodevibCoe, 0.95));
    end
end
fclose(fileID95);