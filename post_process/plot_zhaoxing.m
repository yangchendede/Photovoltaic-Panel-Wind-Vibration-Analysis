inputpath = "D:/Photovoltaic_system/apdl_fengzhen_result/找形/";
nodez = readmatrix(fullfile(inputpath,"nodeZ.txt"));
matrix_z = (reshape(nodez,42,15))';
matrix_z1 = matrix_z(1:5,:);
load("../model/panelnodeall.mat");
node_x = panelx_all(1:42);
node_y = panely_all(1:42:5*42);

[x, y] = meshgrid(node_x,node_y); % node坐标
[xq, yq] = meshgrid(linspace(node_x(1), node_x(end), 10*numel(node_x)), linspace(node_y(1), node_y(end), 10*numel(node_y))); % 10倍插值后的网格
matrixq_z1 = interp2(x, y, matrix_z1, xq, yq, 'spline');
mesh(xq,yq,matrixq_z1);
