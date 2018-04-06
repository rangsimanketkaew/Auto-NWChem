# NWChem Auto Compilation

![Capture_Menu](https://github.com/rangsimanketkaew/NWChem/blob/master/etc/Capture_menu.PNG)

A programing script for auto compile NWChem program on CentOS and Ubuntu. . It can also be adjusted to be compatible with other Linux distribution. <br />

## Prerequisites
* CentOS version 6.x / 7.x or Ubuntu 16.x / 17.x (or other Linux distro)
* Bash shell
* Python version 2.6 / 2.7
* OpenMPI and suitable libraries
* Compiler: Intel, GNU, PGI, etc. More details please consult [NWChem manual](http://www.nwchem-sw.org/index.php/Compiling_NWChem#Setting_up_the_proper_environment_variables).
### Compilers
#### Intel Compiler Collection (icc)
* [Download here](https://software.intel.com/en-us/intel-parallel-studio-xe)
* Get the free student version (Linux), or a real license ($$$)
* Includes MKL Math Library
#### GNU Compiler Collection (gcc)
* [Download here](http://sourceforge.net/projects/hpc/files/hpc/gcc/gcc-4.9-bin.tar.gz/download?use_mirror=softlayer-dal&download=) 
* OSX Options:
    * `brew install gcc`
    * [Build instructions for OSX](https://wiki.helsinki.fi/display/HUGG/Installing+the+GNU+compilers+on+Mac+OS+X)
### Math libraries
#### OpenMPI Installation
* You can use any version of OpenMPI, e.g., OpenMPI 1.6.5.
* OpenMPI 1.6.5 source code is at [Download here](https://www.open-mpi.org/software/ompi/v1.6/). 
* Installation step-by-step [Please visit this website](http://lsi.ugr.es/~jmantas/pdp/ayuda/datos/instalaciones/Install_OpenMPI_en.pdf). 
* Set the environment variables and libraries properly.
#### OpenBLAS Installation
* You may need to install OpenBLAS yourself. [Download here](https://github.com/xianyi/OpenBLAS)
* Installation is here [Installation guide](https://github.com/xianyi/OpenBLAS/wiki/Installation-Guide).
* OSX: Brew installation will put OpenBlas in `/usr/local/opt/openblas`
---
## Installing
- **(1)**  Install required package <br />
> **CentOS**: Install the following package using yum command (root or sudo) <br />
```
yum install python-devel gcc-gfortran openblas-devel openblas-serial64 openmpi-devel scalapack-openmpi-devel blacs-openmpi-devel elpa-openmpi-devel tcsh --enablerepo=epel
```
> **Ubuntu**: Install the following package using apt-get command (root or sudo)
```
sudo apt-get install python-dev gfortran libopenblas-dev libopenmpi-dev openmpi-bin tcsh make 
```
For other Linux distro should consult the manual. <br />
  * **(2)**  Download program from github <br />
Create directory NWCHEM at */usr/local/src/*. Then move to NWCHEM direcotry
```
mkdir /usr/local/src/NWCHEM && cd /usr/local/src/NWCHEM
```
Then download program source code from [NWChem github](https://github.com/nwchemgit/nwchem) to your Linux machine using **wget** command. The release of NWChem can be found [here](https://github.com/nwchemgit/nwchem/releases/tag/v6.8-release). You can download source code (compress file) of NWChem 6.8 using command
```
wget https://github.com/nwchemgit/nwchem/releases/download/v6.8-release/nwchem-6.8-release.revision-v6.8-47-gdf6c956-src.2017-12-14.tar.bz2
```
Then extract the source code *.tar.bz2* file using command
```
tar -xvjf nwchem-6.8-release.revision-v6.8-47-gdf6c956-src.2017-12-14.tar.bz2
```
You should see *nwchem-6.8* directory. <br />
* **(3)** Compiling NWChem <br />
Download [compile-nwchem-auto.sh](https://raw.githubusercontent.com/rangsimanketkaew/NWChem/master/compile-nwchem-auto.sh) script to */usr/local/src/NWCHEM/nwchem-6.8/*.
```
cd /usr/local/src/NWCHEM/nwchem-6.8/
wget https://raw.githubusercontent.com/rangsimanketkaew/NWChem/master/compile-nwchem-auto.sh
```
Run the script using command
```
chmod 755 compile-nwchem-auto.sh
./compile-nwchem-auto.sh
```
--> Enter 2 for compiling NWChem. <br />
--> Enter the directory of nwchem-6.x to be used as $NWCHEM_TOP. <br />
The process will take you about 30 minutes. <br />
  * **(4)**  Setting of environmental variable for NWChem: Run the script using command
```
./compile-nwchem-auto.sh
```
--> Enter "3" <br />
  * **(5)**  Make resource file for NWChem: Run the script using command
```
./compile-nwchem-auto.sh
```
--> Enter "4" <br />
The resource file of NWChem *.nwchemrc* should be located at your $HOME directory. <br />
## Post-Compilation
Run a sample calculation to check whether NWChem program is installed perfectly. I include [a input file](https://raw.githubusercontent.com/rangsimanketkaew/NWChem/master/test/test-azulene-dft/test-azulene.nw) of geometry optimization of azulene using DFT/M06-2X/6-31G(d) in gas phase.
```
nwchem test-azulene.nw >& test-azulene.out &
```
Caveat! Note that the day I posted this script I was using NWChem version 6.6 and 6.8 on CentOS 6.9.
**Optional: PATH SETTING.** Instead of running nwchem using its absolute path, you can make an aliase of NWChem program by adding the *nwchem* absolute path to $PATH using command
```
export PATH=/usr/local/nwchem-6.6/bin/LINUX/nwchem:$PATH
```
To do this every time you login, each user must permanently append the above command to $PATH in *$HOME/.bashrc* file.
```
echo export PATH=/usr/local/nwchem-6.6/bin/LINUX/nwchem:$PATH >> /home/$USER/.bashrc
```
Then activate the *.bashrc* file
```
source /home/$USER/.bashrc
```
Try to logout and login again, now you can run NWChem via *nwchem*.
## Running the tests
You can try to run nwchem with example file offered by the developer. A ton of input & output files are at **$NWCHEM_TOP/QA/tests** and **$NWCHEM_TOP/examples/**. Running NWChem calculation on standalone machine or HPC cluster with OpenMPI parallel using command
```
mpirun -np N nwchem INPUT-FILE.nw >& OUTPUT-FILE.log
```
To run NWChem with multithreaded/OpenMPI, one can use command
```
mpirun -np N -map-by socket -bind-to socket nwchem INPUT-FILE.nw >& OUTPUT-FILE.log
```
The following command may be useful
```
export OMP_NUM_THREADS=M
```
where N and M = number of processors and threads (integer & positive number), respectively. Set number of threads = 1 is recommended if the cluster/machine do not do I/O or even you do not know. This value provides the best performance. You can add optional to set the calculation for either single or multi-threaded process.
```
mpirun -genv OMP_NUM_THREADS M -np N nwchem INPUT-FILE.nw >& OUTPUT-FILE.log 
```
---
Running on MPI Cluster using MPICH
```
mpirun -np $NSLOTS nwchem INPUT-FILE.nw >& OUTPUT-FILE.log
```
Running on MPI Cluster using MVAPICH2
```
mpirun -genv OMP_NUM_THREADS M -genv MV2_ENABLE_AFFINITY 0 -np N nwchem INPUT-FILE.nw >& OUTPUT-FILE.log
```
The total number of cpu cores used for this calculation will be M x N. <br />
If you run NWChem using command like *"mpirun -np N nwchem INPUT-FILE.nw"*, this means the memory required for this calculation = (1 GB)x(N processors). More details of memory arrangement can be found on [this website](http://www.nwchem-sw.org/index.php/Release66:Top-level#MEMORY)
## Error & Fixing
* Error: `libmpi_f90.so.1: cannot open` <br />
When: Installing NWChem using **make** or **configuration setting up** command. <br />
Fix: You can fix this error using command
```
export LD_LIBRARY_PATH=/usr/local/openmpi/lib/:$LD_LIBRARY_PATH
source $HOME/.bashrc
```

* Error: `utilfname: cannot allocate`  or  `utilfname: cannot allocate:Received an Error in Communication` <br />
When: Running NWChem with MPI and cannot allocate the memory with number of processors. <br />
Fix: You must specify the amount of memory **PER** processor core that NWChem can possibly employs for a calculation. <br />
This issue can be easily fixed by *memory* keyword to control the certain memory, for example a following command is used to limit the memory to 1 Gigabyte/process.
```
memory total 1 GB
```

* Error: `GNUmakefile:103: recipe for target 'libraries' failed` and `make: *** [libraries] Error 1 ` <br />
When: Compiling NWChem with make command <br />
Fix: Check the suitable MPI libraries that you can use. Run the script and press [1] or run following command
```
mpif90 -show
```
## More details
- You should pay attention to NWChem manual before using my script. Do not trust the script but it works for me.
- I also provide the scripts (in this repository) of NWChem compilation for other platform or parallel achitecture. 
- If compiling of NWChem using hand-made script is too difficult, you can install NWChem executable using *rpm* and *yum*, visit [this website](https://sites.google.com/site/compchem403/personal-area/linux-knowledge/install-nwchem). The binary rpm file of various flavor of NWChem version 6.6, i.e., nwchem-common, nwchem-openmpi, and nwchem-mpich can be found at [PKGS.org](https://pkgs.org/download/nwchem) and [RPM Find](https://www.rpmfind.net/linux/rpm2html/search.php?query=nwchem&submit=Search+...). 
- [This post](https://sites.google.com/site/rangsiman1993/abinitio/install-nwchem) in my website might be helpful.
- If you have any problems you can consult the [Q&A forum of NWChem](http://www.nwchem-sw.org/index.php/Special:AWCforum) or visit [NWChem compilation](http://www.nwchem-sw.org/index.php/Compiling_NWChem#Setting_up_the_proper_environment_variables). 
## Author
- Rangsiman Ketkaew E-mail: [rangsiman1993(at)gmail.com](rangsiman1993@gmail.com) and [rangsiman_k(at)sci.tu.ac.th](rangsiman_k@sci.tu.ac.th)
## Acknowledgments
- NWChem developer
- NWChem manual
