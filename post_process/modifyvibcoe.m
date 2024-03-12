clc;
clear;
close all;

g = 2.5;
phi = 0.25;

% every condition
inclinationlist=5:5:30;
ww = 0:10:180;
directionlist = ["X_", "Y_", "Z_"];

% selected condition
inclination = inclinationlist(4);

directionlist = ["Z_"];
ww = [0];

% 每个分区包含的node
basicrect1 = [101,102,144,143]';
basicrect2 = [basicrect1, basicrect1+1];
basicrect3 = [basicrect2, basicrect2+42, basicrect2+42*2, basicrect2+42*3];
basicrect4 = basicrect3;
for i = 1:13
    basicrect4 = [basicrect4, basicrect3+3*i];
end
basicrect5 = [basicrect4, basicrect4+210,basicrect4+210*2];

% input output dir
inputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/", "vibCoe/");
outputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/", "vibCoe/");

for w = ww
    for direct = directionlist
        inputfilename = strcat(inputdir,"vibCoe",direct,num2str(w), ".csv");
        nodevibCoe = readmatrix(inputfilename);
        nodevibCoe
        blockvibCoe = node2block(nodevibCoe);
        newFileName = strcat(outputdir,"vibCoe",direct,num2str(w), ".csv");

%         writematrix(vibcoe_disp,newFileName);
    end
end

function  value = node2block(nodevibcoe)
    valueMatrix = nodevibcoe;
    indexMatrix = nodeinblock;
    newMatrix = valueMatrix(indexMatrix);

    

end