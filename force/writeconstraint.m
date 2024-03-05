%% use matlab to build the apdl model's constraint

%% read node's number which need to be constrained
clear;
temp = load("columnNodeNumber.mat");
constrainednodeset = temp.columnnodenumber;
clear temp;

%% open the file
% 打开文件准备写入，'w'表示写入模式，如果文件已存在会被覆盖
inputPath = strcat(['']);
filename = 'constraint.txt';
fileName = strcat(inputPath,'',filename);
fileID = fopen(fileName, 'w');

% 检查文件是否成功打开（fileID是否大于3）
if fileID == -1
    error('File cannot be opened');
end

%% write the constraint

fprintf(fileID, "\n!*********************!\n");
fprintf(fileID, "!establish the constraint\n");
fprintf(fileID, "!*********************!\n");
fprintf(fileID, "/SOL\n");

% select constrained node set
fprintf(fileID, 'NSEL,S,NODE,,%5d\n', 1);
for nodeNumber = 2:numel(constrainednodeset)
    fprintf(fileID, 'NSEL,A,NODE,,%5d\n', nodeNumber);
end

% add constraint to node set
fprintf(fileID, 'D,ALL,ALL\n');

%% close the file
fclose(fileID);