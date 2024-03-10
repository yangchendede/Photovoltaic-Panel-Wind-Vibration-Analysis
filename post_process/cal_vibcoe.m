clc;
clear all
close all

g=2.5;
phi=0.25;

%200�׼�����
Num_angle=36;   %����������ǵĸ���
for ang=1:Num_angle
    file=['G:\�人ͼ���\2 ����ʱ�̷���\Results\disp_accl1/',num2str((ang-1)*10),'out_200��.txt'];
    data=load(file,'-ascii');
    accl_avg(:,:,ang)=data(:,1:3);%��λmm/s2����λͨ��ģ�������ȥ��
    accl_std(:,:,ang)=data(:,4:6);%��λmm/s2
    disp_avg(:,:,ang)=data(:,7:9);%��λmm
    disp_std(:,:,ang)=data(:,10:12);%��λmm
    F_avg(:,:,ang)=data(:,13:15);%��λN
    F_std(:,:,ang)=data(:,16:18);%��λN
    mass(:,:,ang)=data(:,19:21);%��λN/(mm/s2)   1kn=1000kg*1m/s2,
end
%�����������ռ�ı���
areacoe=abs(F_avg)./repmat(sum(abs(F_avg),2),1,3,1); %B = repmat(A,m,n)���书������A�����ݶѵ��ڣ�MxN���ľ���B��
% b=sum(a,dim); a��ʾ����dim����1����2��1��ʾÿһ�н�����ͣ�2��ʾÿһ�н������
Num=length(data(:,1,1));  %�ڵ���
%λ�Ʒ���ϵ��
vibcoe_disp3=1+g.*disp_std./abs(disp_avg);
%�����﷨ΪB = reshape(A,size)��ָ����һ����AԪ����ͬ��nά���飬����������size�������ع�����ά���Ĵ�С
vibcoe_disp=reshape(sum(vibcoe_disp3.*areacoe,2),Num,Num_angle);
%���ط���ϵ��
vibcoe_force3=1+g.*sqrt((mass.*accl_std).^2+(phi.*F_std).^2)./abs(F_avg);
vibcoe_force=reshape(sum(vibcoe_force3.*areacoe,2),Num,Num_angle);
vibcoe=min(vibcoe_disp,vibcoe_force);

% ��������ϵ��
for ang=1:Num_angle
    vib=vibcoe(:,ang);
    maxcoe=max(vib);
    big=vib>3;   %���vib�д���3��ֵ������Ǵ�����  ���1  �������0
    vib(big)=3+vib(big)./(3*(maxcoe+1));
    vibcoe(:,ang)=vib;
end
%�ڵ��Ч�����,��������ƽ�����Է���ϵ��
equiv_Fx=reshape(F_avg(:,1,:),[Num,Num_angle]).*vibcoe;
equiv_Fy=reshape(F_avg(:,2,:),[Num,Num_angle]).*vibcoe;
equiv_Fz=reshape(F_avg(:,3,:),[Num,Num_angle]).*vibcoe;

%���㲻ͬ����Ƿ���ϵ�������Сֵ��
[maxvib,maxind]=max(vibcoe,[],2);   %����ȡ�����Сֵ���õ�
[minvib,minind]=min(vibcoe,[],2);   
maxang=(maxind-1)*10;%���ֵ��Ӧ�ķ����
minang=(minind-1)*10;%��Сֵ��Ӧ�ķ����
%����ϵ�������С��
mmvib_chart=table(maxvib,maxang,minvib,minang); %������ϵ������Ӧ������ϵ������ǣ���С����ϵ������Ӧ��С����ϵ�������
% 
% save('G:/�人ͼ���/2 ����ʱ�̷���/�����������/codes/mat_files/results200-1.mat','accl_avg','accl_std','disp_avg','disp_std','F_avg','F_std','mass','equiv_Fx','equiv_Fy','equiv_Fz');
% save('G:/�人ͼ���/2 ����ʱ�̷���/�����������/codes/mat_files/vib_coe200-1.mat','vibcoe','vibcoe_disp3','vibcoe_disp','vibcoe_force3','vibcoe_force','mmvib_chart');





