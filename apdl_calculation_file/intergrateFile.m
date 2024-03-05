% Open setup.txt, defineElementTypeConstantMaterial.txt, geometry.txt, constraint.txt for reading
fid1 = fopen(strcat('../model/','setup.txt'), 'r');
fid2 = fopen(strcat('../model/','defineElementTypeConstantMaterial.txt'), 'r');
fid3 = fopen(strcat('../model/','geometry.txt'), 'r');
fid4 = fopen(strcat('../force/','constraint.txt'), 'r');

% Open a file for writing the combined content
fid5 = fopen('intergratedFile.txt', 'w');

% Read and write file1 content
content = fread(fid1, '*char')';
fwrite(fid5, content);

% Read and write file2 content
content = fread(fid2, '*char')';
fwrite(fid5, content);

% Read and write file3 content
content = fread(fid3, '*char')';
fwrite(fid5, content);

% Read and write file4 content
content = fread(fid4, '*char')';
fwrite(fid5, content);

% Close all file identifiers
fclose('all');