# Project: PV Panel Finite Anlysis based on APDL

## What I done

* I maintain an **APDL analysis case**.

* the file structure follows the **finite element analysis process**. 

* APDL output is time history dynamic response.

* **Matlab reads APDL output**, analyzes the data and comes to interesting conclusion 

* Include matlab code, apdl script, and supporting documentation.


## File Structure

* **apdl_calculation_file**

  Final APDL file containing all operations

  you can read `intergratedFile.txt` in APDL to show all results

* **force**

  establish constraint; read wind force data to apdl script

* **modalAnalysis**

  apdl modal analysis options

* **transientAnalysis**

  apdl transient analysis options

* **model**

  setup the project ; define ET, R , Material ; generate model geometry from node coordination

* **note**

  store the document

  ***note/ helper.md is useful.***

* **post_process**

  | Fucntion                                                     | Script Name                                |
  | ------------------------------------------------------------ | ------------------------------------------ |
  | write apdl result to txt file.                               | `getresultfromapdl.m`                      |
  | write apdl node coordinates to txt file.                     | `getnodeZ.txt`                             |
  | compute velocity and acceleration from displacement.         | `disp2acce.m`                              |
  | optimize the computing result.                               | `modifyvibcoe.m`                           |
  | calculate statistics of dynamic response.                    | `getvibCoe95value.m` `calculateStatiCoe.m` |
  | calculate wind vibration coefficient.                        | `calculateVibCoe.m`                        |
  | convert node result to block result.                         | `modifyvibcoe.m` function `node2block`     |
  | draw contour picture with data1, meanwhile print the value on contour evenly. | `drawContourVibcoe.m`                      |

* **preAnalysis**

  建立约束后悬索找型，模态分析前

* **result**

## Dara structure

If not consider the time cost in read and write, storing **one condition, one class** parameter **over all node, over all time** in one file (.txt or .csv) is a good choice.

there are many ways to organize the parameter table:

1.  one variable table with **multi column**

   | variable number | time | value |
   | --------------- | ---- | ----- |
   | ...             | ...  | ...   |

2. **one variable table with one column** 

   you can give variable storage order beyond the table, give time storage order beyond the table. Then the table do not need to store number and time. This strategy can reduce the space occupied.

   this table only has one column of data.

   | variable value |
   | -------------- |
   | ...            |

   **Most data is stored in one column table**

   **example**

   * all node displacement over time

     1-2800 is 2800 time-step result of node 1. 2801-5600 is 2800 time-step result of node2 ...

     the node order should be defined. I have a picture showing it.

   * node statistics 

     1-630 is 630 ordered nodes' statistics.

   * ...
