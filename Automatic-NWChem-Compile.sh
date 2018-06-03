#!/bin/bash

:<<'comment'
##############################################################################################
#  Program for compiling NWChem with MPICH / Intel MPI+MKL / OpenMPI on Linux cluster.       #
#  Written by Rangsiman Ketkaew (MSc student in Chemistry), Thammasat University, Thailand.  #
##############################################################################################

version 1.0 First version: works with OpenMPI
version 1.1 Can make resource file
version 1.2 Can search MPI libraries automatically
version 1.3 Works with MPICH & Intel MPI+MKL and Bug fixed
comment

if [ "$1" == "-h" ] || [ "$1" == "-help" ] || [ "$1" == "--help" ]; then
cat << EOF

[x] NWChem Auto Compilation 1.3 

[x] Usage: ./compile-nwchem-auto.sh [-[-]h[elp]]

[x] Description of option

 1. Check MPI Architecture    :  Check vendor and version of MPI & Python & Math libraries.
 2. Compile NWChem            :  Make config & compile program using make at $NWCHEM_TOP.
 3. Create NWChem Data        :  Create NWChem data and libraries files.
 4. Create Resource file      :  Create resource file (.nwchemrc) at your home directory.
 5. Download NWChem 6.8       :  Download source code of NWChem 6.8 to your machine.
 6. Author Info               :  Author & contact
 7. Exit Program              :  Exit program. you can also type "ctrl + c".

[x] Prerequisites

 - CentOS version 6 or 7, or Ubuntu 16 or 17 (or other Linux distribution)
 - BLAS/OpenBLAS [ and Scalapack ]
 - Python version 1.x or 2.6 or 2.7
 - MPICH or Intel MPI+MKL or OpenMPI
 - Compiler: GNU, Intel, PGI, etc.

[x] Instruction of Program Installation

 1. Run Program "compile-nwchem-auto.sh"
 2. Enter option 1 to check the version and suitable libraries of MPI.
 3. Enter option 2 to compile program.
    wait until compilation completes (about 20-30 minutes).
 4. Enter option 3 to set environment variable of NWChem.
 5. Enter option 4 to create the resource file of '.nwchemrc'.

 - More detail: https://github.com/rangsimanketkaew/NWChem
 - Bugs report: rangsiman1993@gmail.com

EOF
	exit 0
fi

clear
echo "********** Automatic NWChem Compilation **********"
PS3="Enter Your Choice: "

OPT1="Check MPI Architecture"
OPT2="Compile NWChem"
OPT3="Create NWChem Data"
OPT4="Create Resource file"
OPT5="Download NWChem 6.8"
OPT6="Author & Contact"
OPT7="Exit Program"
OPTION=("$OPT1" "$OPT2" "$OPT3" "$OPT4" "$OPT5" "$OPT6" "$OPT7")
select choice in  "${OPTION[@]}"

do
	case $choice in
	$OPT1)

:<<'comment'
	 (1) Check MPI Architecture
	 1.Check Version of Linux Distro
	 2.Check OpenMPI version: mpirun --version
	 3.Check Math libraries: mpi90 show
comment

	MPIF90_LIB=`mpif90 -show|grep -o -- '-lm[^ ]\+'|xargs`
	CHECK_OPENMPI=`mpirun --version|grep 'mpirun'|wc -l`
	CHECK_MPICH=`mpirun --version|grep 'gfortran'|wc -l`
	CHECK_INTEL=`mpirun --version|grep 'ifort'|wc -l`

	if [ ! "$CHECK_OPENMPI" -eq "0" ];then
		MPIRUN_VER=`mpirun --version|grep 'mpirun'`

	elif [ ! "$CHECK_MPICH" -eq "0" ];then
		INTEL_VERSION=`mpirun --version|grep 'Version'|awk '{print $2}'`
		MPIRUN_VER="MPICH $INTEL_VERSION"

	elif [ ! "$CHECK_INTEL" -eq "0" ];then
		INTEL_VERSION=`mpirun --version|grep 'Version'|awk '{print $2}'`
		MPIRUN_VER="Intel MPI $INTEL_VERSION"

	else 
		MPIRUN_VER="Cannot detect version of MPI"

	fi

	echo "[] Linux version: $(cat /etc/*release | tail -1)"
	echo "[] MPI Architecture: $MPIRUN_VER"
	echo "[] Suitable MPI libraries: $MPIF90_LIB"

	;;
	$OPT2)

:<<'comment'
	 (2) Configuration & Compile program using Make
	 export NWCHEM_TOP=/nwchem/install/folder/
	 Show a library for MPI using command $ mpif90 -show or Choose [1] from Menu  
comment

	read -p "Enter full path of NWChem source code, e.g. /home/nutt/nwchem-6.8: " inp2
	read -p "Enter full path of MPI directory, e.g. /usr/local/openmpi: " MPI_LOCATION
	read -p "Enter version of Python you are using, e.g. 2.7: " PYTHON_VER
	read -p "Enter full path of Python directory, e.g. /usr: " PYTHON_HOME

	if [ -e $inp2/src ];then
	if [ -e $MPI_LOCATION ];then
	if [ -e $PYTHON_HOME ];then

# ------------------------- NWCHEM Location -------------------------
export NWCHEM_TOP=${inp2}
export NWCHEM_TARGET=LINUX64
# ------------------------- NWCHEM Functionality --------------------
export USE_NOFSCHECK=TRUE
export NWCHEM_FSCHECK=N
export LARGE_FILES=TRUE
export MRCC_THEORY=Y
export EACCSD=Y
export IPCCSD=Y
export CCSDTQ=Y
export CCSDTLR=Y
export NWCHEM_LONG_PATHS=Y
# ------------------------- MPI libraries ---------------------------
export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export MPI_LOC=${MPI_LOCATION}
export MPI_LIB=${MPI_LOC}/lib
export MPI_INCLUDE=${MPI_LOC}/include
export MPIEXEC=${MPI_LOC}/bin/mpiexec
export LIBMPI="${MPIF90_LIB}"
export PATH=${MPI_LOC}/bin/:$PATH
export LD_LIBRARY_PATH=${MPI_LOC}/lib/:$LD_LIBRARY_PATH
# ------------------------- Python Libraries ------------------------
export USE_PYTHONCONFIG=y
export PYTHONVERSION=${PYTHON_VER}
export PYTHONHOME=${PYTHON_HOME}
export USE_PYTHON64=y
export PYTHONLIBTYPE=so
# ------------------------- MATH libraries --------------------------
export USE_64TO32=y
export BLAS_SIZE=4
export BLASOPT="-lopenblas -lpthread -lrt"

		echo ""
		echo "====================================================================="
		echo "======== Environment Variable Setting for NWChem Compilation ========"
		echo "====================================================================="
		echo "Install NWChem version 6.8.1 with MPI"
		echo "Linux OS: $(cat /etc/*release|tail -1)"
		sed -n 124,157p ./compile-nwchem-auto.sh
		echo "====================================================================="
		echo ""

		read -p "Enter YES to start compiling: " COMPILE

		if [ $COMPILE == YES ] || [ $COMPILE == yes ]; then
			cd $NWCHEM_TOP/src
			echo ""
			echo " Start to compile NWChem 6.8 ..."
			echo ""
			echo " Building NWChem executable. Waiting for 20-30 Minutes ..."
			make nwchem_config NWCHEM_MODULES="all python" >& compile-config.log
			make 64_to_32 >& compile-64_to_32.log
			export MAKEOPTS="USE_64TO32=y"
			make ${MAKEOPTS} >& compile-make-nwchem.log
			cp compile-make-nwchem.log compile-make-nwchem.log.2
			echo ""
			echo " ------------------------ Compile done --------------------------"
			echo ""
		fi

	else
		echo "ERROR: No Python version $PYTHON_VER found in $PYTHON_HOME directory"
	fi

	else
		echo "ERROR: No MPI Libraries found in $MPI_LOCATION directory"
	fi

	else
		echo "ERROR: No program source code found in $inp2 directory"
	fi

	if [ -e $NWCHEM_TOP/bin/LINUX64/nwchem ]; then

		echo " Congratulations !  NWChem is compiled as executable successfully."
		echo ""
		echo " It can be found at $NWCHEM_TOP/bin/LINUX64/nwchem"
		echo " Log file is at $NWCHEM_TOP/src/compile*.log"
		echo ""

	else
		if [ -e $NWCHEM_TOP/src/compile-make-nwchem.log.2 ];then

			echo " ERROR: Program compile failed!  No nwchem excutable found"
			echo " Check following files to view Log."
			echo " $NWCHEM_TOP/src/compile-config.log"
			echo " $NWCHEM_TOP/src/compile-64_to_32.log"
			echo " $NWCHEM_TOP/src/compile-make-nwchem.log"
			echo ""

			rm $NWCHEM_TOP/src/compile-make-nwchem.log.2
		fi
	fi

	;;
	$OPT3)

:<<'comment'
	 (3) Create NWChem Data and Libraries
	 Determine the local storage path for the install files. (e.g. /usr/local/).
comment

	read -p "Enter full path of original NWChem directory, e.g. /home/nutt/nwchem-6.8: " inp2
	read -p "Enter full path of new NWChem data & libraries, e.g. /usr/local: " inp3

	if [ -e $inp2 ]; then

		if [ -e $inp3 ]; then

			export NWCHEM_TOP=$inp2
			export NWCHEM_TARGET=LINUX64
			export NWCHEM_EXE=$inp3
			mkdir $inp3/nwchem/
			mkdir $inp3/nwchem/bin
		
			cp $NWCHEM_TOP/bin/${NWCHEM_TARGET}/nwchem $inp3/nwchem/bin/
			chmod 755 $inp3/nwchem/bin/nwchem

			cp -r $NWCHEM_TOP/src/data $inp3/nwchem/
			cp -r $NWCHEM_TOP/src/basis/libraries $inp3/nwchem/
			cp -r $NWCHEM_TOP/src/nwpw/libraryps $inp3/nwchem/

		echo "Created NWChem data & libraries successfully."

		else
			echo "ERROR: $inp3 not found."
		fi

	else
		echo "ERROR: $inp2 not found."
	fi

	;;
	$OPT4)

:<<'comment'
	 (4) Creat Resource file 
	  Create ".nwchemrc" file that point to directory of NWChem data and libraries.
comment

	if [ ! -e $HOME/.nwchemrc ];then

		read -p "Enter full path of NWChem libraries directory, e.g. /usr/local/nwchem: " inp4

		if [ -e $inp4/bin/nwchem ]; then

			touch $HOME/.nwchemrc
			echo -e \
			"nwchem_basis_library $inp4/nwchem/libraries/ \n" \
			"nwchem_nwpw_library $inp4/nwchem/libraryps/ \n" \
			"ffield amber \n" \
			"amber_1 $inp4/data/amber_s/ \n" \
			"amber_2 $inp4/data/amber_q/ \n" \
			"amber_3 $inp4/data/amber_x/ \n" \
			"amber_4 $inp4/data/amber_u/ \n" \
			"spce    $inp4/data/solvents/spce.rst \n" \
			"charmm_s $inp4/data/charmm_s/ \n" \
			"charmm_x $inp4/data/charmm_x/" >> $HOME/.nwchemrc
			echo "NWChem resouce file is created at $HOME/.nwchemrc"

		else
			echo "ERROR: $inp4 not found"

		fi
	else
		echo "You already have NWChem resource file at $HOME/.nwchemrc"

	fi

	;;
	$OPT5)
	
:<<'comment'
	 (5) Download NWChem 6.8
	  Download nwchem-6.8-*.tar.bz2 to Linux machine.
comment

	echo "Download NWChem 6.8 source code to your Linux machine"
	read -p "Enter directory where you want to save NWChem 6.8, e.g. /home/nutt: " NWCHEM68_DIR

	if [ -e $NWCHEM68_DIR ];then

		NWCHEM68_SRC=nwchem-6.8-release.revision-v6.8-47-gdf6c956-src.2017-12-14.tar.bz2
		wget https://github.com/nwchemgit/nwchem/releases/download/v6.8-release/$NWCHEM68_SRC -P $NWCHEM68_DIR
		tar -xvjf $NWCHEM68_DIR/$NWCHEM68_SRC
		echo ""
		echo "Done ! NWChem source code is at $NWCHEM68_DIR/nwchem-6.8"

	else
		echo "ERROR: $NWCHEM68_DIR not found"
	fi

	;;
	$OPT6)

:<<'comment'
	 (6) Author and Contact
comment

	echo ""
	echo -e "  Rangsiman Ketkaew (MSc student)           E-Mail: rangsiman1993@gmail.com\n" \
		" Computational Chemistry Research Unit\n" \
		" C403, LC.5, Department of Chemistry       https://sites.google.com/site/rangsiman1993\n" \
		" Thammasat University, 12120 Thailand      https://github.com/rangsimanketkaew \n"

	;;
	$OPT7)
	
	break

	;;
	*)

	echo "ERROR: Invalid option"

	esac
done
