#!/bin/bash
:<<'comment'

Bash script for compiling NWChem program with OpenMPI on Centos and Ubuntu.
Written by Rangsiman Ketkaew, MSc student in Chemistry, CCRU, Thammasat University, Thailand.
version 1.1 Create script
version 1.2 Make option using CASE

comment

if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ "$1" == "-help" ]; then
echo -e "
################################## NWCHEM Auto Compilation #######################################

[] Description of each option.

1 = Check MPI Libraries
    Check provider and version of 'mpiexec' & math libraries & Python version that you are using

2 = Compile NWChem program
    Config & compile program using make at $NWCHEM_TOP.
    Caveat: I use an openmpi-1.6.5 ($ mpirun --version.
            I use python version 2.7 ($ python --version).

3 = Set environment variable
    Determine the local storage path for the install files. (e.g., /usr/local/).

4 = Make resource file
    Create resource file (.nwchemrc) at your home directory.

5 = Download NWChem 6.8
    Download source code of NWChem 6.8 to your machine

6 = Author & Contact

7 = Exit or ctrl + c
    Exit script

##################################################################################################

[] Prerequisites

  - CentOS version 6.x / 7.x or Ubuntu 16.x / 17.x (or other Linux distro)
  - Bash shell
  - Python version 2.6 / 2.7
  - OpenMPI and suitable libraries
  - Compiler: Intel, GNU, PGI, etc. More details please consult NWChem manual.

##################################################################################################

[] Installation of NWChem

  1. run this script
  2. Enter option 1 to check the version and suitable libraries of openmpi.
  3. Enter option 2 to compile program.
  4. Wait ... for 30 min ... until compilation completes.
  5. Enter option 3 to set the env variable of nwchem.
  6. Enter option 4 to create the resource file of program.
  7. Run test calculation & Enjoy NWChem.

  - More details: https://github.com/rangsimanketkaew/NWChem

##################################################################################################

"|less
	exit 0
fi

clear
echo "************* NWChem Auto Compilation *************"
PS3="Enter Your Choice: "

OPT1="Check Libraries"
OPT2="Compile NWChem program"
OPT3="Set environment variable"
OPT4="Make resource file"
OPT5="Download NWChem 6.8"
OPT6="Author & Contact"
OPT7="Exit or ctrl + c"
OPTION=("$OPT1" "$OPT2" "$OPT3" "$OPT4" "$OPT5" "$OPT6" "$OPT7")
select choice in  "${OPTION[@]}"

do
	case $choice in
	$OPT1)

:<<'comment'
	 (1) Check Libraries
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

	read -p "Enter full path of NWChem source code, e.g., /home/nutt/nwchem-6.8: " inp2
	read -p "Enter full path of MPI directory, e.g., /usr/local/openmpi-2.0.2: " MPI_LOCATION
	read -p "Enter version of Python you are using, e.g., 2.7: " PYTHON_VER
	read -p "Enter full path of Python directory, e.g., /usr/lib64/python2.7: " PYTHON_HOME

	if [ -e $inp2/src ];then
	if [ -e $MPI_LOCATION ];then
	if [ -e $PYTHON_HOME ];then
echo "Install NWChem 6.8 with MPI/OpenMPI"
echo "Linux OS is: $(cat /etc/*release|tail -1)"
# ---------------------------------- NWCHEM_TOP ------------------------------------------
export NWCHEM_TOP=$inp2
export MPI_LOC=$MPI_LOCATION
# ---------------------------------- MPI libraries ---------------------------------------
export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export MPI_LOC=$MPI_LOCATION
export MPI_LIB=$MPI_LOC/lib
export MPI_INCLUDE=$MPI_LOC/include
export LIBMPI="$MPIF90_LIB"
# ----------------------------------- MATH libraries -------------------------------------
export NWCHEM_TARGET=LINUX64
export USE_PYTHONCONFIG=y
export PYTHONVERSION=$PYTHON_VER
export PYTHONHOME=$PYTHON_HOME
export USE_64TO32=y
export BLAS_SIZE=4
export BLASOPT="-lopenblas -lpthread -lrt"
export SCALAPACK_SIZE=4
export SCALAPACK="-L/ucr/local/openmpi/lib -lscalapack -lmpiblacs"
export ELPA="-I/usr/lib64/gfortran/modules/openmpi -L$inp3/openmpi/lib -lelpa"
export LD_LIBRARY_PATH=/usr/local/openmpi/lib/:$LD_LIBRARY_PATH
export PATH=/usr/local/openmpi/bin/:$PATH
# ---------------------------------------------------------------------------------------
		echo ""
		echo "Environment variable setting for NWChem program is shown as following"
		echo "====================================================================="
		echo ""
		sed -n 136,162p ./compile-nwchem-auto.sh
		echo ""

		read -p "Enter YES to start compiling: " COMPILE

		if [ $COMPILE == YES ] || [ $COMPILE == yes ]; then
			cd $NWCHEM_TOP/src
			echo ""
			echo "Start to compile NWChem 6.8 ..."
			echo ""
			echo "Let's build NWCHEM"
			make nwchem_config NWCHEM_MODULES="all python" >& compile-config.log
			echo "Finished configuration setting up using python "
			make 64_to_32 >& compile-64_to_32.log
			echo "Finished changing 64 to 32 "
			echo "Making install, please wait for a while ! "
			make >& compile-make-nwchem.log
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
		echo ""
		echo " You already installed NWChem."
		echo " Now NWChem executable can be found at $NWCHEM_TOP/bin/LINUX64/"
		echo " You may want to set environment variable for NWChem."

	else
		if [ -e $NWCHEM_TOP/src/compile-make-nwchem.log.2 ];then

			echo ""
			echo " ERROR: Program compile failed!  No nwchem excutable found"
			echo " Check following files to view Log."
			echo " $NWCHEM_TOP/src/compile-config.log"
			echo " $NWCHEM_TOP/src/compile-64_to_32.log"
			echo " $NWCHEM_TOP/src/compile-make-nwchem.log"

			rm $NWCHEM_TOP/src/compile-make-nwchem.log.2
		fi
	fi

	;;
	$OPT3)

:<<'comment'
	 (3) set environment variables for NWChem
	 ----------------------------- #
	 Determine the local storage path for the install files. (e.g., /usr/local/).
	 Make directories
comment

	read -p "Enter full path of original NWChem directory, e.g., /home/nutt/nwchem-6.8: " inp2
	read -p "Enter full path of directory where you want to create NWChem libraries: " inp3

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

		echo "Creat NWChem data & libraries successfully."

		else
			echo "ERROR: $inp3 not found."
		fi

	else
		echo "ERROR: $inp2 not found."
	fi

	;;
	$OPT4)

:<<'comment'
	 (4) Creat a .nwchemrc file to point to these default data files.
comment

	read -p "Enter full path of NWChem libraries directory, e.g, /usr/local/nwchem/: " inp4

	if [ -e $inp4/bin/nwchem ]; then

		if [ ! -e $HOME/.nwchemrc ];then

			echo "You already have NWChen resource file '.nwchemrc' file in your home directory."
			read -p "You want to continue ? (yes/no): " $inp5

			if [ "$inp5" = "yes" ]; then

				rm $HOME/.nwchemrc
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

			fi
		fi
	
	else
		echo "ERROR: $inp4 not found"

	fi

	;;
	$OPT5)
	
	echo "Download NWChem 6.8 source code to your Linux machine"
	read -p "Enter directory where you want to save NWChem 6.8, e.g., /home/nutt/: " NWCHEM68_DIR

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

	echo -e " <> Rangsiman Ketkaew \n" \
		"   MSc student \n" \
		"   Computational Chemistry Research Unit \n" \
		"   C403, LC.5, Department of Chemistry \n" \
		"   Thammasat University, 12120 Thailand \n" \
		"<> E-Mail: rangsiman1993@gmail.com \n" \
		"<> https://github.com/rangsimanketkaew"

	;;
	$OPT7)
	
	echo " <<< ===== BYE ===== >>>"
	break

	;;
	*)

	echo "ERROR: Invalid option"

	esac
done
