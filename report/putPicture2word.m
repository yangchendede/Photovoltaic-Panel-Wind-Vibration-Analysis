% 定义包含图片的文件夹路径
picturePath = "D:\Photovoltaic_system\apdl_fengzhen_result\30inclination\equalWindForce"; % 请替换为实际路径
% 定义你要追加内容的Word文档路径
docPath = 'D:\Photovoltaic_system\Photovoltaic-Panel-Wind-Vibration-Analysis\report\equalWindForce.docx'; % 请替换为实际Word文档路径
title_all = "光伏支架30度倾角";


% 启动Word应用程序
wordApp = actxserver('Word.Application');
wordApp.Visible = true;

% 打开现有的Word文档
if exist(docPath, 'file') == 2 % 确保文件存在
    doc = wordApp.Documents.Open(docPath);
else
    disp('文件不存在，创建新文档。');
    doc = wordApp.Documents.Add;
end

% 将插入点移动到文档末尾
wordApp.Selection.EndKey(6)

% 获取文件夹内所有图片文件的信息
images = dir(fullfile(picturePath, '*.png')); % 假设图片为PNG格式，根据需要修改


% 遍历所有图片文件
for i = 1:length(images)
    % 读取图片
    imgPath = fullfile(picturePath, images(i).name);
    img = imread(imgPath);
    
    % 旋转并放大图片
    imgRotated = imrotate(img, 90); % 顺时针旋转90度
    imgScaled = imresize(imgRotated, 1.2); % 放大1.2倍
    
    % 临时保存处理后的图片
    tempImgPath = fullfile(picturePath, ['temp_', images(i).name]);
    imwrite(imgScaled, tempImgPath);
    
    % 插入图片到Word文档
    selection = wordApp.Selection;
    selection.EndKey; % 移动到文档末尾
    selection.InlineShapes.AddPicture(tempImgPath);
    selection.TypeParagraph; % 在图片下方创建一个新段落
    
    % 插入并居中文件名
        title = strcat(title_all, images(i).name,"度法向等效静力风荷载 (kPa)");
    selection.TypeText(title);
    selection.ParagraphFormat.Alignment = 1; % 居中对齐
    selection.TypeParagraph; % 在文件名下方创建一个新段落
    
    % 删除临时图片文件
    delete(tempImgPath);
end

% 保存并关闭文档
doc.Save;
doc.Close;

% 清理COM服务器
wordApp.Quit;
delete(wordApp);