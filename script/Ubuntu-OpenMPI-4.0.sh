#!/bin/bash

# Install NWChem 6.8.1 with MPI parallellism method on AWS EC2 Linux system.
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
## --------------------------------------------------------------------

make nwchem_config
make 64_to_32
make
