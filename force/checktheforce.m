%% load pressure
clc;
clear;
timeNum = 2800;
condition_inclination = ["5度","10度","15度","20度","25度","30度","15度不带撑杆","30度不带撑杆"]; % "15度单跨-空风洞", "15度单跨"还没有做
ww = 0:10:180;
wr = 1;
inputFileDir = "D:\柔性光伏板_全\风洞试验数据\测点风压系数时程_插值\mat格式";
conditionNu = 1;
wangle = 1;
condition = condition_inclination(conditionNu);
w = ww(wangle);

inputFileName = strcat(inputFileDir,"/",condition,"/","pointPressureCoe_modified2_插值_",num2str(w),".mat");
load(inputFileName);

%% calculte pressure should be applied
% 压力为负代表向下压，和重力同向
pressurecoe = out_order(:,10001:10000+timeNum);
pressurecoe1 = pressurecoe(1:336,:);
pressurecoe2 = pressurecoe(337:end,:);
netpressurecoe = pressurecoe1 - pressurecoe2;
pressure = netpressurecoe                                                                                                ; % 压力为负代表向下压，和重力同向

%% 调整第三排右侧9-12排
% 239:252,267:280,295:308, 321:336
pointadj = [1:238,321:336,253:266,295:308,281:294,267:280,309:320,239:252];
pressuretoadj = pressure;
pressureadj = pressuretoadj(pointadj,:);
%%
pressure_time_mean = mean(pressureadj,2);
matrixpressure = reshape(pressure_time_mean,28,12);
matrixpressure = matrixpressure';
matrixpressure2 = matrixpressure(12:-1:1,:);

%% show
% 使用imagesc显示矩阵
matrixtoshow = matrixpressure2;
imagesc(matrixtoshow);
colorbar; % 显示颜色条
axis equal tight; % 调整坐标轴，使其紧凑且比例相等

% 遍历矩阵，显示每个元素的数值
[rows, cols] = size(matrixtoshow);
for i = 1:rows
    for j = 1:cols
        text(j, i, num2str(matrixtoshow(i,j), '%0.2f'), ...
             'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'middle');
    end
end