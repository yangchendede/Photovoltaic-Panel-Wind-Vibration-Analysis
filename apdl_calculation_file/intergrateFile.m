analysisoptions = ["zhaoxing","modalAnalysis","transientAnalysis"];

analysisMode = analysisoptions(3);

writeflag = 0;
% Save file names in order
if analysisMode == "zhaoxing"
    filelist = ["../model/setup.txt", "../model/defineElementTypeConstantMaterial.txt", ...
                "../model/geometry.txt", "../force/constraint.txt", ...
                "../preAnalysis/zhaoxingNoemat.txt"];
    writeflag = 1;
elseif analysisMode == "modalAnalysis"
    filelist = ["../model/setup.txt", "../model/defineElementTypeConstantMaterial.txt", ...
                "../model/geometry.txt", "../force/constraint.txt", ...
                "../preAnalysis/zhaoxing.txt", "../modalAnalysis/modalAnalysis.txt"];
    writeflag = 1;
elseif analysisMode == "transientAnalysis"
    filelist = ["../model/setup.txt", "../model/defineElementTypeConstantMaterial.txt", ...
                "../model/geometry.txt", "../force/constraint.txt", ...
                "../preAnalysis/zhaoxingNoemat.txt", "../transientAnalysis/fulloptionsLargeDeform.txt", ...
                "../force/loadhistory.txt"];
    writeflag = 1;
else
    fprintf("Not allowed analysis mode\n");
    writeflag = 0;   
end

if writeflag == 1
    % Open a file for writing the combined content
    fidfina = fopen("intergratedFile.txt", 'w');
    % Read and write file content
    for fileN = 1: numel(filelist)
        file = fopen(filelist(fileN), 'r');
        content = fread(file, '*char')';
        fwrite(fidfina, content);
    end
    % Close all file identifiers
    fclose('all');
else
    ...
end