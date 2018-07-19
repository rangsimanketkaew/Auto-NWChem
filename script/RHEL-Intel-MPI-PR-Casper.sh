#!/bin/bash
##################################################################################
# Compile NWChem 6.8.1 with ARMCI MPI-PR and Casper on RHEL distribution 64 bit
# build program by Intel Compiler, Intel Parallel Studio XE Cluster Edition
# Rangsiman Ketkaew, Thammasat University, Thailand
##################################################################################

#module purge
module python2.7

export NWCHEM_TOP="$HOME/nwchem-6.8.1"
cd $NWCHEM_TOP/src

### NWChem module request
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
export PYTHONHOME=/usr
export PYTHONVERSION=2.6
export USE_PYTHONCONFIG=y
export USE_PYTHON64=y
### ARMCI method
export ARMCI_NETWORK=MPI-PR
export LD_PRELOAD="/share/apps/nwchem-6.8/Math-RK/casper-1.0b2-RK/lib/libcasper.so"
### Enable OpenMP support
export USE_OPENMP=T
### MPI
export I_MPI_ROOT="$HOME/intel/parallel_studio_xe_2018/compilers_and_libraries_2018/linux/mpi"
export MPI_ROOT="$I_MPI_ROOT/intel64"
export MPICC="$MPI_ROOT/bin/mpiicc"
export MPICXX="$MPI_ROOT/bin/mpiicpc"
export MPIFC="$MPI_ROOT/bin/mpiifort"
export MKLROOT="$HOME/intel/parallel_studio_xe_2018/compilers_and_libraries_2018/linux/mkl"
###Math Library, and Compiler
export CC=icc
export FC=ifort link
export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export MPI_DIR="${MPI_ROOT}"
export MPIEXEC="${MPI_DIR}/bin/mpirun"
export MPI_LIB="${MPI_DIR}/lib"
export MPI_INCLUDE="${MPI_DIR}/include"
export LIBMPI="-lmpifort -lmpi -lmpigi -ldl -lrt -lpthread"
export BLAS_SIZE=8
export BLASOPT="-mkl=parallel -qopenmp"
export LAPACK_SIZE=8
export LAPACK_LIB="$BLASOPT"
export LAPACK_LIBS="$BLASOPT"
export USE_SCALAPACK=y
export SCALAPACK_SIZE=8
export SCALAPACK="-L${MKLROOT}/lib/intel64 -lmkl_scalapack_ilp64 -lmkl_intel_ilp64 -lmkl_intel_thread \
 -lmkl_core -lmkl_blacs_intelmpi_ilp64 -liomp5 -lpthread -lm -ldl"

make -j12 nwchem_config NWCHEM_MODULES="all python" 2>&1 | tee ../make_nwchem_config_mpich.log
make -j12 FC=ifort CC=icc 2>&1 | tee ../makefile.log
