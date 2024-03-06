# Project: PV Panel Finite Anlysis based on APDL

## What I done

* I maintain an apdl analysis case.

* the file structure follows the finite element analysis process. 

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

* **post_process**

* **preAnalysis**

  建立约束后悬索找型，模态分析前

* **result**

