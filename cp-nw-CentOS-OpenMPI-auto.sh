#!/bin/bash
# Bash script for compiling of NWChem with OpenMPI on Centos and Ubuntu.
# Written by Rangsiman Ketkaew, MSc student in Chemistry, CCRU, Thammasat University, Thailand.

menu(){
	clear
	echo " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
	echo " << NWChem Auto Compilation Script >>"
	echo -e " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= \n" \
		"= [1] Check Libraries               = \n" \
		"= [2] Compile NWChem program        = \n" \
		"= [3] Set environment variable      = \n" \
		"= [4] Make resource file            = \n" \
		"= [5] Contact me                    = \n" \
		"= [6] Exit or ctrl + c              = \n" \
	        "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= \n"
	read -p "Enter: " inp1
}

menu

:<<'comment'
	 (1) Check Libraries
	 1.Check Math libraries: mpi90 show
	 2.Check OpenMPI version: mpirun --version
	 3.Check Python version: python --version
comment

if [ $inp1 == 1 ];then
	MPIF90_LIB=`mpif90 -show|grep -o -- '-lm[^ ]\+'|xargs`
	MPIRUN_VER=`mpirun --version|grep 'mpirun'`
	echo "<> You are using --> $MPIRUN_VER"
	echo "<> Suitable MPI libraries are --> $MPIF90_LIB"
	read -p "Enter to Menu"
	menu

:<<'comment'
	 (2) Configuration & Compile program using Make
	 export NWCHEM_TOP=/nwchem/install/folder/
	 I use an openmpi-1.6.5 as mpirun which is installed at $inp3/openmpi/
	 I use python version 2.7.x (checking by $ python --version)
	 Show a library for MPI using command $ mpif90 -show or Choose [1] from Menu
comment

elif [ $inp1 == 2 ];then

	read -p "Enter full path of nwchem program, e.g., /home/nutt/nwchem-6.8: " inp2

	if [ -e $inp2/src ];then

		export NWCHEM_TOP=$inp2
		cd $NWCHEM_TOP/src
# ----------------------------------MPI libraries box -----------------------------------
		export USE_MPI=y
		export USE_MPIF=y
		export USE_MPIF4=y
		export MPI_LOC=$inp3/openmpi
		export MPI_LIB=$MPI_LOC/lib
		export MPI_INCLUDE=$MPI_LOC/include
		export LIBMPI="-lmpi_f90 -lmpi_f77 -lmpi -ldl -Wl,--export-dynamic -lnsl -lutil"
# ---------------------------------------------------------------------------------------
		export NWCHEM_TARGET=LINUX64
		export USE_PYTHONCONFIG=y
		export PYTHONVERSION=2.7
		export PYTHONHOME=/usr
		export USE_64TO32=y
		export BLAS_SIZE=4
		export BLASOPT="-lopenblas -lpthread -lrt"
		export SCALAPACK_SIZE=4
		export SCALAPACK="-L$inp3/openmpi/lib -lscalapack -lmpiblacs"
		export ELPA="-I/usr/lib64/gfortran/modules/openmpi -L$inp3/openmpi/lib -lelpa"
		export LD_LIBRARY_PATH=$inp3/openmpi/lib/:$LD_LIBRARY_PATH
		export PATH=$inp3/openmpi/bin/:$PATH
		echo "Let's build NWCHEM" > $inp2/script-compile.log
		make nwchem_config NWCHEM_MODULES="all python"
		echo " Finished configuration setting up using python " >> script-compile.log
		make 64_to_32
		echo " Finished changing 64 to 32 " >> script-compile.log
		echo " Making install, please wait for a while ! " >> script-compile.log
		make >& script-compile-make.log
		echo " ------------------------ Make done --------------------------"

		if [ -e $NWCHEM_TOP/bin/LINUX64/nwchem ]; then
			echo " nwchem executable can be found now at $NWCHEM_TOP/bin/LINUX64/ "
			echo " Next step: set environment variable for nwchem "

		else
			echo " Program compile failed!   No nwchem excutable found"
			echo " Open script-compile-make.log to check the error"

		fi

	else
		echo "No program source code found in $inp2 directory"
		read -p "Enter to Menu"
		menu
	fi
		exit

:<<'comment'
	 (3) set environment variables for NWChem
	 ----------------------------- #
	 Determine the local storage path for the install files. (e.g., /usr/local/).
	 Make directories
comment

elif [ $inp1 == 3 ];then
	read -p "Enter directory for nwchem.exe and libraries: " inp3

	if [ -e $inp3 ]; then 
		export NWCHEM_TOP=$inp2
		export NWCHEM_TARGET=LINUX64
		export NWCHEM_EXE=$inp3
		mkdir $inp3/nwchem/
		mkdir $inp3/nwchem/bin
		mkdir $inp3/nwchem/data
	
		cp $NWCHEM_TOP/bin/${NWCHEM_TARGET}/nwchem $inp3/nwchem/bin
		cd $inp3/nwchem/bin
		chmod 755 nwchem
	
		cd $NWCHEM_TOP/src/basis
		cp -r libraries $inp3/nwchem/data
		cd $NWCHEM_TOP/src/
		cp -r data $inp3/nwchem
		cd $NWCHEM_TOP/src/nwpw
		cp -r libraryps $inp3/nwchem/data
	
		echo "# ------- Try to run NWChem program ------- #"  >> script-compile.log

	else
		echo "No $inp3 directory"
		read -p "enter to Menu"
		menu
	fi

:<<'comment'
	 (4) Creat a .nwchemrc file to point to these default data files.
comment

elif [ $inp1 == 4 ];then
	if [ -e $HOME/.nwchemrc ];then
		echo "You already have .nwchemrc file in your home directory"
		echo "Please check it!"
		read -p "Enter to Menu"
		menu
	else
		touch $HOME/.nwchemrc
		echo -e "nwchem_basis_library $inp3/nwchem/data/libraries/ \n" \
			"nwchem_nwpw_library $inp3/nwchem/data/libraryps/ \n" \
			"ffield amber \n" \
			"amber_1 $inp3/nwchem/data/amber_s/ \n" \
			"amber_2 $inp3/nwchem/data/amber_q/ \n" \
			"amber_3 $inp3/nwchem/data/amber_x/ \n" \
			"amber_4 $inp3/nwchem/data/amber_u/ \n" \
			"spce    $inp3/nwchem/data/solvents/spce.rst \n" \
			"charmm_s $inp3/nwchem/data/charmm_s/ \n" \
			"charmm_x $inp3/nwchem/data/charmm_x/" >> $HOME/.nwchemrc
	fi

elif [ $inp1 == 5 ];then
	echo -e " <> Rangsiman Ketkaew (MSc), Department of Chemsitry, Thammasat University, Thailand \n" \
		"<> rangsiman1993@gmail.com \n" \
		"<> https://github.com/rangsimanketkaew" 

elif [ $inp1 == 6 ];then
	echo "Bye bye .... :)"
	exit
else
	echo "You enter an incorrect choice"
	read -p "Enter to Menu"
	menu
fi
	exit
