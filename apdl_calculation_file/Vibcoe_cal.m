%%计算分块位移及荷载风振系数

%读取结果文件
path=('...');
accelx=zeros(345744,36);
dispx=zeros(345744,36);
accely=zeros(345744,36);
dispy=zeros(345744,36);
accelz=zeros(345744,36);
dispz=zeros(345744,36);
for ang=1:36
   fname=[path,'wind',num2str((ang-1)*10),'out.xlsx'];
   accelx(:,ang)=xlsread(fname,'Joint Accelerations - Absolute','F4:F345747');%36个风向角X向加速度
   dispx(:,ang)=xlsread(fname,'Joint Displacements - Absolute','F4:F345747');%36个风向角X向位移
   accely(:,ang)=xlsread(fname,'Joint Accelerations - Absolute','G4:G345747');
   dispy(:,ang)=xlsread(fname,'Joint Displacements - Absolute','G4:G345747');
   accelz(:,ang)=xlsread(fname,'Joint Accelerations - Absolute','H4:H345747');
   dispz(:,ang)=xlsread(fname,'Joint Displacements - Absolute','H4:H345747');
end


path=('...');
  accelX=xlsread('accelx.xlsx');%36个风向角X向加速度
  dispX=xlsread('dispx.xlsx');%36个风向角X向位移
  accelX=xlsread('accely.xlsx');
  dispY=xlsread('dispy.xlsx');
  accelZ=xlsread('accelz.xlsx');
  dispZ=xlsread('dispz.xlsx');


%位移、加速度均方根及平均值计算
 for k=1:106
     if k==1
        m=1;
     else
        m=(k-1)*2400;
     end
 n=k*2400;
   for j=1:1:36  
  std_disp_xA(k,j)=std(dispx(m:n,j)); 
  std_disp_yA(k,j)=std(dispy(m:n,j)); 
  std_disp_zA(k,j)=std(dispz(m:n,j)); 
  std_accel_xA(k,j)=std(accelx(m:n,j)); 
  std_accel_yA(k,j)=std(accely(m:n,j)); 
  std_accel_zA(k,j)=std(accelz(m:n,j)); 
  mean_disp_xA(k,j)=mean(dispx(m:n,j)); 
  mean_disp_yA(k,j)=mean(dispy(m:n,j)); 
  mean_disp_zA(k,j)=mean(dispz(m:n,j)); 
  mean_accel_xA(k,j)=mean(accelx(m:n,j));
  mean_accel_yA(k,j)=mean(accely(m:n,j));
  mean_accel_zA(k,j)=mean(accelz(m:n,j));
   end
 end
 
 %%各分块投影面积
 load('...');
area_xA=abs(area(:,1));
area_yA=abs(area(:,2));
area_zA=abs(area(:,3));


  %% 位移风振系数计算
   g=2.5;%
   cc=0.25;% 脉动风压参与系数cc=0.25
   for k=1:106
        for j=1:1:36  
        ld=abs(mean_disp_xA(k,j));
        md=abs(mean_disp_yA(k,j));
        nd=abs(mean_disp_zA(k,j));
        if ld==0
            vib_coe_x2dA(k,j)=1;
        else
            vib_coe_x2dA(k,j)=1+g*(std_disp_xA(k,j)/ld);
        end
        if md==0
            vib_coe_y2dA(k,j)=1;
        else
            vib_coe_y2dA(k,j)=1+g*(std_disp_yA(k,j)/md);
        end
       if nd==0
           vib_coe_z2dA(k,j)=1;
       else
           vib_coe_z2dA(k,j)=1+g*(std_disp_zA(k,j)/nd);
       end
       end
   end 
     coe_disp2A=[vib_coe_x2dA vib_coe_y2dA vib_coe_z2dA];

 %%风振系数修正
  for i=1:144  %修正网架
    for j=1:36
       s1=3*(max(coe_disp2A(i,j))+1);
      if coe_disp2A(i,j)>3
          if coe_disp2A(i,j)>3+coe_disp2A(i,j)/s1
          coedispA2final(i,j)=3+coe_disp2A(i,j)/s1;
          else
          coedispA2final(i,j)=coe_disp2A(i,j);
          end
          else
          coedispA2final(i,j)=coe_disp2A(i,j);
      end
    end
  end  
  
 
  %% 统计节点风力平均值和均方值
  filename1=strcat(['.\风力时程数据\windforce_',num2str(q),'.mat']);
  load(filename1);
 for i=1:1:144
    for j=1:1:36
      meanforce_xA(i,j)=mean(force_x(:,i,j));
      stdforce_xA(i,j)=std(force_x(:,i,j));
      meanforce_yA(i,j)=mean(force_y(:,i,j));
      stdforce_yA(i,j)=std(force_y(:,i,j));
      meanforce_zA(i,j)=mean(force_z(:,i,j));
      stdforce_zA(i,j)=std(force_z(:,i,j));
    end
 end
 

 %% 荷载风振系数计算
    mmA=xlsread('..\分块质量.xlsx','sheet1');%%定义成mat文件
    for k=1:144 %上层屋架
        m=mmA(k,1);
    for j=1:1:36  
        ll=1000*abs(meanforce_xA(k,j));
        ml=1000*abs(meanforce_yA(k,j));%定义成mat文件
        nl=1000*abs(meanforce_zA(k,j));
        if ll==0
            vib_coe_xlA(k,j)=1;
        else
            vib_coe_xlA(k,j)=1+g*sqrt((cc*(1000*stdforce_xA(k,j)))^2)/ll;
        end
        if ml==0
            vib_coe_ylA(k,j)=1;
        else
            vib_coe_ylA(k,j)=1+g*sqrt((cc*(1000*stdforce_yA(k,j)))^2)/ml;
        end
        if nl==0
            vib_coe_zlA(k,j)=1;
        else
            vib_coe_zlA(k,j)=1+g*sqrt((cc*(1000*stdforce_zA(k,j)))^2)/nl;
        end
        coeloadfinalA(k,j)=(vib_coe_xlA(k,j)*area_xA(k,1)+vib_coe_ylA(k,j)*area_yA(k,1)+vib_coe_zlA(k,j)*area_zA(k,1))/(area_xA(k,1)+area_yA(k,1)+area_zA(k,1));
    end
    end
  %% 风振系数整合 
for i=1:144
    for j=1:1
        vibcoeFinal(i,j)=min(coeloadfinalA(i,j),coendispfinalA(i,j));
    end
end