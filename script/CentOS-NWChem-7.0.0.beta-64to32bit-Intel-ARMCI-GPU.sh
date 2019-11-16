#!/bin/bash
##################################################################################
# Compile NWChem 7.0.0 beta with ARMCI & GPU enabled
# CentOS 7 64-bit system
# Intel(R) Xeon(R) Gold 6132 CPU @ 2.60GHz
# Memory DDR4-2666 MHz
# DELL Infiniband SX6012 interconnect
# GPU	4x Tesla V100-SXM2-32GB
# Intel Compiler and Intel Parallel Studio XE Cluster Edition
##################################################################################

module purge
module load intel/19.0.1.144
module load impi/2019.1.144
module load mkl/2019.3
module load python/2.7
module load cuda/10.1

##----------------------- NWChem configuration ------------------------
export NWCHEM_TOP=/home/rangsiman/nwchem-7.0.0-cuda
export NWCHEM_TARGET=LINUX64
export USE_NOFSCHECK=TRUE
export NWCHEM_FSCHECK=N
export LARGE_FILES=TRUE
export MRCC_THEORY=Y
export EACCSD=Y
export IPCCSD=Y
export CCSDTQ=Y
export CCSDTLR=Y
export NWCHEM_LONG_PATHS=Y
### Python
# dynamics python library should be at ls /usr/lib*/python*/config*/libpython*.*
export PYTHONHOME=/usr
export PYTHONVERSION=2.7
export USE_PYTHONCONFIG=y
export USE_PYTHON64=y
### ARMCI method
export ARMCI_NETWORK=ARMCI
export EXTERNAL_ARMCI_PATH=/home/rangsiman/nwchem-7.0.0-cuda/src/tools/../..//external-armci
### Enable OpenMP support
export USE_OPENMP=T
## ---------------------- MPI Libraries box ---------------------------
export I_MPI_ROOT="/opt/ohpc/pub/apps/intel/compilers_and_libraries_2019.1.144/linux/mpi"
export MPI_ROOT="$I_MPI_ROOT/intel64"
export MPICC="$MPI_ROOT/bin/mpiicc"
export MPICXX="$MPI_ROOT/bin/mpiicpc"
export MPIFC="$MPI_ROOT/bin/mpiifort"
export MKLROOT="/opt/ohpc/pub/apps/intel/compilers_and_libraries_2019.1.144/linux/mkl"
## ---------------------- Math support --------------------------------
export CC=icc
export FC=ifort
export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export MPI_INCLUDE="/opt/ohpc/pub/apps/intel/compilers_and_libraries_2019.1.144/linux/mpi/intel64/include -I/opt/ohpc/pub/apps/intel/compilers_and_libraries_2019.1.144/linux/mpi/intel64/include"
export MPI_LIB="/opt/ohpc/pub/apps/intel/compilers_and_libraries_2019.1.144/linux/mpi/intel64/lib/release -L/opt/ohpc/pub/apps/intel/compilers_and_libraries_2019.1.144/linux/mpi/intel64/lib"
export LIBMPI="-lmpifort -lmpi -ldl -lrt -lpthread"
export BLAS_SIZE=8
export BLASOPT="-L${MKLROOT}/lib/intel64 -lmkl_intel_ilp64 -lmkl_intel_thread -lmkl_core -liomp5 -lpthread -lm -ldl"
export LAPACK_SIZE=8
export LAPACK_LIB="$BLASOPT"
export LAPACK_LIBS="$BLASOPT"
export USE_SCALAPACK=y
export SCALAPACK_SIZE=8
export SCALAPACK="-L${MKLROOT}/lib/intel64 -lmkl_scalapack_ilp64 -lmkl_intel_ilp64 -lmkl_intel_thread \
 -lmkl_core -lmkl_blacs_intelmpi_ilp64 -liomp5 -lpthread -lm -ldl"
## ----------------------- GPU CUDA enabled ----------------------------
export CUDA="nvcc --compiler-bindir=/usr/bin/"
export TCE_CUDA=Y
export CUDA_LIBS="-L/opt/ohpc/pub/libs/cuda-10.1/lib64/ -lcudart"
export CUDA_FLAGS="-arch sm_60 "
export CUDA_ARCH="-arch sm60"
export CUDA_INCLUDE="-I. -I/opt/ohpc/pub/libs/cuda-10.1/include"

export USE_64TO32=y

cd $NWCHEM_TOP/src

#find ./ -name "dependencies" -exec rm {} \; -print
#make clean
#rm -f 64_to_32 32_to_64 tools/build tools/install

#cd ./tce
#make clean

make nwchem_config NWCHEM_MODULES="all" 2>&1 | tee ../make_nwchem_config_mpich.log
make FC=ifort USE_64TO32=y 2>&1 | tee ../makefile.log

#make FC=ifort link 2>&1 | tee ../makefile.log

#make FC=ifort 2>&1 | tee ../makefile.log
