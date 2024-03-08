%% 将LES风压转为分块中心的集中风荷载
clc;
clear;

% 场地参数v = 37;
v = 37;
aerfa=0.12;

% 实验参数
freq = 312.5;
time = 90;
N = freq * time;

geometricScale = 250;
windspeedScale = 43.4/11.8;
timeScale = geometricScale / windspeedScale;
protoFreq = freq / timeScale;
dt=1/protoFreq;

protoReferenceHeight = 37.5;
ur=v*(protoReferenceHeight/10).^aerfa;
elevation=284.8;
rou=0.00125*exp(-0.0001*elevation)*1000;
wr=1/2*rou*ur^2;

angles=0:10:350;
timeNum = 2800;
blockNum = 128;
blockNum_roof = 112;
blockNum_gable = 16;
inputPath = strcat(['E:\煤棚抗风动力可靠度分析20200608']);

for num=1:36
    q=angles(num);%风向角
    windForce = zeros(2*blockNum_roof+blockNum_gable,timeNum);
    Area1=xlsread([inputPath,'.\分块面积_中部分开.xlsx'],'sheet1');
    load([inputPath,'\风洞试验数据\分块风压系数时程_中部分开\',num2str(q),'\pressureCoe.mat']);
    pressureLoad = pressureCoe * wr;
  
    for i=1:blockNum_roof
        windForce(i,:)=Area1(i,1)*pressureLoad(i,1:timeNum);
        windForce(blockNum_roof+i,:)=Area1(i,2)*pressureLoad(i,1:timeNum);
    end
    
    for i = (blockNum_roof+1):blockNum
        windForce(blockNum_roof+i,:)=Area1(i,2)*pressureLoad(i,1:timeNum);
    end
    
    windForce(65:112,:) = -windForce(65:112,:);
    windForce(113:224,:) = -windForce(113:224,:);
    windForce(225:232,:) = -windForce(225:232,:);
    
    outputFile=['.\风荷载时程\windForceTimehistory_',num2str(q),'.mat'];
    save(outputFile,'windForce');
end