clc;
clear;
close all;

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

% every condition
condition_inclination = ["5度","10度","15度","20度","25度","30度","15度不带撑杆","30度不带撑杆"]; % "15度单跨-空风洞", "15度单跨"还没有做
inclinationlist=5:5:30;
ww = 0:10:180;
directionlist = ["X_", "Y_", "Z_"];

%node contour: meshgrid 用的node的xy坐标
load("../model/panelnodeall.mat");
node_x = panelx_all(1:42);
node_y = panely_all(1:42:210);

% node_x -> block_x
% show how to convert. no need to run again
% b = [1,2;2,3];
% repeated = repmat(b, 1, 14);
% increments = repmat(0:3:3*13, 2, 1);
% increments = increments(:)';
% basicrect2 = repeated + increments;
% block_x = node2block(node_x, basicrect2);
% block_y = node2block(node_y, [1,2,3,4;2,3,4,5]);
% block336_x = repmat(block_x,1,12);
% block_y2 = sort(repmat(block_y,1,28));
% block336_y = [block_y2, block_y2+2.8, block_y2+2.8*2];
% writematrix(block336_x, "../model/block336_x.csv");
% writematrix(block336_y, "../model/block336_y.csv");

% read block center xy
block336_x = readmatrix("../model/block336_x.csv");
block336_y = readmatrix("../model/block336_y.csv");
block_x = block336_x(1:28);
block_y = block336_y(1:28:28*4);
for inclinationN = 2:numel(inclinationlist)
    inclination = inclinationlist(inclinationN);
    condition = condition_inclination(inclinationN); 
    % vibcoe input dir
    inputdir1 = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/", "vibCoe/");
    % pressureCoe input dir
    inputdir2 = strcat("D:/Photovoltaic_system/风洞试验数据/测点风压数据统计数据/", condition);
    load(fullfile(inputdir2,"测点风压系数统计数据_net_modified2_插值.mat"));
    blockPressure_all = netPressureCoeMean;
    
    %output dir
    outputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/", "equalWindForce/");
    % 检查输出路径是否存在，如果不存在，则创建
    if ~exist(outputdir, 'dir')
        mkdir(outputdir);
    end
    
    directionlist = ["Z_"];

    for wangle = 1:numel(ww)
        w = ww(wangle);
        for direct = directionlist
            inputfilename = strcat(inputdir1,"block336OptimVibCoe",direct,num2str(w), ".csv");
            blockvibCoe = readmatrix(inputfilename);
            %从19*336的矩阵中取出一个风向角的数据
            blockPressure = (blockPressure_all(:,wangle))';
            equalwindforce = blockvibCoe.*blockPressure*wr./1000; % 荷载规范8.1.1风荷载标准值 (kN/m2)
            title = strcat("equalwindforce", direct, num2str(w), ".csv");
            writematrix(equalwindforce, fullfile(outputdir,title));
            drawblockequalforce(equalwindforce, w,direct,node_x, node_y, block_x, block_y, outputdir);

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

function drawblockequalforce(blockequalforce, w,direct,node_x, node_y, block_x, block_y, outputdir)

    M2 = reshape(blockequalforce,28,12);
    M2 = M2';
    M2 = M2(12:-1:1,:);

    % 分割原始矩阵为三个4x28矩阵
    valueMatrix1 = M2(4:-1:1, :);
    valueMatrix2 = M2(8:-1:5, :);
    valueMatrix3 = M2(12:-1:9, :);
    % 定义目标矩阵的x和y坐标网格，对于每个矩阵进行插值
    [x, y] = meshgrid(block_x,block_y); % node坐标
    [xq, yq] = meshgrid(linspace(node_x(1), node_x(end), 10*numel(node_x)), linspace(node_y(1), node_y(end), 10*numel(node_y))); % 10倍插值后的网格
        
    % 对每个矩阵进行插值
    % 'cubic' 方法要求网格具有一致的间距。
    % 由于不满足此条件，该方法将会从 'cubic' 切换到 'spline'。
    Aq1 = interp2(x, y, valueMatrix1, xq, yq, 'spline');
    Aq2 = interp2(x, y, valueMatrix2, xq, yq, 'spline');
    Aq3 = interp2(x, y, valueMatrix3, xq, yq, 'spline');

    parts = {Aq1, Aq2, Aq3};
    
    figure;
    set(gcf, 'Units', 'inches', 'Position', [0, 0, 10.9, 7.5]); % 图形尺寸设置为7.5x10.9英寸匹配A4纸
    % 设置默认文字大小
    set(gca, 'FontSize', 10); % 调整坐标轴文字大小
    %绘图
    for i = 1:3
        subplot(3, 1, i);

        % 选择对应的值矩阵
        if i == 1
            currentValues = valueMatrix1;
        elseif i == 2
            currentValues = valueMatrix2;
        else
            currentValues = valueMatrix3;
        end

        contourf(xq, yq, parts{i}, 'LineColor', 'none');
%         title([titles{i}, ': vibCoe plot: ', direct, num2str(w)]);
        hold on;
        
        % 在图上画直线划分区域
        % 绘制竖直方向的直线，偶数直线更粗
        for tx = 1:28
            if mod(tx, 2) == 0 % 检查tx是否为偶数
                lineWidth = 0.5; % 偶数直线的粗细
            else
                lineWidth = 1.5; % 奇数直线的粗细
            end
            lineX = min(xq(:)) + (tx-1) * range(xq(:)) / 28;
            plot([lineX, lineX], [min(yq(:)), max(yq(:))], 'k', 'LineWidth', lineWidth);
        end
        for lineY = linspace(min(yq(:)), max(yq(:)), 5)
            plot([min(xq(:)), max(xq(:))], [lineY, lineY], 'k', 'LineWidth', 0.5);
        end
        
        % 在每个区域显示文本
        dx = range(xq(:)) / 28;
        dy = range(yq(:)) / 4;
        for tx = 1:28
            for ty = 1:4
                textX = min(xq(:)) + (tx-0.5)*dx;
                textY = min(yq(:)) + (ty-0.5)*dy;
                %text value改成风振结果
                textValue = currentValues(ty, tx);
                text(textX, textY, sprintf('%5.2f', textValue), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 8, 'Color', 'k');
            end
        end
        axis tight;
        axis off;
        hold off;
    end

    % 调整颜色轴以共用同一个颜色轴
    cmin = min([Aq1(:); Aq2(:); Aq3(:)]);
    cmax = max([Aq1(:); Aq2(:); Aq3(:)]);
    for i = 1:3
        subplot(3,1,i);
        caxis([cmin cmax]);
    end
    colorbar('Position', [0.92 0.11 0.02 0.815]); % 调整颜色条的位置

    %输出保存图片
    title = strcat("equalwindforce", direct, num2str(w), ".png");
    filename = strcat(outputdir,title);
    exportgraphics(gcf, filename, 'Resolution', 300);
end