%% 本程序用于生成ansys时程计算文件
clc;
clear;
path=cd;
%设置风向角
ww=0:10:350;
freq = 312.5;
time = 90;
N = freq * time;
geometricScale = 250;
windspeedScale = 43.4/11.8;
timeScale = geometricScale / windspeedScale;
protoFreq = freq / timeScale;
dt = 1 / protoFreq;
timeNum = 2800;
t=dt:dt:(timeNum * dt);
inputPath = strcat(['E:\煤棚抗风动力可靠度分析20200608']);

blockNum_roof = 112;
blockNum_gable = 16;
blockNum_total = 240;
blockNum = 128;

fid1_output=fopen(['.\计算文件\timeHistoryComputingFile.txt'],'w');
fid1_forward=fopen('.\forward.txt','r');
Data_forward=fread(fid1_forward);
fwrite(fid1_output,Data_forward);
fclose(fid1_forward);

inputFile = strcat([inputPath,'\区块中心点坐标_中部分开.xlsx']);
loadPoint = xlsread(inputFile,'Sheet4');
for num=1:1
    w=ww(num);
    inputFile=strcat(['.\风荷载时程\windForceTimehistory_',num2str(w),'.mat']);
    load(inputFile);

    for tt = 1:timeNum
        fprintf(fid1_output,'TIME,%12.6f\n',t(tt));
        fprintf(fid1_output,'NSUBST,1,,,1\nKBC,0\n');
        for i=1:112
            fprintf(fid1_output,'F,%d,FY,%12.6f\n',loadPoint(i),windForce(i,tt));
            fprintf(fid1_output,'F,%d,FZ,%12.6f\n',loadPoint(i),windForce(blockNum_roof+i,tt));
        end
        for i=113:128
            fprintf(fid1_output,'F,%d,FX,%12.6f\n',loadPoint(i),windForce(blockNum_roof+i,tt));
        end
        fprintf(fid1_output,'SAVE\nSOLVE\n');
    end
end
fid1_backward=fopen('.\backward.txt','r');
Data_backward=fread(fid1_backward);
fwrite(fid1_output,Data_backward);
fclose(fid1_backward);

fclose(fid1_output);
clear Data_forward Data_backward;




