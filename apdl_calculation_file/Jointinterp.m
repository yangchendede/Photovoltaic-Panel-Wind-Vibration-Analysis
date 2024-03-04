
% x,y采样点坐标,读入
% x1,y1加载点坐标，读入
%n为点数量
%cp是采样点值 读入每个测点的时程，一行为一点的时程；
cp=
n=size(cp,2);%列长度,点个数
load_knot=ones(size(x1,1),n)*NaN;%置空
 for i=1:n
        F=scatteredInterpolant(x,y,cp(:,i),linear);
        load_knot(:,i)=F(x1,y1);%给加载点返回数值
 end