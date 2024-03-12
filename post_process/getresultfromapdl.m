%% define some parameter
clc;
clear;

condition_inclination = ["5度","10度","15度","20度","25度","30度","15度不带撑杆","30度不带撑杆"]; % "15度单跨-空风洞", "15度单跨"还没有做
ww = 0:10:180;
condition_inclinationEn = [5,10,15,20,25,30];

nnum = 630;
timestep = 2800;
nnodestart=101;
NVAR = 3;

conditionNu = 1;
condition = condition_inclinationEn(conditionNu);

outputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(condition),"inclination/");

outputparameter = ["UX","UY","UZ"];
%% open the file
% 打开文件准备写入，'w'表示写入模式，如果文件已存在会被覆盖
for w = ww
    inputPath = strcat('');
    filename = strcat("getresultfromapdl",num2str(condition),"inclination",num2str(w),"windangle",".txt");
    fileName = strcat(inputPath,'',filename);
    fileID = fopen(fileName, 'w');
    % 检查文件是否成功打开（fileID是否大于3）
    if fileID == -1
        error('File cannot be opened');
    end
    fprintf(fileID, "\n!*********************!\n");
    fprintf(fileID, "! get time history result\n");
    fprintf(fileID, "!*********************!\n");
    fprintf(fileID, "/post26\n");
    for i = 1:numel(outputparameter)
        fprintf(fileID, "\n!*********************!\n");
        para = outputparameter(i);
        outputfilename =  strcat("*CFOPEN,",outputdir,para,"_",num2str(w),",txt");
        fprintf(fileID,outputfilename);
        fprintf(fileID,"\n");
        fprintf(fileID,"nnode=%d\n",nnodestart);
        fprintf(fileID,"*do, i, 1, %d, 1\n",nnum);
        switch para
            case "UZ"
                fprintf(fileID,"NSOL,%2d,nnode,U,Z, variable\n",NVAR);
            case "UY"
                fprintf(fileID,"NSOL,%2d,nnode,U,Y, variable\n",NVAR);
            case "UX"
                fprintf(fileID,"NSOL,%2d,nnode,U,X, variable\n",NVAR);
        end
        fprintf(fileID,"*DIM,parameter,ARRAY,%5d,1\n",timestep);
        fprintf(fileID,"VGET,parameter,%2d\n", NVAR);
        fprintf(fileID,"*VWRITE,parameter(1,1)\n");
        fprintf(fileID,"(F10.5)\n");
        fprintf(fileID,"*del,parameter\n");
        fprintf(fileID,"VARDEL,%2d\n",NVAR);
        fprintf(fileID,"nnode=ndnext(nnode)\n"); % 获取下一个节点编号
        fprintf(fileID,"*enddo\n");
        fprintf(fileID, "*CFCLOSE\n");
    end
    fprintf(fileID, "finish\n");
    %% close the file
    fclose(fileID);
end