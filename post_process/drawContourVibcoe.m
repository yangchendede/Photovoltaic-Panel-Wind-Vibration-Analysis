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
for inclinationN = 1:numel(inclinationlist)
    inclination = inclinationlist(inclinationN);
    
    
    % input output dir
    inputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/", "vibCoe/");
    outputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/", "vibCoePic/");
    % 检查输出路径是否存在，如果不存在，则创建
    if ~exist(outputdir, 'dir')
        mkdir(outputdir);
    end
    
    %node contour: meshgrid 用的node的xy坐标
    load("../model/panelnodeall.mat");
    node_x = panelx_all(1:42);
    node_y = panely_all(1:42:210);
    
    directionlist = ["Z_"];
    
    for wangle = 1:numel(ww)
        w = ww(wangle);
        for direct = directionlist
            inputfilename = strcat(inputdir,"vibCoe",direct,num2str(w), ".csv");
            nodevibCoe = readmatrix(inputfilename);
            % 读取优化后的630node和336block结果
            inputfilename1 = strcat(inputdir,"node630OptimVibCoe",direct,num2str(w), ".csv");
            inputfilename2 = strcat(inputdir,"block336OptimVibCoe",direct,num2str(w), ".csv");
            nodeOptimvibCoe = readmatrix(inputfilename1);
            % 用block结果插值的图不好，不运行
            blockvibCoe = readmatrix(inputfilename2);
            % plot contour picture to check
            directp = "Z";
%             drawblockvibCoe(blockvibCoe,w,direct)
            drawnodevibCoe(nodeOptimvibCoe, blockvibCoe, w,directp,node_x,node_y, outputdir);
    %         checkblockvibCoe(blockvibCoe,w,direct);
        end
    end
end
function drawblockvibCoe(blockvibCoe,w,direct)
    M = reshape(blockvibCoe,28,12);
    M = M';
    M = M(12:-1:1,:);

    % 分割原始矩阵为三个4x28矩阵
    A1 = M(4:-1:1, :);
    A2 = M(8:-1:5, :);
    A3 = M(12:-1:9, :);

    % 定义目标矩阵的x和y坐标网格，对于每个矩阵进行插值
    [x, y] = meshgrid(1:28, 1:4); % y轴插值从1到4，分成40个点
    [xq, yq] = meshgrid(linspace(1, 28, 280), linspace(1, 4, 40)); % 插值后的网格
        
    % 对每个矩阵进行插值
    Aq1 = interp2(x, y, A1, xq, yq, 'spline');
    Aq2 = interp2(x, y, A2, xq, yq, 'spline');
    Aq3 = interp2(x, y, A3, xq, yq, 'spline');
    
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

function drawnodevibCoe(nodevibCoe,blockvibCoe, w,direct,node_x, node_y, outputdir)
    M = reshape(nodevibCoe,42,15);
    M = M';
    M = M(15:-1:1,:);

    M2 = reshape(blockvibCoe,28,12);
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
    title = strcat("vibCoePic", direct, num2str(w), ".png");
    filename = strcat(outputdir,title);
    exportgraphics(gcf, filename, 'Resolution', 300);
end