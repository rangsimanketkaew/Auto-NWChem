#!/bin/bash
# Bash script for compiling of NWChem on Centos 6.x & 7.x using OpenMPI.
# Written by Rangsiman Ketkaew, MSc student in Chemistry, CCRU, Thammasat University, Thailand.

echo "========== Welcome ==========
 [1] Compile NWChem program
 [2] Set environment variable
 [3] Make resource file
 [4] Contact me
 [5] Exit"
read -p "Enter: " inp1

if [ $inp1 == 1 ];then
read -p "Enter \$NWCHEM_TOP, e.g., /home/jack/nwchem-6.8: " inp2
if [ -e $inp2 ];then
:<<'comment'
 (1) Environmental configuration & Compilation using Make
 export NWCHEM_TOP=/nwchem/install/folder/
 I use an openmpi-1.6.5 as mpirun which is installed at /usr/local/openmpi/
 I use python version 2.7.x (checking by $ python --version)
 Show a library for MPI using command $ mpif90 -show
comment

export NWCHEM_TOP=$inp2
cd $NWCHEM_TOP/src
# ------------------MPI libraries box -------------------
export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export MPI_LOC=/usr/local/openmpi
export MPI_LIB=$MPI_LOC/lib
export MPI_INCLUDE=$MPI_LOC/include
export LIBMPI="-lmpi_f90 -lmpi_f77 -lmpi -ldl -Wl,--export-dynamic -lnsl -lutil"
# -------------------------------------------------------
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

echo "Let's build NWCHEM" > $inp2/script-compile.log
make nwchem_config NWCHEM_MODULES="all python"
wait
echo " Finished configuration setting up using python " >> script-compile.log
make 64_to_32
wait
echo " Finished changing 64 to 32 " >> script-compile.log
echo " Making install, please wait for a while ! " >> script-compile.log
make >& script-compile-make.log
wait
echo " Don't forget to check make.log at $NWCHEM_TOP/src/make.log if any error occur. " >> script-compile.log
echo " Also check if nwchem.exe is installed at $NWCHEM_TOP/bin/LINUX64/ " >> script-compile.log
echo " ------------------------ Make done --------------------------" >> script-compile.log
else
echo "No directory of $inp2"
fi
exit
elif [ $inp1 == 2 ];then

:<<'comment'
 (2) set environmental variable path of NWChem
 ----------------------------- #
 Determine the local storage path for the install files. (e.g., /usr/local/nwchem).
 Make directories
comment

export NWCHEM_TOP=$inp2
export NWCHEM_TARGET=LINUX64

mkdir /usr/local/nwchem/
mkdir /usr/local/nwchem/bin
mkdir /usr/local/nwchem/data

cp $NWCHEM_TOP/bin/${NWCHEM_TARGET}/nwchem /usr/local/nwchem/bin
cd /usr/local/nwchem/bin
chmod 755 nwchem

cd $NWCHEM_TOP/src/basis
cp -r libraries /usr/local/nwchem/data
cd $NWCHEM_TOP/src/
cp -r data /usr/local/nwchem
cd $NWCHEM_TOP/src/nwpw
cp -r libraryps /usr/local/nwchem/data

echo "# ------------------ Done ----------------- #"  >> script-compile.log
echo "# ------- Try to run NWChem program ------- #"  >> script-compile.log

:<<'comment'
 (3) Creat a .nwchemrc file to point to these default data files.
comment

elif [ $inp1 == 3 ];then
touch $HOME/.nwchemrc
echo "nwchem_basis_library /usr/local/nwchem/data/libraries/
nwchem_nwpw_library /usr/local/nwchem/data/libraryps/
ffield amber
amber_1 /usr/local/nwchem/data/amber_s/
amber_2 /usr/local/nwchem/data/amber_q/
amber_3 /usr/local/nwchem/data/amber_x/
amber_4 /usr/local/nwchem/data/amber_u/
spce    /usr/local/nwchem/data/solvents/spce.rst
charmm_s /usr/local/nwchem/data/charmm_s/
charmm_x /usr/local/nwchem/data/charmm_x/
" >> $HOME/.nwchemrc
elif [ $inp1 == 4 ];then
echo "
 <> Rangsiman Ketkaew (MSc), Department of Chemsitry, Thammasat University, Thailand
 <> rangsiman1993@gmail.com
 <> https://github.com/rangsimanketkaew
"
elif [ $inp1 == 5 ];then
exit
else
echo "You enter an incorrect choice"
fi
exit
