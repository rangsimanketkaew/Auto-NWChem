#!/bin/bash

# Install NWChem 6.8.1 with MPI parallellism method and GPU enabled on AWS EC2 Linux system.
# Compile with GNU compiler and OpenMPI v.4.0.

export NWCHEM_TOP=/home/ubuntu/nwchem-6.8.1

## *Note that if you are using OpenMPI 4.0 or higher you must change the MPI library, like this:*
sed -i "s/MPI_Errhandler_set/MPI_Comm_set_errhandler/g" $NWCHEM_TOP/src/tools/ga-5.6.5/tcgmsg/tcgmsg-mpi/misc.c
sed -i "s/MPI_Type_struct/MPI_Type_create_struct/g" $NWCHEM_TOP/src/tools/ga-5.6.5/comex/src-armci/message.c
## For more information please visit https://www-lb.open-mpi.org/faq/?category=mpi-removed.

##----------------------- NWChem configuration ------------------------
export NWCHEM_TARGET=LINUX64
export NWCHEM_MODULES="all python"
export MAKE=/usr/bin/make
export USE_NOFSCHECK=TRUE
export PYTHONHOME=/usr
export PYTHONVERSION=2.7
export USE_PYTHONCONFIG=y
export USE_PYTHON64=y
export HAS_BLAS=yes
export BLASOPT="-lopenblas -lpthread -lrt"
export BLAS_SIZE=4
export USE_64TO32=y
export MRCC_METHODS=TRUE
export CCSDTQ=y
export CCSDTLR=y
export IPCCSD=y
export EACCSD=y
## ---------------------- MPI Libraries box ---------------------------
export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export MPI_LOC=/usr/local/
export MPI_LIB=/usr/local/lib
export MPI_INCLUDE=/usr/local/include
export LIBMPI="-lmpi_usempi -lmpi_mpifh -lmpi"
export LIBMPI="-lmpi_usempif08 -lmpi_usempi_ignore_tkr -lmpi_mpifh -lmpi"
#--------------------------- GPU Enabled ------------------------------
export TCE_CUDA=Y
export CUDA="nvcc"
export CUDA_LIBS="-L/usr/local/cuda-10.1/lib64/ -L/usr/local/cuda-10.1/lib64/ -lcudart"
export CUDA_FLAGS="-arch sm_50 "
export CUDA_INCLUDE="-I. -I/usr/local/cuda-10.1/include/"
export FC="gfortran"
## --------------------------------------------------------------------

#Following three lines of command is for recompilation
#find ./ -name "dependencies" -exec rm {} \; -print
#make clean
#rm -f 64_to_32 32_to_64 tools/build tools/install

make nwchem_config
make 64_to_32
make
