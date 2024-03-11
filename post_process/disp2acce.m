% 实验参数

dt = 0.014467529591616;

% apdl计算参数2800
timeNum = 2800;

%%

% 假设你的数据文件名为 'data.txt'
% n 和 m 分别是目标矩阵的行数和列数
inclination=30;
wangle = 30;
nnum = 630;
timestep = 2800;
output_timestep = 2800-2;
inputparameter = ["UZ"];


inputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/");
outputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/");
for i = 1:numel(inputparameter)
    para = inputparameter(i);
    filename = strcat(inputdir,para,"_",num2str(wangle),".txt");
    fileID = fopen(filename,'r');
    formatSpec = '%f';
    data = fscanf(fileID,formatSpec);
    fclose(fileID);
    % 注意这里假设原始数据就是一列，所以直接使用 reshape
    disp_matrix = reshape(data, [timestep, nnum]);
    % 计算第一次差分（速度）
    velo_matrix = diff(disp_matrix, 1, 1) / dt; %少一行
    % 计算第二次差分（加速度）
    acce_matrix = diff(velo_matrix, 1, 1) / dt; %少一行
    %认为加速度第一行对应于第二个时间步，最后一行对应倒数第二个时间步，因此对应修改disp_matrix的大小
    disp_matrix = disp_matrix(2:end-1,:);
    velo_matrix = velo_matrix(2:end,:);
    % 第3步：将矩阵写入新的TXT文件
    newFileName = strcat(outputdir,"matrix_",para,"_",num2str(wangle),".csv");
    writematrix(disp_matrix,newFileName);

    newFileName2 = strcat(outputdir,"matrix_","veloZ_",num2str(wangle),".csv");
    velo_matrix = arrayfun(@(x) sprintf('%.5f', x), velo_matrix, 'UniformOutput', false);
    writecell(velo_matrix,newFileName2);

    newFileName3 = strcat(outputdir,"matrix_","acceZ_",num2str(wangle),".csv");
    acce_matrix = arrayfun(@(x) sprintf('%.5f', x), acce_matrix, 'UniformOutput', false);
    writecell(acce_matrix,newFileName3);
end