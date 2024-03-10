clc;
clear all
close all

g=2.5;
phi=0.25;

%200阶计算结果
Num_angle=36;   %参与计算风向角的个数
for ang=1:Num_angle
    file=['G:\武汉图书馆\2 风振时程分析\Results\disp_accl1/',num2str((ang-1)*10),'out_200阶.txt'];
    data=load(file,'-ascii');
    accl_avg(:,:,ang)=data(:,1:3);%单位mm/s2，单位通过模型中输出去查
    accl_std(:,:,ang)=data(:,4:6);%单位mm/s2
    disp_avg(:,:,ang)=data(:,7:9);%单位mm
    disp_std(:,:,ang)=data(:,10:12);%单位mm
    F_avg(:,:,ang)=data(:,13:15);%单位N
    F_std(:,:,ang)=data(:,16:18);%单位N
    mass(:,:,ang)=data(:,19:21);%单位N/(mm/s2)   1kn=1000kg*1m/s2,
end
%计算各向力所占的比例
areacoe=abs(F_avg)./repmat(sum(abs(F_avg),2),1,3,1); %B = repmat(A,m,n)，其功能是以A的内容堆叠在（MxN）的矩阵B中
% b=sum(a,dim); a表示矩阵；dim等于1或者2，1表示每一列进行求和，2表示每一行进行求和
Num=length(data(:,1,1));  %节点数
%位移风振系数
vibcoe_disp3=1+g.*disp_std./abs(disp_avg);
%函数语法为B = reshape(A,size)是指返回一个和A元素相同的n维数组，但是由向量size来决定重构数组维数的大小
vibcoe_disp=reshape(sum(vibcoe_disp3.*areacoe,2),Num,Num_angle);
%荷载风振系数
vibcoe_force3=1+g.*sqrt((mass.*accl_std).^2+(phi.*F_std).^2)./abs(F_avg);
vibcoe_force=reshape(sum(vibcoe_force3.*areacoe,2),Num,Num_angle);
vibcoe=min(vibcoe_disp,vibcoe_force);

% 修正风振系数
for ang=1:Num_angle
    vib=vibcoe(:,ang);
    maxcoe=max(vib);
    big=vib>3;   %输出vib中大于3的值，如果是大于三  输出1  否者输出0
    vib(big)=3+vib(big)./(3*(maxcoe+1));
    vibcoe(:,ang)=vib;
end
%节点等效风荷载,就是力的平均乘以风振系数
equiv_Fx=reshape(F_avg(:,1,:),[Num,Num_angle]).*vibcoe;
equiv_Fy=reshape(F_avg(:,2,:),[Num,Num_angle]).*vibcoe;
equiv_Fz=reshape(F_avg(:,3,:),[Num,Num_angle]).*vibcoe;

%计算不同风向角风振系数最大最小值，
[maxvib,maxind]=max(vibcoe,[],2);   %对行取最大最小值来得到
[minvib,minind]=min(vibcoe,[],2);   
maxang=(maxind-1)*10;%最大值对应的风向角
minang=(minind-1)*10;%最小值对应的风向角
%体型系数最大最小表
mmvib_chart=table(maxvib,maxang,minvib,minang); %最大风振系数，对应最大风振系数风向角，最小风振系数，对应最小风振系数风向角
% 
% save('G:/武汉图书馆/2 风振时程分析/风振分析后处理/codes/mat_files/results200-1.mat','accl_avg','accl_std','disp_avg','disp_std','F_avg','F_std','mass','equiv_Fx','equiv_Fy','equiv_Fz');
% save('G:/武汉图书馆/2 风振时程分析/风振分析后处理/codes/mat_files/vib_coe200-1.mat','vibcoe','vibcoe_disp3','vibcoe_disp','vibcoe_force3','vibcoe_force','mmvib_chart');





