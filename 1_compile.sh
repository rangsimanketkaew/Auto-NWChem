#!/bin/bash
#### Bash script for NWChem's compilation on Centos 6.x & 7.x Linux distributions.
#### Written by Rangsiman Ketkaew, Master degree student in Chemistry, CCRU, Thammasat U., Thailand.
#### (1) Environmental configuration & Compilation using Make

## export NWCHEM_TOP=/nwchem/install/folder/
## I use an openmpi-1.6.5 as mpirun which is installed at /usr/local/openmpi/

echo "Let's build NWCHEM"

export NWCHEM_TOP=/usr/local/src/NWCHEM/nwchem-6.6
cd $NWCHEM_TOP/src

export ARMCI_NETWORK=OPENIB
export USE_MPI=y
export NWCHEM_TARGET=LINUX64
export USE_PYTHONCONFIG=y
export PYTHONVERSION=2.7
export PYTHONHOME=/usr
export USE_64TO32=y
export BLAS_SIZE=4
export BLASOPT="-lopenblas -lpthread -lrt"
export SCALAPACK_SIZE=4
export SCALAPACK="-L/usr/local/openmpi/lib -lscalapack -lmpiblacs"
export ELPA="-I/usr/lib64/gfortran/modules/openmpi -L/usr/local/openmpi/lib -lelpa"
export LD_LIBRARY_PATH=/usr/local/openmpi/lib/:$LD_LIBRARY_PATH
export PATH=/usr/local/openmpi/bin/:$PATH

make nwchem_config NWCHEM_MODULES="all python"
wait
echo " Finished configuration setting up using python "
make 64_to_32
wait
echo " Finished changing 64 to 32 "
make >& make.log
wait
echo " Don't forget to check make.log at $NWCHEM_TOP/src/make.log if any error occur. "
echo " Also check if nwchem.exe is installed at $NWCHEM_TOP/bin/LINUX64/ "
echo "------------------------ Make done --------------------------"
echo "Please follow the 2nd script --> run_NWchem_Nutt_setpath.sh"

#### (2) Let's go to run_NWchem_Nutt_setpath.sh 
#### Note that each user will need a .nwchemrc file to point to these default data files.
#### HAVE FUN
