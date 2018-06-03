#!/bin/bash
############################################################################################################
#  Program for NWChem compilation on CentOS / Rocks Cluster with MVAPICH2 Intel with ARMCI and Infiniband  #
#  Written by Rangsiman Ketkaew (MSc student in Chemistry), Thammasat University, Thailand.                #
############################################################################################################

# It should be able to make use of a larger number of CPUs across distributed nodes.
# This script utilized the python 2.6 and mvapich2-2.2b_intel2013.

# The environment variable setting used in this bash script is for compiling NWChem 6.6
# on SGE on Chalawan cluster (http://chalawan.narit.or.th).

# You need to install ARMCI first !

module purge
module load /share/apps/modulefiles/gcc48 mvapich2-2.2b_intel2013 python2.7

export MKLROOT=/share/apps/intel/composer_xe_2013_sp1.3.174/mkl
export NWCHEM_TOP=/share/apps/nwchem-6.6/nwchem-6.8-armci
export NWCHEM_TARGET=LINUX64
export ARMCI_NETWORK=ARMCI
export EXTERNAL_ARMCI_PATH=/share/apps/nwchem-6.6/nwchem-6.6/src/tools/..//external-armci
export CC=icc
export FC=ifort link
#export USE_ARUR=TRUE
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
#export PYTHON_LIB=
export PYTHONVERSION=2.6
export USE_PYTHONCONFIG=1
#export PYTHONLIBTYPE=so
#export USE_PYTHON64=y
export HAS_BLAS=yes
export BLAS_LOC=${MKLROOT}/lib/intel64
export BLASOPT="-lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -liomp5 -lpthread -lm -ldl"
export BLAS_SIZE=4
export MAKE=/usr/bin/make
export LD_LIBRARY_PATH="/share/apps/mpi/mvapich2-2.2b_intel2013/lib:/share/apps/python/lib/:/export/apps/intel/composer_xe_2013_sp1.3.174/compiler/lib/intel64/"
export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export MPIEXEC=/share/apps/mpi/mvapich2-2.2b_intel2013/bin/mpiexec
export MPI_LIB=/share/apps/mpi/mvapich2-2.2b_intel2013/lib
export MPI_INCLUDE=/share/apps/mpi/mvapich2-2.2b_intel2013/include
export LDFLAGS="-L/export/apps/compilers/intel2013/composer_xe_2013_sp1.3.174/compiler/lib/intel64/"

#$MAKE realclean
$MAKE nwchem_config NWCHEM_MODULES="all python" 2>&1 | tee ../make_nwchem_config_mpich.log
$MAKE 64_to_32 2>&1 | tee ../make_64_to_32_mpich.log
export MAKEOPTS="USE_64TO32=y"
$MAKE ${MAKEOPTS} 2>&1 | tee ../makefile.log
