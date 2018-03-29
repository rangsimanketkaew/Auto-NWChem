#!/bin/bash

# Compilation of NWChem.
# ----------------------------------------------------------------------------------
# Required package
# MPI, Python 2.6.x or 2.7.x, GCC, GFortran compiler, BLAS & Lapack optimized math libraries
# yum install python-devel gcc-gfortran openblas-devel openblas-serial64 openmpi-devel scalapack-openmpi-devel blacs-openmpi-devel elpa-openmpi-devel tcsh --enablerepo=epel
# ----------------------------------------------------------------------------------
# Download NWChem to /usr/local/
# Extract tar file and rename the folder of NWChem source file to nwchem-6.6
# You should have /usr/local/nwchem-6.6 so far.
# ----------------------------------------------------------------------------------

# Define your home directory and your nwchem-6.x folder, says /home/rangsiman and /home/rangsiman/nwchem-6.8
MYHOME=/home/rangsiman
MYNWCHEM=/home/rangsiman/nwchem-6.8

# ----------- Press ... E n t e r ... and ... W a i t -----------

cd $MYNWCHEM/src
export NWCHEM_TOP=$MYNWCHEM
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

mkdir -p $MYHOME/NWChem/bin
mkdir -p $MYHOME/NWChem/data
cp $NWCHEM_TOP/bin/${NWCHEM_TARGET}/nwchem /usr/local/NWChem/bin
chmod 755 $MYHOME/NWChem/bin/nwchem
cp -r $NWCHEM_TOP/src/basis/libraries /usr/local/NWChem/data
cp -r $NWCHEM_TOP/src/data /usr/local/NWChem
cp -r $NWCHEM_TOP/src/nwpw/libraryps /usr/local/NWChem/data

echo "export MYHOME=/home/rangsiman"      >> $MYHOME/.bashrc
touch $MYHOME/NWChem/data/default.nwchemrc
echo "nwchem_basis_library /usr/local/NWChem/data/libraries/"    >> default.nwchemrc
echo "nwchem_nwpw_library /usr/local/NWChem/data/libraryps/"    >> default.nwchemrc
echo "ffield amber"    >> default.nwchemrc"
echo "amber_1 $MYHOME/NWChem/data/amber_s/"    >> default.nwchemrc
echo "amber_2 $MYHOME/NWChem/data/amber_q/"    >> default.nwchemrc
echo "amber_3 $MYHOME/NWChem/data/amber_x/"    >> default.nwchemrc
echo "amber_4 $MYHOME/NWChem/data/amber_u/"    >> default.nwchemrc
echo "spce $MYHOME/NWChem/data/solvents/spce.rst"    >> default.nwchemrc
echo "charmm_s $MYHOME/NWChem/data/charmm_s/"    >> default.nwchemrc
echo "charmm_x $MYHOME/NWChem/data/charmm_x/"    >> default.nwchemrc
cp $MYHOME/NWChem/data/default.nwchemrc ~/.nwchemrc
cp $MYHOME/NWChem/data/default.nwchemrc /etc/skel/.nwchemrc

echo "======================================== D O N E ========================================"
