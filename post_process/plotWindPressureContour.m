%% 绘制风振云图
close all;clc;clear;
%% 定义元数据

condition_inclination = ["5度","10度","15度","20度","25度","30度","15度不带撑杆","30度不带撑杆"]; % "15度单跨-空风洞", "15度单跨"还没有做
angle1 = [0:10:180]; % 甲方工况
angle2 = [0:30:180]; % 研究工况

frequence = 312.5;
time = 64;
N = frequence * time;
geometricScale = 7; %windspeedScale;timeScale;protoFreq不知道

% 测压点
CpPointNum = 672;CpPerRow = 28;
CpPointNumPerBoard = 112;
% 光伏板
boardW = 1134; boardL = 2279; boardNum = 42;

%画图属性
imagesize={[10 0 10 20],[10 1 10 10],[10 1 14 10]};
LabelSpacing = 500;
fontSize = 7;
levelStep1 = 0.2;
levelStep2 = 0.025;
levelStep3 = 0.2;
levelStep4 = 0.5;

%% 导入光伏板和测压点坐标
% 定义光伏板左下角点坐标 从尺寸信息.exel读入，或者从boardCornerCoordinates.mat读入
load("../../结构参数统计/boardCornerCoordinates.mat");
boardCornerX = boardCornerX'; % 转成行向量
boardCornerY = boardCornerY'; % 转成行向量

% 计算三排光伏板的角点坐标
boardXmin = min(boardCornerX);boardXmax = max(boardCornerX)+boardW;
board1Ymin = boardCornerY(boardNum/3);board1Ymax = board1Ymin+boardL;
board2Ymin = boardCornerY(2*boardNum/3);board2Ymax = board2Ymin+boardL;
board3Ymin = boardCornerY(boardNum);board3Ymax = board3Ymin+boardL;

% 光伏板内部坐标插值
% 光伏支架内部加密点，作为画云图的新坐标点
xnum = CpPerRow*4; ynum = 3*4;
[xx1,yy1]=meshgrid(linspace(boardXmin,boardXmax,xnum),linspace(board1Ymin,board1Ymax,ynum));
[xx2,yy2]=meshgrid(linspace(boardXmin,boardXmax,xnum),linspace(board2Ymin,board2Ymax,ynum));
[xx3,yy3]=meshgrid(linspace(boardXmin,boardXmax,xnum),linspace(board3Ymin,board3Ymax,ynum));

% 导入测压点坐标 
% 读入重排后的测压点坐标 ，并且因为只有一个面的测点位置，因此只取前一半的坐标

load('../../结构参数统计/CpCoordinates.mat'); % 变量名CpX,CpY
CpX = CpX(1:CpPointNum/2);
CpY = CpY(1:CpPointNum/2);

% 光伏板坐标处理
boardCornerCodnt = [boardCornerX; boardCornerY];
boardWMat = ones(1,boardNum)*boardW;
boardLMat = ones(1,boardNum)*boardL;
rectAll = [boardCornerCodnt; boardWMat; boardLMat]';


%% 

tic
set(0,'DefaultFigureVisible', 'on');%plot不弹窗
for i = condition_inclination([1:2,4:end])
    % 因为不同工况吹的风向角不同
    if i == "15度不带撑杆" || i == "15度单跨" || i == "30度不带撑杆"
        angle = angle2;        
    else
        angle = angle1;        
    end 

    % 导入测压点风压系数统计信息
    inputDir = i;
    inputName = strcat(inputDir,'\','测点风压系数统计数据_net_modified2_插值.mat'); % modified是修正过坏点的
    % ["netnetPressureCoeMean","netPressureCoeStd","netPressureCoeKurt","netPressureCoeSkew"]);
    load(inputName);
    for j = 1:length(angle)
        anglej = angle(j);
        outputDir = strcat('测点平均风压系数等值线图_net\',i,"\");

        % 测压数据重新插值
        % 测压点坐标支架排数分为3组，风压统计系数也同样分为3组
        data1 = griddata(CpX(1:112),CpY(1:112),netPressureCoeMean(1:112,j),xx1,yy1,'v4');
        txtStep1 = [min(min(data1)):0.2:max(max(data1))];
        data2 = griddata(CpX(113:224),CpY(113:224),netPressureCoeMean(113:224,j),xx1,yy1,'v4');
        txtStep2 = [min(min(data2)):0.2:max(max(data2))];
        data3 = griddata(CpX(225:336),CpY(225:336),netPressureCoeMean(225:336,j),xx1,yy1,'v4');
        txtStep3 = [min(min(data3)):0.2:max(max(data3))];
        
        % 路径如果不存在则创建路径
        if ~exist("outputdir", 'dir')
            mkdir(outputDir);
            fprintf('Folder "%s" created successfully.\n', outputDir);
        else
            fprintf('Folder "%s" already exists.\n', outputDir);
        end
        
        %初始化图形窗口
        fig1=figure();
        set(fig1,'color','w');
        set(fig1,'unit','centimeters','position',imagesize{1});
        
        % 画测压点 关闭
        scatter(CpX,CpY,5,'filled','b');
        hold on;
        
        % 画板
        parfor k = 1:boardNum
            recti = rectAll(k,:);
            rectangle('Position', recti, 'LineWidth', 1, 'EdgeColor', 'k');
            hold on
        end
        
        % 画等值线
        txtStep1 = [-1.6 -1.4 -1.2 -1.0 -0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6];
        [cs1,fig1]=contourf(xx1,yy1,data1,'ShowText','on','LabelSpacing',LabelSpacing,'levelStep',0.2,'linewidth',0.3);
%         clabel(cs1, fig1,txtStep1,'FontSize', fontSize, 'Color', 'k','Margin',5,'Fontweight','bold','FontName','TimesNewRome','FontSmoothing','on');
        hold on
        [cs2,fig1]=contourf(xx2,yy2,data2,'ShowText','on','LabelSpacing',LabelSpacing,'levelStep',0.2,'linewidth',0.3);
%         clabel(cs2, fig1,txtStep2,'FontSize', fontSize, 'Color', 'k','Margin',5,'Fontweight','bold','FontName','TimesNewRome','FontSmoothing','on');
        hold on
        [cs3,fig1]=contourf(xx3,yy3,data3,'ShowText','on','LabelSpacing',LabelSpacing,'levelStep',0.2,'linewidth',0.3);
%         clabel(cs3, fig1,txtStep3,'FontSize', fontSize, 'Color', 'k','Margin',5,'Fontweight','bold','FontName','TimesNewRome','FontSmoothing','on');
        hold on
        %设置属性
        colormap white;
        axis off;
        axis equal;
        
        picname = strcat(outputDir,num2str(anglej),'_modified2.fig');
        saveas(fig1,picname);
        picname = strcat(outputDir,num2str(anglej),'_modified2.tiff');
        saveas(fig1,picname);
    end
end
toc
%%
% 第二种画等值线方法，光伏板间不分开插值
% tic
% for i = condition_inclination
%     % 因为不同工况吹的风向角不同
%     if i == "15度不带撑杆" || i == "15度单跨" || i == "30度不带撑杆"
%         angle = angle2;        
%     else
%         angle = angle1;        
%     end 
% 
%     % 导入测压点风压系数统计信息
%     inputDir = i;
%     inputName = strcat(inputDir,'\','测点风压系数统计数据_modified_插值.mat');
%     % ["netnetPressureCoeMean","netPressureCoeStd","netPressureCoeKurt","netPressureCoeSkew"]);
%     load(inputName);
%     for j = 1:length(angle)
%         anglej = angle(j);
%         % 测压数据重新插值
%         % 测压点坐标支架排数分为3组，风压统计系数也同样分为3组
%         data = griddata(CpX,CpY,netnetPressureCoeMean(:,j),[xx1;xx2;xx3],[yy1;yy2;yy3],'v4');
%         txtStep1 = [min(min(data)):0.2:max(max(data))];
%         outputDir = strcat(i,'\测点平均风压系数等值线图\');
%         % 路径如果不存在则创建路径
%         if ~exist("outputDir", 'dir')
%             mkdir(outputDir);
%             fprintf('Folder "%s" created successfully.\n', outputDir);
%         else
%             fprintf('Folder "%s" already exists.\n', outputDir);
%         end
%         fig1=figure();
%         set(fig1,'color','w');
%         % set(fig1,'unit','centimeters','position',imagesize{1});
%         
%         % 画测压点 关闭
% %         scatter(CpX,CpY,5,'filled','b');
% %         hold on;
%         
%         % 画板
%         parfor k = 1:boardNum
%             recti = rectAll(k,:);
%             rectangle('Position', recti, 'LineWidth', 1, 'EdgeColor', 'k');
%             hold on
%         end
%         
%         % 画等值线
%         [cs1,fig1]=contourf(xx1,yy1,data(1:ynum,:),'ShowText','on','LabelSpacing',LabelSpacing,'levelStep',0.2,'linewidth',0.3);
%         hold on
% %         clabel(cs1, fig1,txtStep1,'FontSize', fontSize, 'Color', 'k','Margin',5,'Fontweight','bold','FontName','TimesNewRome','FontSmoothing','on');
%         [cs2,fig1]=contourf(xx2,yy2,data(ynum+1:2*ynum,:),'ShowText','on','LabelSpacing',LabelSpacing,'levelStep',0.2,'linewidth',0.3);
%         hold on
% %         clabel(cs2, fig1,txtStep1,'FontSize', fontSize, 'Color', 'k','Margin',5,'Fontweight','bold','FontName','TimesNewRome','FontSmoothing','on');
%         [cs3,fig1]=contourf(xx3,yy3,data(ynum*2+1:3*ynum,:),'ShowText','on','LabelSpacing',LabelSpacing,'levelStep',0.2,'linewidth',0.3);
%         hold on
% %         clabel(cs3, fig1,txtStep1,'FontSize', fontSize, 'Color', 'k','Margin',5,'Fontweight','bold','FontName','TimesNewRome','FontSmoothing','on');        %设置属性
%         colormap white;
%         axis off;
%         axis equal;
%         
%         picname = strcat(outputDir,num2str(anglej),'_modified_不分排','.fig');
%         saveas(fig1,picname);
%         picname = strcat(outputDir,num2str(anglej),'_modified_不分排','.tiff');
%         saveas(fig1,picname);
%     end
% end
% toc
%%
function plotRect(xmin,xmax,ymin,ymax)
    plot([xmin,xmax,xmax,xmin,xmin],[ymin,ymin,ymax,ymax,ymin],'-r')
end









