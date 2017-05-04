** The way to install NWChem program
** Proposed by Nutt

-- Setup and install th neccessary package --

$ su
enter passwd for root

$ yum install python-devel gcc-gfortran openblas-devel openblas-serial64 openmpi-devel scalapack-openmpi-devel blacs-openmpi-devel elpa-openmpi-devel tcsh --enablerepo=epel
$ python -V
The version of python have to be 2.7.x, if not, please have a look how to install python 2.7.13 at https://tecadmin.net/install-python-2-7-on-centos-rhel

$ vi /etc/bashrc
export PATH=/usr/lib64/openmpi/bin/:$PATH
export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib/:$LD_LIBRARY_PATH
$ source /etc/bashrc

-- Download nwchem from its website and extract file to /opt/ --

$ cd /opt/nwchem-6.6/src
$ vi nwchem_env.sh
export NWCHEM_TOP=/opt/nwchem-6.6
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

$ . nwchem_env.sh
$ make nwchem_config
$ make 64_to_32
$ make
If successfully finished, it should have nwchem executeable file at /opt/nwchem-6.6/bin/LINUX64/

-- path and environment setting --

$ sudo mkdir -p /usr/local/NWChem/bin
$ sudo mkdir -p /usr/local/NWChem/data

$ sudo cp $NWCHEM_TOP/bin/${NWCHEM_TARGET}/nwchem /usr/local/NWChem/bin
$ sudo chmod 755 /usr/local/NWChem/bin/nwchem
$ sudo cp -r $NWCHEM_TOP/src/basis/libraries /usr/local/NWChem/data
$ sudo cp -r $NWCHEM_TOP/src/data /usr/local/NWChem
$ sudo cp -r $NWCHEM_TOP/src/nwpw/libraryps /usr/local/NWChem/data
$ sudo vi /usr/local/NWChem/data/default.nwchemrc
nwchem_basis_library /usr/local/NWChem/data/libraries/
nwchem_nwpw_library /usr/local/NWChem/data/libraryps/
ffield amber
amber_1 /usr/local/NWChem/data/amber_s/
amber_2 /usr/local/NWChem/data/amber_q/
amber_3 /usr/local/NWChem/data/amber_x/
amber_4 /usr/local/NWChem/data/amber_u/
spce /usr/local/NWChem/data/solvents/spce.rst
charmm_s /usr/local/NWChem/data/charmm_s/
charmm_x /usr/local/NWChem/data/charmm_x/

$ cp /usr/local/NWChem/data/default.nwchemrc ~/.nwchemrc
$ sudo cp /usr/local/NWChem/data/default.nwchemrc /etc/skel/.nwchemrc

Add
export PATH=$PATH:/usr/local/NWChem/bin
to /etc/bashrc .

-- Try to run some tests file --
