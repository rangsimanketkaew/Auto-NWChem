# NWChem Compilation
This repository includes scripts for NWChem's automatic compilation on Centos 6.x &amp; 7.x and test file of optimization of azulene using DFT at M06-2X/6-31G(d) level of theory. It's such a friendly user script, very easy to use. The procedure of compilation can be successive via step (0) to (3)
  * **(0)**  Setting up. Make directory NWCHEM at /usr/local/src/ via sudo command or **root**. Check the required package *Before Compile*.
  * **(1)**  Download a program source of *nwchem-x.x.tar.gz* from NWChem website using **wget** command first. (I am using nwchem version 6.6 on the day I wrote this script). Save it at */usr/local/src/NWCHEM/* , then extract the program from tar file using *tar -xf nwchem-x.x.tar.gz*. So far you should have a nwchem-x.x directory in the present location.
  * **(2)**  Download a scripts to */usr/local/src/NWCHEM/nwchem-x.x*. Then run script [1_compile.sh](https://github.com/rangsimanketkaew/NWChem/blob/master/1_compile.sh). After finishing and there's no any error, then run [2_path.sh](https://github.com/rangsimanketkaew/NWChem/blob/master/2_path.sh), respectively. More instruction can be found in script [1_compile.sh](https://github.com/rangsimanketkaew/NWChem/blob/master/1_compile.sh). ! <br />
  * **(3)**  Up to now, let's create a **.nwchemrc** file which included following commands at your home directory, /home/$USER/.nwchemrc <br /> Noted that I use nwchem version 6.6 for this compilation.
```
  nwchem_basis_library /usr/local/nwchem/data/libraries/
  nwchem_nwpw_library /usr/local/nwchem/data/libraryps/
  ffield amber
  amber_1 /usr/local/nwchem/data/amber_s/
  amber_2 /usr/local/nwchem/data/amber_q/
  amber_3 /usr/local/nwchem/data/amber_x/
  amber_4 /usr/local/nwchem/data/amber_u/
  spce    /usr/local/nwchem/data/solvents/spce.rst
  charmm_s /usr/local/nwchem/data/charmm_s/
  charmm_x /usr/local/nwchem/data/charmm_x/
```
---
***Optional: PATH SETTING.** Instead of running nwchem via direct path, you can make a alias path to call nwchem by using following command
```
export PATH=/usr/local/nwchem-6.6/bin/LINUX/nwchem:$PATH
```
If you want system to call automatically nwchem for next log-in time, each user might have to use following command in which appending the path to their own $HOME/.bashrc file.
```
echo export PATH=/usr/local/nwchem-6.6/bin/LINUX/nwchem:$PATH >> /home/$USER/.bashrc
```

# Error recognition & fixing
During compilation using **make** or **configuration setting up** It is possible to meet an error in which caused by calling library mistake. <br />
E.g. *libmpi_f90.so.1: cannot open*, you have to use the following command to fix the issue.
```
export LD_LIBRARY_PATH=/usr/local/openmpi/lib/:$LD_LIBRARY_PATH
source $HOME/.bashrc
```
---
When you run NWChem with MPI, and you meet the error like this
```
utilfname: cannot allocate
or
utilfname: cannot allocate:Received an Error in Communication
```
This error is telling that it cannot allocate the memory with number of processors. The user have to specify the amount of memory **PER PROCESSOR CORE** that NWChem can use for a calculation. <br />
This issue can be easily fixed by adding a memory keyword into INPUT-FILE.nw, e.g.
```
memory 1 gb
```
If you run NWChem using, says, *"mpirun -np N nwchem INPUT-FILE.nw"* This mean that the total of used memory for this calculation is = (1 gb)*(N processors). <br />
However, safety first, you can limit the total of memory usage for calculation by specifying optional keyword of memory keyword, says
```
memory total 1 gb
```
More details about memory arrangement can be found this [website](http://www.nwchem-sw.org/index.php/Release66:Top-level#MEMORY)

# How to run easily NWChem
let's try to run nwchem with some test files from **/usr/local/src/NWCHEM/nwchem-6.6/examples/** or **/usr/local/src/NWCHEM/nwchem-6.6/QA/tests** by using the following command run
```
nohup mpirun -np N /usr/local/nwchem/bin/nwchem INPUT-FILE.nw >& OUTPUT-FILE.log
```
or
```
nohup mpirun -np N nwchem INPUT-FILE.nw >& OUTPUT-FILE.log
```
Just in case of MPI, the following might be useful
```
export OMP_NUM_THREADS=N
```
where N = number of processors

## Before compile
The required packages of MPI variable compilation are following <br />
* OpenMPI (recommend OpenMPI 1.6.5) <br />
* Intel Compilers <br />
* Intel MKL <br />
* python-devel <br />
* gcc-gfortran <br />
* openblas-devel <br />
* openblas-serial64 <br />
* scalapack-openmpi-devel <br />
* elpa-openmpi-devel <br />
* tcsh <br />
* openssh-clients <br />
* which

## OpenMPI 1.6.5 Installation
[Please visit this website](http://lsi.ugr.es/~jmantas/pdp/ayuda/datos/instalaciones/Install_OpenMPI_en.pdf)

## OpenBLAS Installation
Source file [Download here](https://www.open-mpi.org/software/ompi/v1.6/) <br />
[Installation guide](https://github.com/xianyi/OpenBLAS/wiki/Installation-Guide)

## More details
[NWChem Compilation website](http://www.nwchem-sw.org/index.php/Compiling_NWChem)

## Contact me
ragnsiman1993 (at) gmail.com
