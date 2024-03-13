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
inclination = inclinationlist(1);

% 每个分区包含的node
basicrect1 = [101,102,144,143]';
basicrect2 = [basicrect1, basicrect1+1];
basicrect3 = [basicrect2, basicrect2+42, basicrect2+42*2, basicrect2+42*3];
basicrect4 = basicrect3;
for i = 1:13
    basicrect4 = [basicrect4, basicrect3+3*i];
end
basicrect5 = [basicrect4, basicrect4+210,basicrect4+210*2] - 100;

% input output dir
inputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/", "vibCoe/");
outputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/", "vibCoe/");

directionlist = ["Z_"];

for wangle = 1:numel(ww)
    w = ww(wangle);
    for direct = directionlist
        inputfilename = strcat(inputdir,"vibCoe",direct,num2str(w), ".csv");
        nodevibCoe = readmatrix(inputfilename);
        % 把vibCoe压缩到0-3或0-6
        nodeOptimvibCoe = optimizedata(nodevibCoe);
        % convert node vibration coefficients to block vibration coefficients
        blockvibCoe = node2block(nodeOptimvibCoe, basicrect5);
        
        checkblockvibCoe(blockvibCoe,w,direct);
%         newFileName = strcat(outputdir,"block336OptimVibCoe",direct,num2str(w), ".csv");
%         writematrix(blockvibCoe,newFileName);
    end
end

function  value = node2block(valueMatrix,indexMatrix)
    % convert node vibration coefficients to block vibration coefficients
    % valueMatrix: apdl里node算出的风振结果
    % indexMatrix: 一块block包含的node的编号
    newMatrix = valueMatrix(indexMatrix);
    value = mean(newMatrix,1);
end

function value = optimizedata(data)
    % 把vibCoe压缩到0-3或0-6
    % 计算95%分位数作为阈值,如果分位数小于阈值，把大于3的赋值3
    % 如果分位数大于阈值，用非线性变换把3-infinite变换到3-6
    threshold = quantile(data, 0.95);
    if threshold < 3
        data(data>3) =3;
    else
        % 步骤一：对数据加1后应用对数变换
        log_data = log(data(data>3));
        % 步骤二：找到对数变换后的数据的最小和最大值
        min_log_data = min(log_data);
        max_log_data = max(log_data);
        % 将对数变换后的数据线性缩放到0到3的范围内
        data(data>3) = 3 + ((log_data - min_log_data) / (max_log_data - min_log_data)) * 3;

    end
    value = data;
    
end

function checkblockvibCoe(blockvibCoe,w,direct)
    M = reshape(blockvibCoe,28,12);
    M = M';
    M = M(12:-1:1,:);

    % 分割原始矩阵为三个4x28矩阵
    A1 = M(1:4, :);
    A2 = M(5:8, :);
    A3 = M(9:12, :);

    % 定义目标矩阵的x和y坐标网格，对于每个矩阵进行插值
    [x, y] = meshgrid(1:28, 1:4); % y轴插值从1到4，分成40个点
    [xq, yq] = meshgrid(linspace(1, 28, 280), linspace(1, 4, 40)); % 插值后的网格
        
    % 对每个矩阵进行插值
    Aq1 = interp2(x, y, A1, xq, yq, 'cubic');
    Aq2 = interp2(x, y, A2, xq, yq, 'cubic');
    Aq3 = interp2(x, y, A3, xq, yq, 'cubic');
    
    % 绘制云图
    figure;
    subplot(3,1,1);
    contourf(xq, yq, Aq1, 50);
    title('Part 3');
    subplot(3,1,2);
    contourf(xq, yq, Aq2, 50);
    title('Part 2');
    subplot(3,1,3);
    contourf(xq, yq, Aq3, 50);
    title('Part 1');
    title(strcat('vibCoe plot ',direct, num2str(w)));

    % 调整颜色轴以共用同一个颜色轴
    cmin = min([Aq1(:); Aq2(:); Aq3(:)]);
    cmax = max([Aq1(:); Aq2(:); Aq3(:)]);
    for i = 1:3
        subplot(3,1,i);
        caxis([cmin cmax]);
    end
    colorbar('Position', [0.92 0.11 0.02 0.815]); % 调整颜色条的位置
end

function checknodevibCoe(nodevibCoe,w,direct)
    M = reshape(nodevibCoe,42,15);
    M = M';
    M = M(15:-1:1,:);

    % 分割原始矩阵为三个5x42矩阵
    A1 = M(1:5, :);
    A2 = M(6:10, :);
    A3 = M(11:15, :);

    % 定义目标矩阵的x和y坐标网格，对于每个矩阵进行插值
    [x, y] = meshgrid(panelx_all(1:42), panely_all(1:42:210)); % node坐标
    [xq, yq] = meshgrid(linspace(panelx_all(1), panelx_all(42), 420), linspace(panely_all(1), panely_all(210), 50)); % 10倍插值后的网格
        
    % 对每个矩阵进行插值
    Aq1 = interp2(x, y, A1, xq, yq, 'cubic');
    Aq2 = interp2(x, y, A2, xq, yq, 'cubic');
    Aq3 = interp2(x, y, A3, xq, yq, 'cubic');
    
    % 绘制云图
    figure;
    subplot(3,1,1);
    contourf(xq, yq, Aq1, 50);
    title('Part 3');
    subplot(3,1,2);
    contourf(xq, yq, Aq2, 50);
    title('Part 2');
    subplot(3,1,3);
    contourf(xq, yq, Aq3, 50);
    title('Part 1');
    title(strcat('vibCoe plot ',direct, num2str(w)));

    % 调整颜色轴以共用同一个颜色轴
    cmin = min([Aq1(:); Aq2(:); Aq3(:)]);
    cmax = max([Aq1(:); Aq2(:); Aq3(:)]);
    for i = 1:3
        subplot(3,1,i);
        caxis([cmin cmax]);
    end
    colorbar('Position', [0.92 0.11 0.02 0.815]); % 调整颜色条的位置
end