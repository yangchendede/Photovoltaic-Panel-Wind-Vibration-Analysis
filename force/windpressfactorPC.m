
clear;
clc;
Pi=3.14159;      
PV=0.85;                                                       %essential wind pressure 
BITA= 0.15;                                                   %rough factor
EssentialHight=10;                                   %�ο���߶�
Row= 30;                                                      %%��������Ŀ���ֵ
Col= 8;                                                        %%������Ŀ
                                                                                                 %%????????????����
 

TestPointNum=450; %ʵ�ʲ����Ŀ

WindAngleNum= 13;
TimeDataNum=10000;

AllTestPointNum=Row*Col;
EssentialHightFactor= (EssentialHight/10)^(BITA*2);%%Uzr
EssentialWindPress= EssentialHightFactor*PV; %%Wr

%%���༭������������                                                                                       ����������ַ
dir_AR='\����ѹ���ݴ���\'; %%��ֵ�������������ļ���
height=load('\�����ļ�\height.txt'); %% height���߶�
height2=load('\�����ļ�\height.txt'); %% height���߶�

heightT=height';
heightT2=height2';



%% ���������ѹϵ��ƽ��ֵ������������������ѹϵ���������
for Wa=1:1:WindAngleNum %%�����
    %%%%%%%%%%%%% ��ȡ�����������ƽ����ѹ������ֵ��������Ϊ���� %%%%%%%%%%%%%%%%%%
    str_angle=num2str((Wa-1)*15);
	file_a=cat(2,dir_AR,'a',str_angle);
                file_r=cat(2,dir_AR,'r',str_angle);
	data_temp=load(file_a);
	tempPressFactor=data_temp(5:length(data_temp));                      %%%5���������ĵ�ǰ���з�������Ϣ
    data_temp=load(file_r);
    tempPressFactorRms=data_temp(5:length(data_temp)); 
    WindPressFactor=reshape(tempPressFactor(:),Row,Col);
    WindPressFactor=WindPressFactor';                                    %%%���� 'Ϊת��
    WindPressFactorRms=reshape(tempPressFactorRms(:),Row,Col); 
    WindPressFactorRms=WindPressFactorRms';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
  

 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%% ����У��point_max(min)_ave %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    WindPressFactorave(Wa,:,:)=WindPressFactor;
    WindPressFactorrmsb(Wa,:,:)=WindPressFactor+3.5*WindPressFactorRms; %%bigger
    WindPressFactorrmss(Wa,:,:)=WindPressFactor-3.5*WindPressFactorRms; %%smaller
    %%%%%��ÿ�������ѭ����д��÷�������ݣ�ѭ�����ӣ���ά��������һ��ѭ�����򻯳���
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    
    %%%%%�������Ϣ��������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:1:Col
        for j=1:1:Row
            if(WindPressFactor(i,j)~=-150)
                Point(i,j).height=heightT(i,j);
                Point2(i,j).height=heightT2(i,j);
            end
        end

    end
    
    sss=['windangle=',num2str((Wa-1)*15),'��'];
    disp(sss);
end %%Wa

% %%������ã�
% %%������Ǹ������ѹ��ֵ����������ֵ
% %%������Ǹ�����ѹ���ֵ����������ֵ



%% %%%%%%%%%%%%%%%%% �������ѹϵ��,��ѹ������ϵ����ֵ��������������) %%%%%%%%%%%%%%%%%%%%%%%%%%
[temp_maxa,temp_maxa2]=max(WindPressFactorave,[],1);                  %��ѹϵ����ֵ���ֵ
[temp_mina,temp_mina2]=min(WindPressFactorave,[],1);                  %��ѹϵ����ֵ��Сֵ
[temp_maxr,temp_maxr2]=max(WindPressFactorrmsb,[],1);                 %������ѹϵ�����ֵ               
[temp_minr,temp_minr2]=min(WindPressFactorrmss,[],1);                 %������ѹϵ����Сֵ

    nval=1; %%��Ч�������������������ֵ�͸�ֵ����Ӧ�ĽǶ�    һ����Ҫô������-150,Ҫô����-150,���в���Ҫ�ų�
    for i=1:1:Col
        for j=1:1:Row
            if(WindPressFactor(i,j)~=-150)
                MaxPressFactor(nval,1)=temp_maxa(1,i,j);%��ѹϵ��
                heightchangefactor(nval)=(Point(i,j).height/10)^(2*BITA);%��ѹ�߶ȱ仯ϵ��
                MaxPressFactor(nval,3)=(EssentialHight/Point2(i,j).height)^(2*BITA)*temp_maxa(1,i,j);%����ϵ��    ƽ��ֵ���ֵ
                MaxPressFactor(nval,2)=MaxPressFactor(nval,3)*heightchangefactor(nval)*PV;%��ѹ
                
               MaxPressFactor(nval,4)=(temp_maxa2(1,i,j)-1)*15;%��Ӧ�Ƕ�
                
                
                
                MinPressFactor(nval,1)=temp_mina(1,i,j);%��ѹϵ��
                heightchangefactor(nval)=(Point(i,j).height/10)^(2*BITA);%��ѹ�߶ȱ仯ϵ��
                MinPressFactor(nval,3)=(EssentialHight/Point2(i,j).height)^(2*BITA)*temp_mina(1,i,j);%����ϵ��            % ƽ��ֵ��Сֵ
                MinPressFactor(nval,2)=MinPressFactor(nval,3)*heightchangefactor(nval)*PV;%��ѹ
                MinPressFactor(nval,4)=(temp_mina2(1,i,j)-1)*15;%��Ӧ�Ƕ�
                
                
                
                MaxPressFactorRms(nval,1)=temp_maxr(1,i,j);%��ѹϵ��
                heightchangefactor(nval)=(Point(i,j).height/10)^(2*BITA);%��ѹ�߶ȱ仯ϵ��
                MaxPressFactorRms(nval,4)=(EssentialHight/Point2(i,j).height)^(2*BITA)*temp_maxr(1,i,j);%����ϵ��  %��������������ֵ
                
           if (i~=9&&i~=10&&i~=11)
                if MaxPressFactorRms(nval,4)>0
                    MaxPressFactorRms(nval,4)=MaxPressFactorRms(nval,4)+0.2
                else
                    MaxPressFactorRms(nval,4)=MaxPressFactorRms(nval,4)-0.2                      %%Χ���ṹ
                end
           end
                MaxPressFactorRms(nval,2)=MaxPressFactorRms(nval,4)*heightchangefactor(nval)*PV;%��ѹ
                MaxPressFactorRms(nval,3)=(temp_maxr2(1,i,j)-1)*15;                
                
                MinPressFactorRms(nval,1)=temp_minr(1,i,j);%��ѹϵ��
                heightchangefactor(nval)=(Point(i,j).height/10)^(2*BITA);%��ѹ�߶ȱ仯ϵ��
                MinPressFactorRms(nval,4)=(EssentialHight/Point2(i,j).height)^(2*BITA)*temp_minr(1,i,j);%����ϵ��   %��������������ֵ��С����
           if (i~=9&&i~=10&&i~=11)
                if MinPressFactorRms(nval,4)>0
                    MinPressFactorRms(nval,4)=MinPressFactorRms(nval,4)+0.2
                else
                    MinPressFactorRms(nval,4)=MinPressFactorRms(nval,4)-0.2
                end
           end
                MinPressFactorRms(nval,2)=MinPressFactorRms(nval,4)*heightchangefactor(nval)*PV;%��ѹ
                MinPressFactorRms(nval,3)=(temp_minr2(1,i,j)-1)*15;                          
                
                nval=nval+1;
            end
        end
    end %%Col
    
    



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% �����������Ƿ�ѹ��ϵ������ѹ��Ͷ�Ӧ������ϵ�������ɻ�ͼlisp�ļ���
for Wa=1:1:WindAngleNum
    nval=1;
    for i=1:1:Col
        for j=1:1:Row
            if(WindPressFactorave(Wa,i,j)~=-150)
                WindPressFactor1(nval,Wa)=WindPressFactorave(Wa,i,j);%��ѹ��ϵ��
                heightchangefactor(nval)=(Point(i,j).height/10)^(2*BITA);%��ѹ�߶ȱ仯ϵ��
                WindPressFactor3(nval,Wa)=(EssentialHight/Point2(i,j).height)^(2*BITA)*WindPressFactorave(Wa,i,j);%����ϵ��
                WindPressFactor2(nval,Wa)=WindPressFactor3(nval,Wa)*heightchangefactor(nval)*PV;%��ѹ
                nval=nval+1;
            end
        end
    end
    nval=1;
end




for i=1:1:383
    WindPressFactor22_max(i,1)=max(WindPressFactor2(i,:));%1��������£�������ע����%%������ѹ��ϵ�������ֵ
    WindPressFactor22_min(i,1)=min(WindPressFactor2(i,:));%1��������£���%%������ѹ��ϵ�����ֵ
    WindPressFactor33_max(i,1)=max(WindPressFactor3(i,:));%1��������£���%%���������ϵ�������ֵ
    WindPressFactor33_min(i,1)=min(WindPressFactor3(i,:));%1��������£���%%���������ϵ�����ֵ
end




WindPressFactor2=[WindPressFactor2,WindPressFactor22_max,WindPressFactor22_min];%����������¸�����ѹϵ���������ֵ�����ֵ�������㣩     ����������
WindPressFactor3=[WindPressFactor3,WindPressFactor33_max,WindPressFactor33_min];%����������¸��������ϵ���������ֵ�����ֵ�������㣩     ����������







%% LISP

s1='...����ѹlisp\';    %��ѹ��

cor=load('...\�����ļ�\cor.txt');

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




