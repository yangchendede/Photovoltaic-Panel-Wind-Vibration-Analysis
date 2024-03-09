%% define time step and some parameter
clc;
clear;

condition_inclination = ["5度","10度","15度","20度","25度","30度","15度不带撑杆","30度不带撑杆"]; % "15度单跨-空风洞", "15度单跨"还没有做
ww = 0:10:180;

% 场地参数
aerfa=0.3;%d类地貌，中高层建筑密集区，起伏较大的丘陵地带，地面粗糙度取0.3
% 风速计算
wb = 400; % 建筑结构荷载规范规定50年重现期基本风压 N/m2
protoReferenceHeight = 1.85; %实际结构参考点高度
elevation=304.5; %建筑结构荷载规范规定
rou=0.00125*exp(-0.0001*elevation)*1000; %空气密度
v = sqrt(wb/(0.5*rou)); %10米高度50年重现期10min平均风速
ur=v*(protoReferenceHeight/10).^aerfa; %实际结构参考高度风速
wr = 0.5*rou*ur^2;

% 实验参数
freq = 312.5; %风洞采集频率

geometricScale = 7; %几何比尺
windspeedScale = ur/10; %风速比尺
timeScale = geometricScale / windspeedScale; %时间比尺
protoFreq = freq / timeScale; %原型频率
dt = 1 / protoFreq;

% apdl计算参数
timeNum = 2800;
t=dt:dt:(timeNum * dt);
pressureNlist = 1:336;
loadNnumber = numel(pressureNlist);

%% load pressure
inputFileDir = "D:\柔性光伏板_全\风洞试验数据\测点风压系数时程_插值\mat格式";
conditionNu = 6;
wangle = 4;
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

%% adjust pressure point number
% 因为第三排光伏板荷载成中心对称，但合理的是对称。因此认为第三排光伏板右侧测点顺序错了，第三排光伏板右侧1，2，3，4排顺序改为4，3，2，1排
% 239:252,267:280,295:308, 321:336
pointadj = [1:238,321:336,253:266,295:308,281:294,267:280,309:320,239:252];
pressuretoadj = pressure;
pressureadj = pressuretoadj(pointadj,:);
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
            fprintf(fileID,'SFE,%5d,%5d,PRES,1,%12.6f\n',loadElementlist(loadlocation), 1,pressureadj(loadlocation,tt));
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

