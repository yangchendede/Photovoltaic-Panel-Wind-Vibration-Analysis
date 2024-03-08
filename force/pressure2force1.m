%% 本程序用于生成风力时程
clear
clc
close all
area=xlsread('....xlsx','sheet1');
% block_info=xlsread('..\测点坐标.xlsx','fenkuai');
% points=xlsread('..\测点坐标.xlsx','top');
windpressureFB=zeros(10000,7920);
windpressureCK=zeros(10000,7920);
angle_vector=[0 15 30 45 60 75 90 105 120 135 150 165 180 195 210 225 240 255 270 285 300 315 330 345];
datanum=10000;
for num=1:24
m=330*(num-1)+1;
n=330*num;
    vangles=angle_vector(num)
    filename1=strcat(['...',num2str(vangles),'.txt']);
    filename2=strcat(['...',num2str(vangles),'.txt']);
    windpressureFB(:,m:n)=load(filename1);
    windpressureCK(:,m:n)=load(filename2);
    windforceFBy(:,m:n)=windpressureFB(:,m:n).*area(1,:);
    windforceFBz(:,m:n)=0.85(windpressureFB(:,m:n).*area(2,:));
    windforceCKy(:,m:n)=windpressureCK(:,m:n).*area(1,:);
    windforceCKz(:,m:n)=0.85*(windpressureCK(:,m:n).*area(2,:));
end

for num=1:24
m=330*(num-1)+1;
n=330*num;
    wind_forceCKz(:,m:n)=0.85*(windpressureCK(:,m:n).*area(2,:));
    wind_forceFBz(:,m:n)=0.85*(windpressureFB(:,m:n).*area(2,:));
end

for i=1:7920
%     mean_forceFBy(:,i)=mean(windforceFBy(:,i));
    mean_forceFBz(:,i)=mean(windforceFBz(:,i));
%     mean_forceCKy(:,i)=mean(windforceCKy(:,i));
    mean_forceCKz(:,i)=mean(wind_forceCKz(:,i));
%     std_forceFBy(:,i)=std(windforceFBy(:,i));
     std_forceFBz(:,i)=std(windforceFBz(:,i));
%     std_forceCKy(:,i)=std(windforceCKy(:,i));
    std_forceCKz(:,i)=std(wind_forceCKz(:,i));
end

 %% 荷载风振系数计算
    g=2.5;%
   cc=0.25;% 脉动风压参与系数cc=0.25
    for j=1:7920 
%         ll=1000*abs(meanforce_xA(1,j));
        ml1=1000*abs(mean_forceCKy(1,j));%定义成mat文件
        nl1=1000*abs(mean_forceCKz(1,j));
        ml2=1000*abs(mean_forceCKy(1,j));%定义成mat文件
        nl2=1000*abs(mean_forceCKz(1,j));
%         if ll==0
%             vib_coe_xlA(1,j)=1;
%         else
%             vib_coe_xlA(1,j)=1+g*sqrt((cc*(1000*stdforce_xA(1,j)))^2)/ll;
%         end
        if ml1==0
            vib_coe_ylACK(1,j)=1;
            vib_coe_ylAFB(1,j)=1;
        else
            vib_coe_ylACK(1,j)=1+g*sqrt((cc*(1000*std_forceCKy(1,j)))^2)/ml1;
            vib_coe_ylAFB(1,j)=1+g*sqrt((cc*(1000*std_forceFBy(1,j)))^2)/ml2; 
        end
        if nl1==0
            vib_coe_zlACK(1,j)=1;
            vib_coe_zlAFB(1,j)=1;
        else
            vib_coe_zlACK(1,j)=1+g*sqrt((cc*(1000*std_forceCKz(1,j)))^2)/nl1;
            vib_coe_zlAFB(1,j)=1+g*sqrt((cc*(1000*std_forceFBz(1,j)))^2)/nl2; 
        end
    end
     
    for num2=1:24
        a=330*(num2-1)+1;
        b=330*num2;
   vibcoeFinalcky(num2,:)=vib_coe_ylACK(:,a:b);
   vibcoeFinalckz(num2,:)=vib_coe_zlACK(:,a:b);
    end
    for num3=1:24
        for j=1:330
      vib_coe_loadACK(num3,j)=(vibcoeFinalcky(num3,j)*area(j,1)+vibcoeFinalckz(num3,j)*area(j,2))/AREA(j,1);
        end
    end

    
     %% 荷载风振系数计算
    g=2.5;%
   cc=0.25;% 脉动风压参与系数cc=0.25
    for j=1:7920 
        ml2=1000*abs(mean_forceFBy(1,j));%定义成mat文件
        nl2=1000*abs(mean_forceFBz(1,j));
        if ml2==0
            vib_coe_ylAFB(1,j)=1;
        else
            vib_coe_ylAFB(1,j)=1+g*sqrt((cc*(1000*std_forceFBy(1,j)))^2)/ml2; 
        end
        if nl2==0
            vib_coe_zlAFB(1,j)=1;
        else
            vib_coe_zlAFB(1,j)=1+g*sqrt((cc*(1000*std_forceFBz(1,j)))^2)/nl2; 
        end
    end
     
    for num2=1:24
        a=330*(num2-1)+1;
        b=330*num2;
   vibcoeFinalfby(num2,:)=vib_coe_ylAFB(:,a:b);
   vibcoeFinalfbz(num2,:)=vib_coe_zlAFB(:,a:b);
    end
    for num3=1:24
        for j=1:330
      vib_coe_loadAFB(num3,j)=(vibcoeFinalfby(num3,j)*area(j,1)+vibcoeFinalfbz(num3,j)*area(j,2))/AREA(j,1);
        end
    end
    
   for num2=1:24
        a=330*(num2-1)+1;
        b=330*num2;
   meanforceCKz(num2,:)=mean_forceCKz(1,a:b);
   stdforceCKz(num2,:)=std_forceCKz(1,a:b);
   meanforceFBz(num2,:)=mean_forceFBz(1,a:b);
   stdforceFBz(num2,:)=std_forceFBz(1,a:b);
   end
   
    for i=1:24
        for j=1:330        
    equi_forceCKz(i,j)=meanforceCKz(i,j)+stdforceCKz(i,j);
     equi_forceFBz(i,j)=meanforceFBz(i,j)+stdforceFBz(i,j);
        end
    end
    
    for i=1:24
        for j=1:330 
%     mean_forceFBy(:,i)=mean(windforceFBy(:,i));
    mean_forceFBz(:,i)=mean(windforceFBz(:,i));
%     mean_forceCKy(:,i)=mean(windforceCKy(:,i));
%     meanforce(:,i)=mean(wind_forceCKz(:,i));
%     std_forceFBy(:,i)=std(windforceFBy(:,i));
    std_forceFBz(:,i)=std(windforceFBz(:,i));
%     std_forceCKy(:,i)=std(windforceCKy(:,i));
%     stdforce(:,i)=std(wind_forceCKz(:,i));
        end
end