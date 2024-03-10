%% define some parameter
clc;
clear;

condition_inclination = ["5度","10度","15度","20度","25度","30度","15度不带撑杆","30度不带撑杆"]; % "15度单跨-空风洞", "15度单跨"还没有做
ww = 0:10:180;

inclination=30;
wangle = 30;
nnum = 630;
timestep = 10;
nnodestart=101;
NVAR = 3;
outputdir = strcat("D:/Photovoltaic_system/apdl_fengzhen_result/",num2str(inclination),"inclination/");
%% open the file
% 打开文件准备写入，'w'表示写入模式，如果文件已存在会被覆盖
inputPath = strcat('');
filename = 'getresultfromapdl.txt';
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
outputfilename =  strcat("*CFOPEN,",outputdir,"UZ_",num2str(wangle),",txt");
fprintf(fileID,outputfilename);
fprintf(fileID,"\n");
fprintf(fileID,"nnode=%d\n",nnodestart);
fprintf(fileID,"*do, i, 1, %d, 1\n",nnum);
fprintf(fileID,"NSOL,%2d,nnode,U,Z, uz_variable\n",NVAR);
fprintf(fileID,"*DIM,uz_parameter,ARRAY,%5d,1\n",timestep);
fprintf(fileID,"VGET,uz_parameter,%2d\n", NVAR);
fprintf(fileID,"*VWRITE,uz_parameter(1,1)\n");
fprintf(fileID,"(F10.5)\n");
fprintf(fileID,"*del,uz_parameter\n");
fprintf(fileID,"VARDEL,%2d\n",NVAR);
fprintf(fileID,"nnode=ndnext(nnode)\n"); % 获取下一个节点编号
fprintf(fileID,"*enddo\n");
fprintf(fileID,"*CFCLOSE\n");

%% close the file
fclose(fileID);