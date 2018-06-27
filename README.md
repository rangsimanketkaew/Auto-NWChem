# NWChem Auto Compilation

<p align="center">
   <img alt="Capture_Menu" src="https://github.com/rangsimanketkaew/NWChem/blob/master/etc/Capture_Menu.PNG" align=middle width="450pt" hight="100pt" /> 
<p/>
<br />

An automated program for compiling NWchem with MPICH / MVAPICH2 / MVAPICH23 / Intel MPI+MKL / OpenMPI on Linux cluster.  <br />

## Prerequisites

* Linux distro
  * CentOS 6.x or 7.x
  * Ubuntu 16.x or 17.x
* BLAS/OpenBLAS [ and Scalapack ]
* Python version 1.x or 2.6 or 2.7
* MPICH or MVAPICH2 or MVAPUCH23 or Intel MPI+MKL or OpenMPI or any MPI
* Compiler: GNU, Intel, PGI, etc. (More details please consult [NWChem manual](http://www.nwchem-sw.org/index.php/Compiling_NWChem#Setting_up_the_proper_environment_variables))

### Math libraries

#### OpenMPI Installation

* [Download here](https://www.open-mpi.org/software/ompi/v3.0/)
* Installation step-by-step, [please visit this website](https://sites.google.com/site/rangsiman1993/linux/install-openmpi). 
* Set the environment variables and libraries properly.

#### OpenBLAS Installation

* [Download here](https://github.com/xianyi/OpenBLAS).
* Installation is at [Installation guide](https://github.com/xianyi/OpenBLAS/wiki/Installation-Guide).
* OSX: Brew installation will put OpenBlas in `/usr/local/opt/openblas`

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

## Installing

* **(1)**  Install required package for NWChem <br />
> **CentOS**:
```
sudo yum install python-devel gcc-gfortran openblas-devel openblas-serial64 openmpi-devel scalapack-openmpi-devel blacs-openmpi-devel elpa-openmpi-devel tcsh --enablerepo=epel
```
> **Ubuntu**:
```
sudo apt-get install python-dev gfortran libopenblas-dev libopenmpi-dev openmpi-bin tcsh make 
```
For other Linux distro, please consult NWChem manual. <br />

* **(2)**  Download program source code from [NWChem github](https://github.com/nwchemgit/nwchem) to your home directory. Release file available at [here](https://github.com/nwchemgit/nwchem/releases/tag/v6.8-release).
```
wget https://github.com/nwchemgit/nwchem/releases/download/6.8.1-release/nwchem-6.8.1-release.revision-v6.8-133-ge032219-src.2018-06-14.tar.bz2
```
Then extract a *.tar.bz2* file using command
```
tar -xvf nwchem-6.8.1-release.revision-v6.8-133-ge032219-src.2018-06-14.tar.bz2
```
You should see *nwchem-6.8.1* directory. <br />

* **(3)** Download [Automatic-NWChem-Compilation.sh](https://github.com/rangsimanketkaew/NWChem/blob/master/Automatic-NWChem-Compile.sh) program to your Linux machine using following command
```
wget https://raw.githubusercontent.com/rangsimanketkaew/NWChem/master/Automatic-NWChem-Compile.sh
```
Change permission of script.
```
chmod 755 Automatic-NWChem-Compile.sh
```
Run script and follow the instruction of compilation.
```
./Automatic-NWChem-Compile.sh
```
For help page, run `./Automatic-NWChem-Compile.sh -h` or `./Automatic-NWChem-Compile.sh -help`.

## Post-Compilation

Run a sample calculation to check if NWChem is installed correctly. I include [a input file](https://raw.githubusercontent.com/rangsimanketkaew/NWChem/master/test/test-azulene-dft/test-azulene.nw) of geometry optimization of azulene using DFT/M06-2X/6-31G(d) in gas phase.
```
nwchem test-azulene.nw >& test-azulene.out &
```
Caveat! Note that the day I posted this script I was using NWChem version 6.6 and 6.8 on CentOS 6.9. <br />

**Optional: PATH SETTING.** Instead of running nwchem using its absolute (full) path, you can make an aliase of NWChem program by adding the *nwchem* absolute path to $PATH using command
```
export PATH=/usr/local/nwchem-6.6/bin/LINUX/nwchem:$PATH
```
To do this every time you login, each user must permanently append the above command to $PATH in *$HOME/.bashrc* file.
```
echo export PATH=/usr/local/nwchem-6.6/bin/LINUX/nwchem:$PATH >> $HOME/.bashrc
```
Then activate the *.bashrc* file
```
source /home/$USER/.bashrc
```
Logout and login again, now you can run NWChem via *nwchem*.

## Partial recompile

When you modify the code in `src` directory, program executable `nwchem` is needed to be compiled again. Due to full compilation of NWChem normally takes 20 - 30 minutes, you can easily recompile program executable withon a few seconds/minutes, depending on how much you have modified the code. To do this, just use `make` and `make link` commands to install that particular modified fortran code and link a new executable.<be />
First, create the scrip that includes all necessary environment variables setting that you have used for full compilation. (For this script, you can use the script that you used to compile program for the first time.) Then nevigate to sub-directory where you have modified the code and then append the following commands to the recompile script, e.g., you have modified fortran code in `$NWCHEM_TOP/src/nwdft/scf_dft` directory.

```
export USE_64TO32=y

cd $NWCHEM_TOP/src/nwdft/scf_dft
make

cd $NWCHEM_TOP/src
make link
```

NWChem execuable file, `$NWCHEM_TOP/bin/LINUX64/nwchem`, will be replaced with the updated executable.  <br />
P.S. `export USE_64TO32=Y` is needed for compilng program based on 32bit Libraries.

## Running the tests
### Standalone machine
Example of input & output files are available at **$NWCHEM_TOP/QA/tests** and **$NWCHEM_TOP/examples/**. Running NWChem calculation on standalone machine or HPC cluster with OpenMPI parallel using command
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
### Distributed memory cluster
Visit [this repository](https://github.com/rangsimanketkaew/PBS-submission) for using job scheduler, such as PBS Pro, PBS, and SGE to submit NWChem job on connected cluster.

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
