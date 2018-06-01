#!/bin/bash
##############################################################################################
#  Bash script for compiling of NWChem on Ubuntu 17.10 using OpenMPI                         #
#  Written by Rangsiman Ketkaew (MSc student in Chemistry), Thammasat University, Thailand.  #
##############################################################################################

# Compiling of NWChem 6.8 on Ubuntu 17.10.1 (Artful Aardvark)
# Use NWCHEM's BLAS & OpenMPI 1.8.1
# mpif90 -show = -lmpi_usempi -lmpi_mpifh -lmpi
# The lines in MPI libraries box should be adjusted to satify the library/environment of your machine.

export NWCHEM_TOP=/home/nutt/nwchem-6.8
export NWCHEM_TARGET=LINUX64
export MAKE=/usr/bin/make
export USE_NOFSCHECK=TRUE
export PYTHONHOME=/usr
export PYTHONVERSION=2.7
export USE_PYTHON64=y
export USE_PYTHONCONFIG=y
export BLASOPT="-lopenblas -lpthread -lrt"
export BLAS_SIZE=4
export USE_64TO32=y
## ---------------------- MPI Libraries box ---------------------------
export LD_LIBRARY_PATH=/usr/local/openmpi-1.8.1/lib/:$LD_LIBRARY_PATH
export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export MPI_LOC=/usr/local/openmpi-1.8.1
export MPI_LIB=/usr/local/openmpi-1.8.1/lib
export MPI_INCLUDE=/usr/local/openmpi-1.8.1/include
export LIBMPI="-lmpi_usempi -lmpi_mpifh -lmpi"
## --------------------------------------------------------------------

make nwchem_config NWCHEM_MODULES="all python"
make 64_to_32
make
