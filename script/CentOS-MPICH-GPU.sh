#!/bin/bash

# Note that the following environment variables and configuration settings are optimized for 
# compiling NWChem 6.8.1 on CentOS-based Chalawan Cluster equipped with Infiniband interconnect
# (http://chalawan.narit.or.th) using OpenMP + MPICH and GPU enabled.
# It should be able to make use of a larger number of CPUs across distributed nodes.

export NWCHEM_TOP=/builddir/build/BUILD/nwchem-6.8.1
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
export USE_OPENMP=y
export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export MPIEXEC=/usr/lib64/mpich/bin/mpiexec
export MPI_LIB=/usr/lib64/mpich/lib
export MPI_INCLUDE=/usr/include/mpich-x86_64
export LIBMPI="-lmpich"
export TCE_CUDA=Y
export CUDA="nvcc"
export CUDA_LIBS="-L/usr/local/cuda-10.1/lib64/ -L/usr/local/cuda-10.1/lib64/ -lcudart"
export CUDA_FLAGS="-arch sm_50 "
export CUDA_INCLUDE="-I. -I/usr/local/cuda-10.1/include/"

cd $NWCHEM_TOP/src

$MAKE nwchem_config NWCHEM_MODULES="all python" 2>&1 | tee ../make_nwchem_config_mpich.log
$MAKE 64_to_32 2>&1 | tee ../make_64_to_32_mpich.log
export MAKEOPTS="USE_64TO32=y"
$MAKE ${MAKEOPTS} 2>&1

