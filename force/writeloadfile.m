%% define time step and some parameter
clc;
clear;

condition_inclination = ["5度","10度","15度","20度","25度","30度","15度不带撑杆","30度不带撑杆"]; % "15度单跨-空风洞", "15度单跨"还没有做
ww = 0:10:180;

% 场地参数
v=37;
aerfa=0.12;

% 实验参数
freq = 312.5;
time = 90;
N = freq * time;
geometricScale = 7;
windspeedScale = 30/10;
timeScale = geometricScale / windspeedScale;
protoFreq = freq / timeScale;
dt = 1 / protoFreq;

% apdl计算参数
timeNum = 2800;
timeNum = 400;
t=dt:dt:(timeNum * dt);
pressureNlist = 1:336;
loadNnumber = numel(pressureNlist);

% 风速计算
protoReferenceHeight = 1.85;
ur=v*(protoReferenceHeight/10).^aerfa;
elevation=250;
rou=0.00125*exp(-0.0001*elevation)*1000;
wr=1/2*rou*ur^2;


%% load pressure
inputFileDir = "D:\柔性光伏板_全\风洞试验数据\测点风压系数时程_插值\mat格式";
conditionNu = 1;
wangle = 1;
condition = condition_inclination(conditionNu);
w = ww(wangle);

inputFileName = strcat(inputFileDir,"/",condition,"/","pointPressureCoe_modified2_插值_",num2str(w),".mat");
load(inputFileName);
% load('D:\柔性光伏板_全\风洞试验数据\测点风压系数时程_插值\mat格式\5度\pointPressureCoe_modified2_插值_0.mat')
%% calculte pressure should be applied
% 压力为负代表向下压，和重力同向
pressurecoe = out_order(:,10001:10000+timeNum);
netpressurecoe = pressurecoe(1:336,:) - pressurecoe(337:end,:);
pressure = -(netpressurecoe * wr); % 压力为负代表向下压，和重力同向
% pressure = -(300+rand(loadNnumber, timeNum)*30);
%% load 336 net pressure to 336 element surface

% load pressure data order to apdl element mapping relation
temp = load("pressurenumbermapping.mat");
loadElementlist = temp.pressurenumbermaping;

% pressureNlist = [1:336];
clear temp;

%% open the file
% 打开文件准备写入，'w'表示写入模式，如果文件已存在会被覆盖
inputPath = strcat('');
filename = 'loadhistory.txt';
fileName = strcat(inputPath,'',filename);
fileID = fopen(fileName, 'w');
% 检查文件是否成功打开（fileID是否大于3）
if fileID == -1
    error('File cannot be opened');
end
fprintf(fileID, "\n!*********************!\n");
fprintf(fileID, "! define time-step load\n");
fprintf(fileID, "!*********************!\n");

% write time-step loads
for wangle = 1:1
    w = ww(wangle);
%     inputfile = 
%     load = 
    for tt = 1:timeNum
        fprintf(fileID,'TIME,%12.6f\n',t(tt)); %set time step
%         fprintf(fileID,'TIME,%5d\n',t(tt)); %set time step
        fprintf(fileID,'NSUBST,1,,,1\nKBC,0\n'); 
        %NSUBST: Specifies the number of substeps to be taken this load step.
        %KBC: Specifies ramped or stepped loading within a load step.
        for loadlocation = 1:loadNnumber
%         for loadlocation = 1:28
            % SFE, Elem, LKEY, Lab, KVAL, VAL1, VAL2, VAL3, VAL4
            fprintf(fileID,'SFE,%5d,%5d,PRES,1,%12.6f\n',loadElementlist(loadlocation), 1,pressure(loadlocation,tt));
%             fprintf(fileID,'F,%5d,   FZ,%12.6f\n',100+loadlocation,pressure(loadlocation,tt));
        end
        fprintf(fileID,'SOLVE\n');
        
    end
%     fprintf(fileID,'PSOLVE\n');
%     fprintf(fileID,'LSWRITE,1\n');
%     fprintf(fileID,'LSSOLVE,1,1\n');
end

%% close the file
fclose(fileID);

