
clear;
clc;
Pi=3.14159;      
PV=0.85;                                                       %essential wind pressure 
BITA= 0.15;                                                   %rough factor
EssentialHight=10;                                   %参考点高度
Row= 30;                                                      %%测点层测点数目最大值
Col= 8;                                                        %%测点层数目
                                                                                                 %%????????????数据
 

TestPointNum=450; %实际测点数目

WindAngleNum= 13;
TimeDataNum=10000;

AllTestPointNum=Row*Col;
EssentialHightFactor= (EssentialHight/10)^(BITA*2);%%Uzr
EssentialWindPress= EssentialHightFactor*PV; %%Wr

%%待编辑。。。。。。                                                                                       ？？？？地址
dir_AR='\净风压数据处理\'; %%均值及均方根数据文件夹
height=load('\计算文件\height.txt'); %% height测点高度
height2=load('\计算文件\height.txt'); %% height测点高度

heightT=height';
heightT2=height2';



%% 计算各测点风压系数平均值、均方根、内外表面风压系数差、均方根
for Wa=1:1:WindAngleNum %%风向角
    %%%%%%%%%%%%% 读取各测点各风向角平均风压和脉动值，并构造为矩阵 %%%%%%%%%%%%%%%%%%
    str_angle=num2str((Wa-1)*15);
	file_a=cat(2,dir_AR,'a',str_angle);
                file_r=cat(2,dir_AR,'r',str_angle);
	data_temp=load(file_a);
	tempPressFactor=data_temp(5:length(data_temp));                      %%%5——数据文档前四行非数据信息
    data_temp=load(file_r);
    tempPressFactorRms=data_temp(5:length(data_temp)); 
    WindPressFactor=reshape(tempPressFactor(:),Row,Col);
    WindPressFactor=WindPressFactor';                                    %%%—— '为转置
    WindPressFactorRms=reshape(tempPressFactorRms(:),Row,Col); 
    WindPressFactorRms=WindPressFactorRms';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
  

 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%% 用于校对point_max(min)_ave %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    WindPressFactorave(Wa,:,:)=WindPressFactor;
    WindPressFactorrmsb(Wa,:,:)=WindPressFactor+3.5*WindPressFactorRms; %%bigger
    WindPressFactorrmss(Wa,:,:)=WindPressFactor-3.5*WindPressFactorRms; %%smaller
    %%%%%在每个风向角循环里写入该风向角数据，循环叠加（升维，可以少一轮循环、简化程序）
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    
    %%%%%将测点信息赋予各测点%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:1:Col
        for j=1:1:Row
            if(WindPressFactor(i,j)~=-150)
                Point(i,j).height=heightT(i,j);
                Point2(i,j).height=heightT2(i,j);
            end
        end

    end
    
    sss=['windangle=',num2str((Wa-1)*15),'度'];
    disp(sss);
end %%Wa

% %%以上求得：
% %%各风向角各层测点风压均值，考虑脉动值
% %%各风向角各测点的压差均值，考虑脉动值



%% %%%%%%%%%%%%%%%%% 求各测点风压系数,风压，体型系数最值（包含考虑脉动) %%%%%%%%%%%%%%%%%%%%%%%%%%
[temp_maxa,temp_maxa2]=max(WindPressFactorave,[],1);                  %风压系数均值最大值
[temp_mina,temp_mina2]=min(WindPressFactorave,[],1);                  %风压系数均值最小值
[temp_maxr,temp_maxr2]=max(WindPressFactorrmsb,[],1);                 %脉动风压系数最大值               
[temp_minr,temp_minr2]=min(WindPressFactorrmss,[],1);                 %脉动风压系数最小值

    nval=1; %%有效测点数，求各测点的最大正值和负值及相应的角度    一个点要么都不是-150,要么都是-150,所有不需要排除
    for i=1:1:Col
        for j=1:1:Row
            if(WindPressFactor(i,j)~=-150)
                MaxPressFactor(nval,1)=temp_maxa(1,i,j);%风压系数
                heightchangefactor(nval)=(Point(i,j).height/10)^(2*BITA);%风压高度变化系数
                MaxPressFactor(nval,3)=(EssentialHight/Point2(i,j).height)^(2*BITA)*temp_maxa(1,i,j);%体型系数    平均值最大值
                MaxPressFactor(nval,2)=MaxPressFactor(nval,3)*heightchangefactor(nval)*PV;%风压
                
               MaxPressFactor(nval,4)=(temp_maxa2(1,i,j)-1)*15;%相应角度
                
                
                
                MinPressFactor(nval,1)=temp_mina(1,i,j);%风压系数
                heightchangefactor(nval)=(Point(i,j).height/10)^(2*BITA);%风压高度变化系数
                MinPressFactor(nval,3)=(EssentialHight/Point2(i,j).height)^(2*BITA)*temp_mina(1,i,j);%体型系数            % 平均值最小值
                MinPressFactor(nval,2)=MinPressFactor(nval,3)*heightchangefactor(nval)*PV;%风压
                MinPressFactor(nval,4)=(temp_mina2(1,i,j)-1)*15;%相应角度
                
                
                
                MaxPressFactorRms(nval,1)=temp_maxr(1,i,j);%风压系数
                heightchangefactor(nval)=(Point(i,j).height/10)^(2*BITA);%风压高度变化系数
                MaxPressFactorRms(nval,4)=(EssentialHight/Point2(i,j).height)^(2*BITA)*temp_maxr(1,i,j);%体型系数  %考虑脉动后的最大值
                
           if (i~=9&&i~=10&&i~=11)
                if MaxPressFactorRms(nval,4)>0
                    MaxPressFactorRms(nval,4)=MaxPressFactorRms(nval,4)+0.2
                else
                    MaxPressFactorRms(nval,4)=MaxPressFactorRms(nval,4)-0.2                      %%围护结构
                end
           end
                MaxPressFactorRms(nval,2)=MaxPressFactorRms(nval,4)*heightchangefactor(nval)*PV;%风压
                MaxPressFactorRms(nval,3)=(temp_maxr2(1,i,j)-1)*15;                
                
                MinPressFactorRms(nval,1)=temp_minr(1,i,j);%风压系数
                heightchangefactor(nval)=(Point(i,j).height/10)^(2*BITA);%风压高度变化系数
                MinPressFactorRms(nval,4)=(EssentialHight/Point2(i,j).height)^(2*BITA)*temp_minr(1,i,j);%体型系数   %考虑脉动后的最大值（小？）
           if (i~=9&&i~=10&&i~=11)
                if MinPressFactorRms(nval,4)>0
                    MinPressFactorRms(nval,4)=MinPressFactorRms(nval,4)+0.2
                else
                    MinPressFactorRms(nval,4)=MinPressFactorRms(nval,4)-0.2
                end
           end
                MinPressFactorRms(nval,2)=MinPressFactorRms(nval,4)*heightchangefactor(nval)*PV;%风压
                MinPressFactorRms(nval,3)=(temp_minr2(1,i,j)-1)*15;                          
                
                nval=nval+1;
            end
        end
    end %%Col
    
    



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 计算各个风向角风压差系数、风压差和对应的体型系数（生成画图lisp文件）
for Wa=1:1:WindAngleNum
    nval=1;
    for i=1:1:Col
        for j=1:1:Row
            if(WindPressFactorave(Wa,i,j)~=-150)
                WindPressFactor1(nval,Wa)=WindPressFactorave(Wa,i,j);%风压差系数
                heightchangefactor(nval)=(Point(i,j).height/10)^(2*BITA);%风压高度变化系数
                WindPressFactor3(nval,Wa)=(EssentialHight/Point2(i,j).height)^(2*BITA)*WindPressFactorave(Wa,i,j);%体型系数
                WindPressFactor2(nval,Wa)=WindPressFactor3(nval,Wa)*heightchangefactor(nval)*PV;%风压
                nval=nval+1;
            end
        end
    end
    nval=1;
end




for i=1:1:383
    WindPressFactor22_max(i,1)=max(WindPressFactor2(i,:));%1个风向角下？？（备注有误）%%各测点风压差系数最大正值
    WindPressFactor22_min(i,1)=min(WindPressFactor2(i,:));%1个风向角下？？%%各测点风压差系数最大负值
    WindPressFactor33_max(i,1)=max(WindPressFactor3(i,:));%1个风向角下？？%%各测点体型系数最大正值
    WindPressFactor33_min(i,1)=min(WindPressFactor3(i,:));%1个风向角下？？%%各测点体型系数最大负值
end




WindPressFactor2=[WindPressFactor2,WindPressFactor22_max,WindPressFactor22_min];%各个风向角下各测点风压系数、最大正值、最大负值（单面测点）     不考虑脉动
WindPressFactor3=[WindPressFactor3,WindPressFactor33_max,WindPressFactor33_min];%各个风向角下各测点体型系数、最大正值、最大负值（单面测点）     不考虑脉动







%% LISP

s1='...净风压lisp\';    %风压差

cor=load('...\计算文件\cor.txt');

for i=1:1:24
    ss1=[s1,'p_',num2str((i-1)*15),'.lsp'];
   ss2=[s1,'t_',num2str((i-1)*15),'.lsp'];
    fid_2=fopen(ss1,'wt');
    fid_3=fopen(ss2,'wt');
    for j=1:1:383
      
           fprintf(fid_2,'(command \"text\" \"s\" \"Standard\" \"j\" \"bl\" \"%f,%f,0\"\"800\" \"0\" \"%4.2f\")\n',cor(j,1),cor(j,2),WindPressFactor2(j,i));
           fprintf(fid_3,'(command \"text\" \"s\" \"Standard\" \"j\" \"bl\" \"%f,%f,0\"\"800\" \"0\" \"%4.2f\")\n',cor(j,1),cor(j,2),WindPressFactor3(j,i));

    end
    fclose(fid_2);
    fclose(fid_3);
end

ss3=[s1,'ewai_max','.lsp'];
ss4=[s1,'ewai_min','.lsp'];
fid_4=fopen(ss3,'wt');
fid_5=fopen(ss4,'wt');
for j=1:1:383

        fprintf(fid_4,'(command \"text\" \"s\" \"Standard\" \"j\" \"bl\" \"%f,%f,0\"\"800\" \"0\" \"%4.2f\")\n',cor(j,1),cor(j,2),MaxPressFactorRms(j,2));
        fprintf(fid_5,'(command \"text\" \"s\" \"Standard\" \"j\" \"bl\" \"%f,%f,0\"\"800\" \"0\" \"%4.2f\")\n',cor(j,1),cor(j,2),MinPressFactorRms(j,2));
end
fclose(fid_4);
fclose(fid_5);

ss5=[s1,'ewai_t1','.lsp'];
ss6=[s1,'ewai_t2','.lsp'];
fid_6=fopen(ss5,'wt');
fid_7=fopen(ss6,'wt');
for j=1:1:383

        fprintf(fid_4,'(command \"text\" \"s\" \"Standard\" \"j\" \"bl\" \"%f,%f,0\" \"800\" \"0\" \"%4.2f\")\n',cor(j,1),cor(j,2),MaxPressFactor(j,3));
        fprintf(fid_5,'(command \"text\" \"s\" \"Standard\" \"j\" \"bl\" \"%f,%f,0\"\"800\" \"0\" \"%4.2f\")\n',cor(j,1),cor(j,2),MinPressFactor(j,3));

end
fclose(fid_6);
fclose(fid_7);
%save result_nbzx_windpress;
save;




