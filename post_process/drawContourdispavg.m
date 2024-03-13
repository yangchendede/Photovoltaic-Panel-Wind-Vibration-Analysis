clc;
clear;
close all;

g = 2.5;
phi = 0.25;

% every condition
inclinationlist=5:5:30;
ww = 0:10:180;
paralist = ["U", "velo", "acce"];
directionlist = ["X_", "Y_", "Z_"];

% selected condition
for inclination = inclinationlist
    paralist = "U";
    directionlist = "Z_";
    
    % input output dir
    inputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/", "nodestatiCoe/");
    outputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/", "DispPic/");
    % 检查输出路径是否存在，如果不存在，则创建
    if ~exist(outputdir, 'dir')
        mkdir(outputdir);
    end
    
    %node contour: meshgrid 用的node的xy坐标
    load("../model/panelnodeall.mat");
    node_x = panelx_all(1:42);
    node_y = panely_all(1:42:210);
    
    % 每个分区包含的node
    node2blockOrder = readmatrix("node2blockOrder.csv");
    
    % calculate max min disp and corresponding windangle, plot
    for w = ww
        for para = paralist
            for direct = directionlist
                inputtitle = strcat("avg",para,direct,num2str(w),".csv");
                
                nodedisp = readmatrix(strcat(inputdir,inputtitle));
                blockdisp = node2block(nodedisp, node2blockOrder);
        
                % plot contour
                title = strcat(para,direct,num2str(w), ".png");
                plotnodedisp(nodedisp, blockdisp,node_x,node_y, outputdir, title);
                    
            end
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

function plotnodedisp(nodeValue,blockValue,node_x, node_y, outputdir, title)
    % value用mm单位展示，因为太多小数点占文字位置
    % 列顺序存储的M，第一个元素代表0度第一排迎风左下角第一个元素。
    % M = M(15:-1:1,:);后M(15,1)矩阵左下角第一个元素正好和我的命名匹配
    % 后续A3 = M(15:-1:11,);取出0度第一排迎风光伏板的点，注意此时倒序取，把M(15,:)换到了M(11,:)
    % 对应于A3(1,:)，矩阵视图来看在左上角，但contour时给他的是xmin和ymin
    % 画在plot的左下角，这和光伏板放置方式才匹配
    M = nodeValue*1000; %m -> mm
    M = reshape(M,42,15);
    M = M';
    M = M(15:-1:1,:);
    M2 = blockValue*1000; % m -> mm
    M2 = reshape(M2,28,12);
    M2 = M2';
    M2 = M2(12:-1:1,:);


    % 分割原始矩阵为三个5x42矩阵
    A1 = M(5:-1:1, :);
    A2 = M(10:-1:6, :);
    A3 = M(15:-1:11, :);
    % 分割原始矩阵为三个4x28矩阵
    valueMatrix1 = M2(4:-1:1, :);
    valueMatrix2 = M2(8:-1:5, :);
    valueMatrix3 = M2(12:-1:9, :);
    % 定义目标矩阵的x和y坐标网格，对于每个矩阵进行插值
    [x, y] = meshgrid(node_x,node_y); % node坐标
    [xq, yq] = meshgrid(linspace(node_x(1), node_x(end), 10*numel(node_x)), linspace(node_y(1), node_y(end), 10*numel(node_y))); % 10倍插值后的网格
        
    % 对每个矩阵进行插值
    % 'cubic' 方法要求网格具有一致的间距。
    % 由于不满足此条件，该方法将会从 'cubic' 切换到 'spline'。
    Aq1 = interp2(x, y, A1, xq, yq, 'spline');
    Aq2 = interp2(x, y, A2, xq, yq, 'spline');
    Aq3 = interp2(x, y, A3, xq, yq, 'spline');

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
        hold on;
        
        % 在图上画直线划分区域
        % 绘制竖直方向的直线，偶数直线更粗
        for tx = 1:29
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
    filename = strcat(outputdir,title);
    exportgraphics(gcf, filename, 'Resolution', 300);
end

function plotangle(blockValue,node_x, node_y, outputdir, title)

    M2 = reshape(blockValue,28,12);
    M2 = M2';
    M2 = M2(12:-1:1,:);

    % 分割原始矩阵为三个4x28矩阵
    valueMatrix1 = M2(4:-1:1, :);
    valueMatrix2 = M2(8:-1:5, :);
    valueMatrix3 = M2(12:-1:9, :);
    % 定义目标矩阵的x和y坐标网格，对于每个矩阵进行插值

    [xq, yq] = meshgrid(linspace(node_x(1), node_x(end), 10*numel(node_x)), linspace(node_y(1), node_y(end), 10*numel(node_y))); % 10倍插值后的网格
    
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
        hold on;
        % 在图上画直线划分区域
        % 绘制竖直方向的直线，偶数直线更粗
        for tx = 1:29
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
                text(textX, textY, sprintf('%d', textValue), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 8, 'Color', 'k');
            end
        end
        axis tight;
        axis off;
        hold off;
    end

    %输出保存图片
    filename = strcat(outputdir,title);
    exportgraphics(gcf, filename, 'Resolution', 300);
end