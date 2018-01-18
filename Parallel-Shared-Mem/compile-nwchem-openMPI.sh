#!/bin/bash

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
export BLASOPT='-L/usr/lib64 -lopenblas'
export BLAS_SIZE='4'
export MAKE=/usr/bin/make
export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib
export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export MPIEXEC=/usr/lib64/openmpi/bin/mpiexec
export MPI_LIB=/usr/lib64/openmpi/lib
export MPI_INCLUDE=/usr/include/openmpi-x86_64
export LIBMPI='-lmpi -lmpi_f90 -lmpi_f77'
$MAKE nwchem_config NWCHEM_MODULES="all python" 2>&1 | tee ../make_nwchem_config_openmpi.log
$MAKE 64_to_32 2>&1 | tee ../make_64_to_32_openmpi.log
export MAKEOPTS="USE_64TO32=y"
$MAKE ${MAKEOPTS} 2>&1
