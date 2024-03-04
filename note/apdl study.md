### example of time domain load-respondence analysis (PV panels)

```fortran
!读入节点风荷载时程数据并将其作用于光伏板振动分析
*Create,dataread,mac

NN=10000 !单点数据长度
*DIM,W150,,63,NN !创建节点风荷载存储文件,default type is ARRAY, dimension 63*n[*1]
*VREAD,WF,WF150.TXT,,JIK,NN,63 !先读入行，后读入列
(10000F1.8)!读入格式，每行10000个数据，1个字节，数点后8位

/SOLU$ALLSEL,ALL 
ANTYPE,0
NLGEOM,ON
PSTRES,ON 
SSTIF,ON
NSUBST,1
OUTREA,ALL,ALL  

*DO,I,1,NN
 TIME,I
 *DO,II,1,63 
  FDELE,ALL,ALL   
  F,II+100,FZ,WF(II,I)
  PSOLVE
 *ENDDO
*ENDDO
FINISH
                 
  !动画查看变形结果
!/POST1
```

### Decomposing 

#### 1.**Reading Wind Load Time History Data:**

* **Create,dataread,macro**

**Macros are a sequence of Mechanical APDL commands stored in a file.** Macros should not have the same name as an existing Mechanical APDL command, or start with the first four characters of a Mechanical APDL command, because Mechanical APDL executes the internal command instead of the macro. 

* **\*DIM,W150,,63,NN** 

`*DIM, Par, Type, IMAX, JMAX, KMAX, Var1, Var2, Var3, CSYSID `
Defines an array parameter and its dimensions.

创建节点风荷载存储文件`W150`,default type is ARRAY, dimension $63*NN[*1]$

* ***VREAD,WF,WF150.TXT,,JIK,NN,63**

> You can fill an array from a data file via the *VREAD command. The command reads information from an ASCII data file and begins writing it into the array, starting with the index location that you specify. You can control the format of the information read from the file through data descriptors. The data descriptors must be enclosed in parenthesis and placed on the line following the *VREAD command. See Vector Operations for more information about data descriptors. The data descriptors control the number of fields to be read from each record, the width of the data fields, and the position of the decimal point in the field.

```
*VREAD, ParR, Fname, Ext, --, Label, n1, n2, n3, NSKIP
```

Reads data and produces an array parameter vector or matrix.

Reads the wind load data from a text file named `WF150.TXT` into the array.

The format `(10000F1.8)` specifies that each line of the file contains 10,000 floating-point numbers with one digit before the decimal and eight digits after the decimal.

![vread-array](vread-array.png)

#### 2.**Setting Up the Analysis **(static analysis)

- `/SOLU`: Enters the solution environment. The `$ALLSEL,ALL` part seems to be a combination of commands and might be incorrectly formatted. The correct command to select all entities is `ALLSEL,ALL` or simply `ALLSEL` for APDL.
- `ANTYPE,0`: Specifies a static analysis.
- `NLGEOM,ON`: Activates large deflection effects, which is important for accurate nonlinear dynamic analysis.
- `PSTRES,ON` and `SSTIF,ON`: These commands activate prestress effects and include stress-stiffening in the analysis, respectively.
- `NSUBST,1`: Sets the number of substeps. This might need adjustment based on the analysis requirements.
- `OUTREA,ALL,ALL`: Specifies that all results should be output for all substeps.

#### 3. Setting Up the Analysis (transient analysis)

```fortran
!*******************瞬态分析*********************
/SOL
/SOLU
ANTYPE,TRANS
TRNOPT,MSUP,50,,,,,YES
ACEL,,,9.800
FCUM,ADD,,
MDAMP,1,0.02
MDAMP,2,0.02
...
MDAMP,50,0.02
AUTOTS, ON
SAVE
SOLVE	
```

* **ANTYPE,TRANS**

  transient analysis

* **TRNOPT,MSUP,50,,,,,YES**

  ```
  TRNOPT, Method, MAXMODE, --, MINMODE, MCout, TINTOPT, VAout, DMPSFreq, EngCalc
  ```

  Specifies transient analysis options.

  *Parameters:*

  MSUP: Mode-superposition method.

  50: Largest mode number to be used to calculate the response is 50.

  YES: Calculate damping energy and work done by external loads.

* **ACEL,,,9.800**

  ```
  ACEL, ACEL_X, ACEL_Y, ACEL_Z
  ```

  Specifies the linear acceleration of the global Cartesian reference frame for the analysis.

* **FCUM,ADD,,**

  ```
  FCUM, Oper, RFACT, IFACT
  ```

  Specifies that force loads are to be accumulated.

  *Parameters:*

  REPL: Subsequent values replace the previous values (default).

  ADD: Subsequent values are added to the previous values.

  IGNO: Subsequent values are ignored.

* **MDAMP,1,0.02**

  ```
  MDAMP, STLOC, V1, V2, V3, V4, V5, V6
  ```

  Defines the damping ratios as a function of mode.

* **AUTOTS, ON**

  Specifies whether to use automatic time stepping or load stepping.

#### **Applying Loads and Solving**

##### **loop in the apdl**

```fortran
*DO,I,1,NN
 TIME,I
 *DO,II,1,63 
  FDELE,ALL,ALL   
  F,II+100,FZ,WF(II,I)
  PSOLVE
 *ENDDO
*ENDDO
```

The nested `*DO` loops iterate over each time step (`I`) and each node (`II`). Within each iteration, the script:

- Deletes all previously applied loads with `FDELE,ALL,ALL`.
- Applies a force in the Z direction (`FZ`) to each node (`II+100`) using the wind load data from the `W150` array.
- Solves the analysis for each time step with `PSOLVE`.

##### write the apdl script by matlab

```matlab
% tanggui's code H:\煤棚抗风动力可靠度分析20200608\ansys有限元计算
%% 本程序用于生成ansys时程计算文件
clc;
clear;
path=cd;
%设置风向角
ww=0:10:350;
freq = 312.5;
time = 90;
N = freq * time;
geometricScale = 250;
windspeedScale = 43.4/11.8;
timeScale = geometricScale / windspeedScale;
protoFreq = freq / timeScale;
dt = 1 / protoFreq;
timeNum = 2800;
t=dt:dt:(timeNum * dt);
inputPath = strcat(['E:\煤棚抗风动力可靠度分析20200608']);

blockNum_roof = 112;
blockNum_gable = 16;
blockNum_total = 240;
blockNum = 128;

fid1_output=fopen(['.\计算文件\timeHistoryComputingFile.txt'],'w');
fid1_forward=fopen('.\forward.txt','r');
Data_forward=fread(fid1_forward);
fwrite(fid1_output,Data_forward);
fclose(fid1_forward);

inputFile = strcat([inputPath,'\区块中心点坐标_中部分开.xlsx']);
loadPoint = xlsread(inputFile,'Sheet4');
for num=1:1
    w=ww(num);
    inputFile=strcat(['.\风荷载时程\windForceTimehistory_',num2str(w),'.mat']);
    load(inputFile);

    for tt = 1:timeNum
        fprintf(fid1_output,'TIME,%12.6f\n',t(tt));
        fprintf(fid1_output,'NSUBST,1,,,1\nKBC,0\n');
        for i=1:112
            fprintf(fid1_output,'F,%d,FY,%12.6f\n',loadPoint(i),windForce(i,tt));
            fprintf(fid1_output,'F,%d,FZ,%12.6f\n',loadPoint(i),windForce(blockNum_roof+i,tt));
        end
        for i=113:128
            fprintf(fid1_output,'F,%d,FX,%12.6f\n',loadPoint(i),windForce(blockNum_roof+i,tt));
        end
        fprintf(fid1_output,'SAVE\nSOLVE\n');
    end
end
fid1_backward=fopen('.\backward.txt','r');
Data_backward=fread(fid1_backward);
fwrite(fid1_output,Data_backward);
fclose(fid1_backward);

fclose(fid1_output);
clear Data_forward Data_backward;
```



### what is array?

> This type is similar to FORTRAN arrays and is the default array type when dimensioning arrays. As with FORTRAN arrays, the indices for rows, columns, and planes are sequential integer numbers beginning with one. Array elements can be either integers or real numbers.

#### Specifying Array Element Values

You can specify array element values by

* Setting individual array element values through the *SET command or "=" shortcut.

* Filling individual vectors (columns) in the array with either specified or calculated values (the *VFILL command, for example).

* Interactively specifying values for the elements through the *VEDIT dialog.

* Reading the values from an ASCII file (*VREAD or *TREAD commands).

![vread-array](vread-array.png)