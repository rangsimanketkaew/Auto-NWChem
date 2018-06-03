#!/bin/bash

#################################################################################################
#  Program for NWChem compilation on CentOS / Rocks Cluster with MVAPICH2 Intel and Infiniband  #
#  SCALAPACK 32 bits is used with NWChem 64 bits, so program must be compiled as 64_to_32       #
#  Written by Rangsiman Ketkaew (MSc student in Chemistry), Thammasat University, Thailand.     #
#################################################################################################

## For compile with scalapack 32 bits (integer*4), the following 2 env variables are needed
# "export BLAS_SIZE=4"
# "export SCALAPACK_SIZE=4"
## Compile as 32 bits
# "make 64_to_32"
# "make USE_64TO32=y"
## And math library must be suitable with 32 bits, e.g. 
# -lmkl_intel_lp64, not -lmkl_intel_ilp64

module purge
module load /share/apps/modulefiles/gcc48 mvapich2-2.2b_intel2013

export MKLROOT=/share/apps/intel/composer_xe_2013_sp1.3.174/mkl
export NWCHEM_TOP=/share/apps/nwchem-6.6/nwchem-6.8-SCALAPACK-32
export NWCHEM_TARGET=LINUX64
export ARMCI_NETWORK=OPENIB
export CC=icc
export FC=ifort link
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
export PYTHONVERSION=2.6
export USE_PYTHONCONFIG=1
export HAS_BLAS=yes
export BLAS_LOC="$MKLROOT/lib/intel64"
export BLASOPT="-lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -liomp5 -lpthread -lm -ldl"
export BLAS_SIZE=4
export USE_SCALAPACK=y
export SCALAPACK_SIZE=4
export SCALAPACK="-L$MKLROOT/lib/intel64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread"
export SCALAPACK_LIB="$SCALAPACK"
export MAKE=/usr/bin/make
export LD_LIBRARY_PATH="/share/apps/mpi/mvapich2-2.2b_intel2013/lib:/share/apps/python/lib/:/export/apps/intel/composer_xe_2013_sp1.3.174/compiler/lib/intel64/"
export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export MPIROOT=/share/apps/mpi/mvapich2-2.2b_intel2013/
export MPIEXEC=$MPIROOT/bin/mpiexec
export MPI_LIB=$MPIROOT/lib
export MPI_INCLUDE=/share/apps/mpi/mvapich2-2.2b_intel2013/include
export LDFLAGS="-L/export/apps/compilers/intel2013/composer_xe_2013_sp1.3.174/compiler/lib/intel64/"

$MAKE realclean
$MAKE nwchem_config NWCHEM_MODULES="all python" 2>&1 | tee ../make_nwchem_config_mpich.log
$MAKE 64_to_32 2>&1 | tee ../make_64_to_32_mpich.log
export MAKEOPTS="USE_64TO32=y"
$MAKE ${MAKEOPTS} 2>&1 | tee ../makefile.log
