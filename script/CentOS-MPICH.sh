#!/bin/bash
###############################################################################################
#  Program for NWChem compilation on CentOS / Rocks Cluster with MPICH & Infiniband           #
#  MPICH & MPICH2 GNU-based are supported.                                                    #
#  Written by Rangsiman Ketkaew (MSc student in Chemistry), Thammasat University, Thailand.   #
###############################################################################################

# The environment variable and configuration settings in this bash script is optimized and used 
# for compiling NWChem 6.6, 6.8, and 6.8.1 on CentOS/Rocks Chalawan cluster (http://chalawan.narit.or.th).
# It should be able to make use of a larger number of CPUs across distributed nodes.
# This script utilized the python 2.6 and mvapich2-2.2b_intel2013.

export NWCHEM_TOP=/builddir/build/BUILD/nwchem-6.6
export NWCHEM_TARGET=LINUX64
export CC=gcc
export FC=gfortran
export USE_ARUR=TRUE
export USE_NOFSCHECK=TRUE
export NWCHEM_FSCHECK=N
export LARGE_FILES=TRUE
export MRCC_THEORY=Y
export EACCSD=Y
export IPCCSD=Y
export CCSDTQ=Y
export CCSDTLR=Y
export NWCHEM_LONG_PATHS=Y
export PYTHONHOME=/usr
export PYTHONVERSION=2.7
export PYTHONLIBTYPE=so
export USE_PYTHON64=y
export HAS_BLAS=yes
export BLASOPT="-L/usr/lib64 -lopenblas"
export BLAS_SIZE=4
export MAKE=/usr/bin/make
export LD_LIBRARY_PATH=/usr/lib64/mpich/lib
export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export MPIEXEC=/usr/lib64/mpich/bin/mpiexec
export MPI_LIB=/usr/lib64/mpich/lib
export MPI_INCLUDE=/usr/include/mpich-x86_64
export LIBMPI="-lmpich"

$MAKE nwchem_config NWCHEM_MODULES="all python" 2>&1 | tee ../make_nwchem_config_mpich.log
$MAKE 64_to_32 2>&1 | tee ../make_64_to_32_mpich.log
export MAKEOPTS="USE_64TO32=y"
$MAKE ${MAKEOPTS} 2>&1

