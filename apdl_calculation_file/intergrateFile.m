% Open setup.txt, defineElementTypeConstantMaterial.txt, geometry.txt, constraint.txt for reading
fid1 = fopen(strcat('../model/','setup.txt'), 'r');
fid2 = fopen(strcat('../model/','defineElementTypeConstantMaterial.txt'), 'r');
fid3 = fopen(strcat('../model/','geometry.txt'), 'r');
fid4 = fopen(strcat('../force/','constraint.txt'), 'r');
fid5 = fopen(strcat('../preAnalysis/','zhaoxing.txt'), 'r');

% Open a file for writing the combined content
fidfina = fopen('intergratedFile.txt', 'w');

% Read and write file1 content
content = fread(fid1, '*char')';
fwrite(fidfina, content);

% Read and write file2 content
content = fread(fid2, '*char')';
fwrite(fidfina, content);

% Read and write file3 content
content = fread(fid3, '*char')';
fwrite(fidfina, content);

% Read and write file4 content
content = fread(fid4, '*char')';
fwrite(fidfina, content);

% Read and write file4 content
content = fread(fid5, '*char')';
fwrite(fidfina, content);

% Close all file identifiers
fclose('all');