# NWChem Auto Compilation
A programing script for auto compile NWChem program on CentOS 6.x &amp; 7.x & Ubuntu 16.x & 17.x. Do not trust the script but it works for me. It can also be adjusted to be compatible with other Linux distribution.
### Requirement
* NWChem version 6.x (recommended is 6.8)
* CentOS version 6.x / 7.x or 16.x / 17.x (or other Linux distro)
* Python version 2.6 / 2.7
* Suitable MPI libraries (e.g. OpenMPI)
* Compiler: Intel, GNU, PGI, etc. More details please consult [NWChem manual](http://www.nwchem-sw.org/index.php/Compiling_NWChem#Setting_up_the_proper_environment_variables).
### Installation
- **(1)**  Install required package <br />
> **CentOS**: Install the following package using yum command (root or sudo) <br />
```
yum install python-devel gcc-gfortran openblas-devel openblas-serial64 openmpi-devel scalapack-openmpi-devel blacs-openmpi-devel elpa-openmpi-devel tcsh --enablerepo=epel
```
> **Ubuntu**: Install the following package using apt-get command (root or sudo)
```
sudo apt-get install python-dev gfortran libopenblas-dev libopenmpi-dev openmpi-bin tcsh make 
```
  * **(2)**  Download program from github <br />
Create directory NWCHEM at */usr/local/src/*. Then move to NWCHEM direcotry
```
mkdir /usr/local/src/NWCHEM && cd /usr/local/src/NWCHEM
```
Then download program source code from [NWChem github](https://github.com/nwchemgit/nwchem) to your Linux machine using **wget** command. The release of NWChem can be found [here](https://github.com/nwchemgit/nwchem/releases/tag/v6.8-release). <br />
I downloaded the NWChem 6.8 using command
```
wget https://github.com/nwchemgit/nwchem/releases/download/v6.8-release/nwchem-6.8-release.revision-v6.8-47-gdf6c956-src.2017-12-14.tar.bz2
```
Extract full source code from *.tar.bz2* file using command.
```
tar -xvjf nwchem-6.8-release.revision-v6.8-47-gdf6c956-src.2017-12-14.tar.bz2
```
Then you should see *nwchem-6.8 directory*. <br />
* **(3)** Compiling program <br />
Download [cp-nw-CentOS-OpenMPI-auto.sh](https://raw.githubusercontent.com/rangsimanketkaew/NWChem/master/cp-nw-CentOS-OpenMPI-auto.sh) script to */usr/local/src/NWCHEM/nwchem-6.8/*.
```
cd /usr/local/src/NWCHEM/nwchem-6.8/
wget https://raw.githubusercontent.com/rangsimanketkaew/NWChem/master/compile-nwchem-CentOS-OpenMPI-full.sh
```
Run the script using command
```
chmod 755 cp-nw-CentOS-OpenMPI-auto.sh
./cp-nw-CentOS-OpenMPI-auto.sh
```
Enter 1 for compiling NWChem. <br />
Enter the directory of nwchem-6.x to be used as $NWCHEM_TOP. <br />
The process will take you about 30 minutes. <br />
  * **(4)**  Setting environmental variable path of NWChem
Run the script using command
```
./cp-nw-CentOS-OpenMPI-auto.sh
```
Enter "2" <br />

  * **(5)**  Setting resource file *.nwchemrc* <br />
Run the script using command
```
./cp-nw-CentOS-OpenMPI-auto.sh
```
Enter "3" <br />
# Post-Compilation
Run a sample calculation to check whether NWChem program is installed perfectly. I include [a input file](https://github.com/rangsimanketkaew/NWChem/blob/master/test-azulene-dft/test-azulene.nw) of geometry optimization of azulene using DFT/M06-2X/6-31G(d) in gas phase.
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
# Running NWChem
You can try to run nwchem with example file offered by the developer. A ton of input & output files are at **/usr/local/src/NWCHEM/nwchem-6.6/examples/** and **/usr/local/src/NWCHEM/nwchem-6.6/QA/tests**. Running calculation on standalone machine or HPC cluster with OpenMPI parallel using command
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
# Error & Fixing
* Error: *libmpi_f90.so.1: cannot open*
When: Installing NWChem using **make** or **configuration setting up** command.<br />
Fix: You can fix this error using command
```
export LD_LIBRARY_PATH=/usr/local/openmpi/lib/:$LD_LIBRARY_PATH
source $HOME/.bashrc
```

* Error: *utilfname: cannot allocate*  or  *utilfname: cannot allocate:Received an Error in Communication* <br />
when: Running NWChem with MPI and cannot allocate the memory with number of processors.
Fix: You must specify the amount of memory **PER** processor core that NWChem can possibly employs for a calculation. <br />
This issue can be easily fixed by *memory* keyword to control the certain memory, for example a following command is used to limit the memory to 1 Gigabyte/process.
```
memory total 1 GB
```

* Error: about MPI libraries.
when: Compiling NWChem with make command
```
GNUmakefile:103: recipe for target 'libraries' failed
make: *** [libraries] Error 1
```
Fix: Check the suitable libraries that you can use by command
```
mpif90 -show
```
## OpenMPI 1.6.5 Installation
[Please visit this website](http://lsi.ugr.es/~jmantas/pdp/ayuda/datos/instalaciones/Install_OpenMPI_en.pdf). Not only version 1.6.5, but also other version says 2.x are also used in conjunction with NWChem compilation as long as you set the linkink and compatible libraries correctly.
## OpenBLAS Installation
You may need to install OpenBLAS yourself. Download source file at [Download here](https://www.open-mpi.org/software/ompi/v1.6/) <br />
Explanation of installation is here [Installation guide](https://github.com/xianyi/OpenBLAS/wiki/Installation-Guide).
## More details
I also provide the scripts (in this repository) of NWChem compilation for other platform or parallel achitecture. Additionally, if compiling of NWChem manually is too difficult, you can install NWChem executable using *rpm* and *yum*, visit [this website](https://sites.google.com/site/compchem403/personal-area/linux-knowledge/install-nwchem). The binary rpm file of various flavor of NWChem version 6.6, i.e., nwchem-common, nwchem-openmpi, and nwchem-mpich can be found at [PKGS.org](https://pkgs.org/download/nwchem) and [RPM Find](https://www.rpmfind.net/linux/rpm2html/search.php?query=nwchem&submit=Search+...). However, [this website](https://sites.google.com/site/compchem403/personal-area/linux-knowledge/install-nwchem). was written in Thai. If you have any problems you can consult the [Q&A forum of NWChem](http://www.nwchem-sw.org/index.php/Special:AWCforum) or visit [NWChem compilation](http://www.nwchem-sw.org/index.php/Compiling_NWChem#Setting_up_the_proper_environment_variables). You can contact me at e-mail: [rangsiman1993(at)gmail.com](rangsiman1993@gmail.com) and [rangsiman_k(at)sci.tu.ac.th](rangsiman_k@sci.tu.ac.th).
