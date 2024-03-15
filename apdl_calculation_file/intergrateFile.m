% 分析模式
analysisoptions = ["zhaoxing","modalAnalysis","transientAnalysis"];
analysisMode = analysisoptions(3);

% 工况选择
condition_inclination = ["5度","10度","15度","20度","25度","30度","15度不带撑杆","30度不带撑杆"]; % "15度单跨-空风洞", "15度单跨"还没有做
ww = 0:10:180;
condition_inclinationEn = [5,10,15,20,25,30];
conditionNu = 5;
condition = condition_inclinationEn(conditionNu);

for w = ww
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
        loadfilename = strcat("../force/loadhistory",num2str(condition),"inclination",num2str(w),"windangle",".txt");
        getresultfilename = strcat("../post_process/getresultfromapdl",num2str(condition),"inclination",num2str(w),"windangle",".txt");
        filelist = ["../model/setup.txt", "../model/defineElementTypeConstantMaterial.txt", ...
                    "../model/geometry.txt", "../force/constraint.txt", ...
                    "../preAnalysis/zhaoxingNoemat.txt", "../transientAnalysis/fulloptionsLargeDeform.txt", ...
                    loadfilename, getresultfilename];
        writeflag = 1;
    else
        fprintf("Not allowed analysis mode\n");
        writeflag = 0;   
    end
    
    if writeflag == 1
        % Open a file for writing the combined content
        outputfilename = strcat("intergratedFile",num2str(condition),"inclination",num2str(w),"windangle",".txt");
        fidfina = fopen(outputfilename, 'w');
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

end