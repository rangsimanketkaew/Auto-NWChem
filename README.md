# NWChem
This repository includes scripts for NWChem's automatic compilation on Centos 6.x &amp; 7.x <br />
and example test file of optimization calculation of azulene molecule using DFT at M06-2X/6-31G(d) level of theory.
<br />
If there is error like ' ', you have to use this command to fix this
```
export LD_LIBRARY_PATH=/usr/local/openmpi/lib/:$LD_LIBRARY_PATH
source $HOME/.bashrc
```

# Usage
Very easy to use, download a nwchem-x.x.tar.gz from NWChem website using wget command. <br />
Then run script [1_compile.sh](https://github.com/rangsimanketkaew/NWChem/blob/master/1_compile.sh) and then [2_path.sh](https://github.com/rangsimanketkaew/NWChem/blob/master/2_path.sh), respectively. More instruction can be found in script [1_compile.sh](https://github.com/rangsimanketkaew/NWChem/blob/master/1_compile.sh). !

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
