clc;
clear;
close all;

g = 2.5;
phi = 0.25;

% every condition
inclinationlist=5:5:30;
ww = 0:10:180;
directionlist = ["X_", "Y_", "Z_"];

for inclinationN = 1:numel(inclinationlist)
    % selected condition
    inclination = inclinationlist(inclinationN);
    
    % 每个分区包含的node
    basicrect1 = [1,2,44,43;2,3,45,44]';
    repeated = repmat(basicrect1, 1, 14);
    increments = repmat(0:3:3*13, 2, 1);
    increments = increments(:)';
    increments = repmat(increments,4,1);
    basicrect2 = repeated + increments;
    basicrect3 = [basicrect2, basicrect2 + 42, basicrect2 + 42*2, basicrect2 + 42*3];
    basicrect4 = [basicrect3, basicrect3 + 210, basicrect3 + 210*2];
    
    %meshgrid 用的node的xy坐标
    load("../model/panelnodeall.mat");
    node_x = panelx_all(1:42);
    node_y = panely_all(1:42:210);
    
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
            blockvibCoe = node2block(nodeOptimvibCoe, basicrect4);
            
            newFileName1 = strcat(outputdir,"node630OptimVibCoe",direct,num2str(w), ".csv");
            newFileName2 = strcat(outputdir,"block336OptimVibCoe",direct,num2str(w), ".csv");
            writematrix(nodeOptimvibCoe,newFileName1);
            writematrix(blockvibCoe,newFileName2);
        end
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