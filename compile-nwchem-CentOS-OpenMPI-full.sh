#!/bin/bash
# Bash script for compiling of NWChem on Centos 6.x & 7.x using OpenMPI.
# Written by Rangsiman Ketkaew, MSc student in Chemistry, CCRU, Thammasat University, Thailand.

# (1) Environmental configuration & Compilation using Make
# export NWCHEM_TOP=/nwchem/install/folder/
# I use an openmpi-1.6.5 as mpirun which is installed at /usr/local/openmpi/
# I use python version 2.7.x (checking by $ python --version)
# Show a library for MPI using command $ mpif90 -show

echo "Let's build NWCHEM" > script-compile.log

export NWCHEM_TOP=/usr/local/src/NWCHEM/nwchem-6.6
cd $NWCHEM_TOP/src

# export ARMCI_NETWORK=OPENIB

export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export MPI_LOC=/usr/local/openmpi
export MPI_LIB=$MPI_LOC/lib
export MPI_INCLUDE=$MPI_LOC/include
export LIBMPI="-lmpi_f90 -lmpi_f77 -lmpi -ldl -Wl,--export-dynamic -lnsl -lutil"

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
echo " Making install, please wait for a while ! "
make >& make.log
wait
echo " Don't forget to check make.log at $NWCHEM_TOP/src/make.log if any error occur. " >> script-compile.log
echo " Also check if nwchem.exe is installed at $NWCHEM_TOP/bin/LINUX64/ " >> script-compile.log
echo " ------------------------ Make done --------------------------" >> script-compile.log

# (2) set environmental variable path of NWChem
# ----------------------------- #
# Determine the local storage path for the install files. (e.g., /usr/local/nwchem).
# Make directories

export NWCHEM_TOP=/usr/local/src/NWCHEM/nwchem-6.6
export NWCHEM_TARGET=LINUX64

mkdir /usr/local/nwchem/
mkdir /usr/local/nwchem/bin
mkdir /usr/local/nwchem/data

# ----------------------------- #
# Copy binary

cp $NWCHEM_TOP/bin/${NWCHEM_TARGET}/nwchem /usr/local/nwchem/bin
cd /usr/local/nwchem/bin 
chmod 755 nwchem

# ----------------------------- #
# Set links to data files (binaries, basis sets, force fields, etc.)

cd $NWCHEM_TOP/src/basis
cp -r libraries /usr/local/nwchem/data

cd $NWCHEM_TOP/src/
cp -r data /usr/local/nwchem

cd $NWCHEM_TOP/src/nwpw
cp -r libraryps /usr/local/nwchem/data

echo "# ------------------ Done ----------------- #"  >> script-compile.log
echo "# ------- Try to run NWChem program ------- #"  >> script-compile.log

# Note that each user will need a .nwchemrc file to point to these default data files.
