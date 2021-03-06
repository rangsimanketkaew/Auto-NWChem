#!/bin/bash

# Compilation of NWChem.
# You must be root.
# ----------------------------------------------------------------------------------
# Required package
# MPI, Python 2.6.x or 2.7.x, GCC, GFortran compiler, BLAS & Lapack optimized math libraries
# yum install python-devel gcc-gfortran openblas-devel openblas-serial64 openmpi-devel scalapack-openmpi-devel blacs-openmpi-devel elpa-openmpi-devel tcsh --enablerepo=epel
# ----------------------------------------------------------------------------------
# Download NWChem to /usr/local/
# Extract tar file and rename the folder of NWChem source file to nwchem-6.6
# You should have /usr/local/nwchem-6.6 so far.
# ----------------------------------------------------------------------------------

cd /usr/local/nwchem-6.6/src/

export NWCHEM_TOP=/usr/local/nwchem-6.6
export NWCHEM_TARGET=LINUX64
export NWCHEM_MODULES=all
export USE_MPI=y
export USE_PYTHONCONFIG=y
export PYTHONVERSION=2.7
export PYTHONHOME=/usr
export USE_64TO32=y
export BLAS_SIZE=4
export BLASOPT="-lopenblas -lpthread -lrt"
export SCALAPACK_SIZE=4
export SCALAPACK="-L/usr/lib64/openmpi/lib -lscalapack -lmpiblacs"
export ELPA="-I/usr/lib64/gfortran/modules/openmpi -L/usr/lib64/openmpi/lib -lelpa"

make nwchem_config
make 64_to_32
make
# ----------------------------------------------------------------------------------
# So far it should have nwchem executable file at /usr/local/nwchem-6.6/bin/LINUX64/

mkdir -p /usr/local/NWChem/bin
mkdir -p /usr/local/NWChem/data
cp $NWCHEM_TOP/bin/${NWCHEM_TARGET}/nwchem /usr/local/NWChem/bin
chmod 755 /usr/local/NWChem/bin/nwchem
cp -r $NWCHEM_TOP/src/basis/libraries /usr/local/NWChem/data
cp -r $NWCHEM_TOP/src/data /usr/local/NWChem
cp -r $NWCHEM_TOP/src/nwpw/libraryps /usr/local/NWChem/data

touch /usr/local/NWChem/data/default.nwchemrc
echo "nwchem_basis_library /usr/local/NWChem/data/libraries/"    >> default.nwchemrc
echo "nwchem_nwpw_library /usr/local/NWChem/data/libraryps/"    >> default.nwchemrc
echo "ffield amber"    >> default.nwchemrc"
echo "amber_1 /usr/local/NWChem/data/amber_s/"    >> default.nwchemrc
echo "amber_2 /usr/local/NWChem/data/amber_q/"    >> default.nwchemrc
echo "amber_3 /usr/local/NWChem/data/amber_x/"    >> default.nwchemrc
echo "amber_4 /usr/local/NWChem/data/amber_u/"    >> default.nwchemrc
echo "spce /usr/local/NWChem/data/solvents/spce.rst"    >> default.nwchemrc
echo "charmm_s /usr/local/NWChem/data/charmm_s/"    >> default.nwchemrc
echo "charmm_x /usr/local/NWChem/data/charmm_x/"    >> default.nwchemrc

cp /usr/local/NWChem/data/default.nwchemrc ~/.nwchemrc
cp /usr/local/NWChem/data/default.nwchemrc /etc/skel/.nwchemrc

echo "======================================== D O N E ========================================"
