% Open a file for writing the combined content
fidfina = fopen('intergratedFile.txt', 'w');

% Save file names in order
filelist = ["../model/setup.txt", "../model/defineElementTypeConstantMaterial.txt", ...
            "../model/geometry.txt", "../force/constraint.txt", ...
            "../preAnalysis/zhaoxing.txt", "../modalAnalysis/modalAnalysis.txt"];

% Read and write file content
for fileN = 1: numel(filelist)
    file = fopen(filelist(fileN), 'r');
    content = fread(file, '*char')';
    fwrite(fidfina, content);
end

% Close all file identifiers
fclose('all');