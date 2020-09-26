!/bin/bash
##################################################################################
# Compile NWChem 7.0.0 with GPU support and MPI-PR on Piz Daint
# Cray compiler and Intel MKL
# Rangsiman Ketkaew - August 2020
##################################################################################

module swap PrgEnv-cray PrgEnv-intel
module load daint-gpu
module load cudatoolkit/10.1.105_3.27-7.0.1.1_4.1__ga311ce7

# NWChem stuff
export NWCHEM_TOP=/project/s1001/nwchem-7.0.0/nwchem-7.0.0-gpu-MPI-PR
export NWCHEM_TARGET=LINUX64
export NWCHEM_MODULES=all
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
export ARMCI_NETWORK=MPI-PR
#export EXTERNAL_ARMCI_PATH=/home/rangsiman/nwchem-7.0.0-cuda/external-armci
### Enable OpenMP support
export USE_OPENMP=T

### CRAY
export CRAYPE_LINK_TYPE=dynamic

### Math and MPI
export BLAS_SIZE=8
export LAPACK_SIZE=8
export SCALAPACK_SIZE=8
export SCALAPACK="-L$MKLROOT/lib/intel64 -lmkl_scalapack_ilp64 -lmkl_intel_ilp64 -lmkl_core -lmkl_sequential -lmkl_blacs_intelmpi_ilp64 -lpthread -lm"
export BLASOPT="-L$MKLROOT/lib/intel64  -lmkl_intel_ilp64 -lmkl_core -lmkl_sequential -lmkl_core -lmkl_sequential -lpthread -lm"
export BLAS_LIB=$BLASOPT
export LAPACK_LIB=$BLASOPT

export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export USE_64TO32=y
export LIBMPI=" "
export HAS_BLAS=yes
export USE_SCALAPACK=y
export LARGE_FILES=y

# CUDA support
export TCE_CUDA=Y
export CUDA_LIBS="-L/opt/nvidia/cudatoolkit10/10.1.105_3.27-7.0.1.1_4.1__ga311ce7/lib64 -L/opt/nvidia/cudatoolkit10/10.1.105_3.27-7.0.1.1_4.1__ga311ce7/lib -lcudart"
export CUDA_FLAGS="-arch sm_60"
export CUDA_INCLUDE="-I. -I/opt/nvidia/cudatoolkit10/10.1.105_3.27-7.0.1.1_4.1__ga311ce7/include"

# Compilers
export FC=ftn
export _FC=ifort
export CC=cc
export COPTS="-O0 -g"

cd $NWCHEM_TOP/src

make nwchem_config 2>&1 | tee nwchem_config.log
make -j16 64_to_32 2>&1 | tee nwchem_64to32.log
make -j16 2>&1 | tee nwchem_build.log
