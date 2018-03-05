
export LARGE_FILES=TRUE
export TCGRSH=/usr/bin/ssh
export NWCHEM_TOP=`pwd`
export NWCHEM_TARGET=LINUX64
export NWCHEM_MODULES="all python"
export PYTHONVERSION=2.7
export PYTHONHOME=/usr
export BLASOPT="-L/opt/openblas/lib -lopenblas"
export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export MPI_LOC=/usr/lib/openmpi/lib
export MPI_INCLUDE=/usr/lib/openmpi/include
export LIBRARY_PATH=$LIBRARY_PATH:/usr/lib/openmpi/lib:/opt/acml/acml5.2.0/gfortran64_int64/lib:/opt/openblas/lib
export LIBMPI="-lmpi -lopen-rte -lopen-pal -ldl -lmpi_f77 -lpthread"
export FC=gfortran

## Go to dirctory where you have modified the fortran code file.
##     Example, in src/ddscf, src/nwdft/scf_dft, and src/mcscf
## Then recompile the file.
cd $NWCHEM_TOP/src/ddscf
make
cd $NWCHEM_TOP/src/nwdft/scf_dft
make
cd $NWCHEM_TOP/src/mcscf
make

## Make link in the src directory
cd $NWCHEM_TOP/src
make link

## Optional: post-compilation
## cd $NWCHEM_TOP/contrib
## ./getmem.nwchem
