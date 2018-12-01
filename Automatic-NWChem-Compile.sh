#!/bin/bash

:<<'comment'
#############################################################
#  Automatic NWChem Compilaton Program                      #
#                                                           #
#  Written by Rangsiman Ketkaew, MSc student in Chemistry   #
#  Computational Chemistry Research Unit                    #
#  Department of Chemistry                                  #
#  Faculty of Science and Technology                        #
#  Thammasat University, Thailand.                          #
#############################################################

## History
version 1.0 Automatic NWChem Compilation
version 1.1 Create NWChem resource file
version 1.2 Automatically search Fortran and MPI libraries
version 1.3 Support MPICH, MVAPICH2, MVAPICH23, Intel MPI, and OpenMPI
version 2.0 MPI detection bug fixed

comment

######################################################
VERSION="6.8.1"
NWCHEM_GIT="https://github.com/nwchemgit/nwchem/releases/download/6.8.1-release"
NWCHEM_SRC="nwchem-6.8.1-release.revision-v6.8-133-ge032219-src.2018-06-14.tar.bz2"
NWCHEM_GIT_SRC="$NWCHEM_GIT/$NWCHEM_SRC"
######################################################

if [ "$1" == "-h" ] || [ "$1" == "-help" ] || [ "$1" == "--help" ]; then

cat << EOF

                     Automatic NWChem Compilation 2.0 (2017-2018)
                     --------------------------------------------

[x] Usage: ./Automatic-NWChem-Compile.sh

[x] Description of option

 1. Check MPI Architecture       Check vendor and version of MPI & Python & Math libraries.
 2. Compile NWChem               Compile program in \$NWCHEM_TOP using parallel Fortran.
 3. Create Resource file         Create resource file (.nwchemrc) at your home directory.
 4. Download NWChem              Download source code of NWChem $VERSION to your machine.
 5. Author Info                  Author and contact address.
 6. Exit Program                 Exit program. This is as if you use "Ctrl + C".

[x] Prerequisites

 - RHEL, CentOS, and Ubuntu
 - BLAS/OpenBLAS
 - Python 2.x
 - MPICH, MVAPICH, Intel MPI, and OpenMPI
 - Fortran compiler: GNU, Intel, PGI, etc.

[x] Installation Instruction

 1. Execute program "./Automatic-NWChem-Compile.sh"
 2. Select 1 to check the version and libraries of Fortran and MPI.
 3. Select 2 to compile NWChem. This can take about 20-30 minutes.
 5. Select 3 to create the resource file of NWChem.

 - Bugs report: https://github.com/rangsimanketkaew/NWChem
 - Suggestions: rangsiman1993@gmail.com

EOF
	exit 0
fi

clear

echo "*********** Automatic NWChem Compilation ***********"

PS3="Enter Your Choice: "

OPT1="Check MPI Architecture"
OPT2="Compile NWChem"
OPT3="Create Resource file"
OPT4="Download NWChem $VERSION"
OPT5="Author & Contact"
OPT6="Exit Program"
OPTION=("$OPT1" "$OPT2" "$OPT3" "$OPT4" "$OPT5" "$OPT6")

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

	MPIF90=`command -v mpif90`
	MPIRUN=`command -v mpirun`

	if [ -z "$MPIF90" ];then
		echo "ERROR: \"mpif90\" command not found. Please check if Fortran compiler is currently available on your Linux."
		exit 1

	elif [ -z "$MPIRUN" ];then
      	        echo "ERROR: \"mpirun\" command not found. Please check if MPI library is currently available on your Linux."
	        exit 1

	else

	MPIF90_LIB=`mpif90 -show|grep -o -- '-lm[^ ]\+'|xargs`
	CHECK_OPENMPI=`mpirun --version|grep -c 'mpirun'`
	CHECK_MPICH_GNU=`mpirun --version|grep -cE 'HYDRA|gfortran'`
	CHECK_MPICH_INT=`mpirun --version|grep -cE 'HYDRA|ifort'`
	CHECK_INTEL_MPI=`mpirun --version|grep -c 'Intel'`

	if [ ! "$CHECK_OPENMPI" -eq "0" ];then
		MPIRUN_VER=`mpirun --version|grep 'mpirun'`

	elif [ ! "$CHECK_MPICH_GNU" -eq "1" ];then
		INTEL_VERSION=`mpirun --version|grep 'Version'|awk '{print $2}'`
		MPIRUN_VER="MPICH GNU $INTEL_VERSION"

	elif [ ! "$CHECK_MPICH_INT" -eq "1" ];then
		INTEL_VERSION=`mpirun --version|grep 'Version'|awk '{print $2}'`
		MPIRUN_VER="MPICH Intel $INTEL_VERSION"

	elif [ ! "$CHECK_INTEL_MPI" -eq "0" ];then
		INTEL_VERSION=`mpirun --version|grep 'Version'|awk '{print $2}'`
		MPIRUN_VER="Intel MPI $INTEL_VERSION"

	else
		echo "ERROR: Cannot detect MPI program. This program supports only OpenMPI, MPICH, MVAPICH, and Intel MPI."
		exit 1

	fi

	echo "- Linux distribution version   : $(cat /etc/*release | tail -1)"
	echo "- MPI architecture and version : $MPIRUN_VER"
	echo "- Fortran Compiler libraries   : $MPIF90_LIB"

	fi

	;;
	$OPT2)

:<<'comment'
	 (2) Setting up configuration compilation using paralell making
	 export NWCHEM_TOP="/directory/of/nwchem/"
comment

	MPIRUN_SEARCH=`which mpirun`
	MPI_LOCATION=`echo $MPIRUN_SEARCH | sed -e 's/\/bin\/mpirun//'`

	read -p "Enter absolute path of NWChem source code, e.g. /home/$USER/nwchem-${VERSION}/: " inp1
	if [ -z $inp1 ];then
		echo "ERROR: Please enter absolute path of NWChem source code."
		exit 1
	fi

	read -p "Enter version of Python you are using, e.g. 2.6: " PYTHON_VER
	if [ -z $PYTHON_VER ];then
		echo "ERROR: Please enter version of Python."
		exit 1	
	fi

	read -p "Enter absolute path of Python directory, e.g. /usr/: " PYTHON_HOME
	if [ -z $PYTHON_HOME ];then
		echo "ERROR: Please enter absolute path of Python directory."
		exit 1	
	fi

	export NWCHEM_TOP=$inp1

	if [ -e $NWCHEM_TOP/src ];then
		if [ -e $MPI_LOCATION ];then
			if [ -e $PYTHON_HOME ];then

cat << EOF > $PWD/configure_nwchem_compile.sh
#!/bin/bash

#######################################################################
## This script was generated by Automatic NWChem Compilation program ##
##            https://github.com/rangsimanketkaew/NWChem             ##
#######################################################################

# ------------------------- NWCHEM Location -------------------------
export NWCHEM_TOP=${NWCHEM_TOP}
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
export PATH=${MPI_LOC}/bin/:\$PATH
export LD_LIBRARY_PATH=${MPI_LOC}/lib/:\$LD_LIBRARY_PATH
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
# ------------------------- Compile ---------------------------------
make nwchem_config NWCHEM_MODULES="all python" >& compile-config.log
make -j4 64_to_32 >& compile-64_to_32.log
export MAKEOPTS="USE_64TO32=y"
make -j4 ${MAKEOPTS} >& compile-make-nwchem.log

EOF

			echo ""
			echo "====================================================================="
			echo "Install NWChem version $VERSION with Message Passing Interface (MPI)"
			echo ""
			echo "Configuration compilation has been saved."
			echo "Please check $PWD/configure_nwchem_compile.sh"
			echo "====================================================================="
			echo ""
	
			read -p "Enter YES to start compiling: " COMPILE
	
			if [ $COMPILE == YES ] || [ $COMPILE == yes ] || [ $COMPILE == y ]; then
				echo ""
				echo " Start to compile NWChem ..."
				echo ""
				echo " Building NWChem executable ... This will take 20-30 minutes."
				echo " Please do not close this terminal."
				cp $PWD/configure_nwchem_compile.sh $NWCHEM_TOP/src
				cd $NWCHEM_TOP/src
				chmod +x configure_nwchem_compile.sh
				# Compile
				./configure_nwchem_compile.sh
				#
				wait
				cp compile-make-nwchem.log compile-make-nwchem.log.2
				echo ""
				echo " -------------------------------------------------------------"
				echo ""
			fi

			else
				echo "ERROR: Python version $PYTHON_VER not found in $PYTHON_HOME directory."
			fi

		else
			echo "ERROR: MPI Libraries not found in $MPI_LOCATION directory."
		fi

	else
		echo "ERROR: Program source code not found in $NWCHEM_TOP directory."
	fi

	if [ -e $NWCHEM_TOP/bin/LINUX64/nwchem ]; then

		echo " Congratulations! NWChem has been compiled successfully."
		echo ""
		echo " It can be found at $NWCHEM_TOP/bin/LINUX64/nwchem"
		echo " Log file is at $NWCHEM_TOP/src/compile*.log"
		echo ""

	else
		if [ -e $NWCHEM_TOP/src/compile-make-nwchem.log.2 ];then

			echo " ERROR: Program compile failed! nwchem excutable not found."
			echo " Check following files to view Log."
			echo " $NWCHEM_TOP/src/compile-config.log"
			echo " $NWCHEM_TOP/src/compile-64_to_32.log"
			echo " $NWCHEM_TOP/src/compile-make-nwchem.log"
			echo ""
			echo " Please look at the end of LOG file to see error message."
			echo " You can consult NWChem developer at http://www.nwchem-sw.org/index.php/Special:AWCforum"
			echo ""

			rm $NWCHEM_TOP/src/compile-make-nwchem.log.2
		fi
	fi

	;;
	$OPT3)

:<<'comment'
	 (3) Creat Resource file 
	  Create .nwchemrc file that point to directory of NWChem data and libraries.
comment

	if [ ! -e $HOME/.nwchemrc ];then

		read -p "Enter absolute path of NWChem top directory, e.g. /home/$USER/nwchem-${VERSION}: " inp2

		if [ -e $inp2/src/basis ]; then

			touch $HOME/.nwchemrc
			echo -e \
			"nwchem_basis_library $inp2/src/basis/libraries/ \n" \
			"nwchem_nwpw_library $inp2/src/nwpw/libraryps/ \n" \
			"ffield amber \n" \
			"amber_1 $inp2/src/data/amber_s/ \n" \
			"amber_2 $inp2/src/data/amber_q/ \n" \
			"amber_3 $inp2/src/data/amber_x/ \n" \
			"amber_4 $inp2/src/data/amber_u/ \n" \
			"spce    $inp2/src/data/solvents/spce.rst \n" \
			"charmm_s $inp2/src/data/charmm_s/ \n" \
			"charmm_x $inp2/src/data/charmm_x/" > $HOME/.nwchemrc
			echo "NWChem resouce file has been created: $HOME/.nwchemrc"

		else
			echo "ERROR: Basis set directory \"$inp2/src/basis\" not found."

		fi
	else
		echo "You already have NWChem resource file which is $HOME/.nwchemrc."
		echo "Remove an existing resource file if you want to create a new one."

	fi

	;;
	$OPT4)
	
:<<'comment'
	 (4) Download NWChem source code
	  Download the tarball of nwchem-$VERSION to the present folder.
comment

	echo "Download NWChem $VERSION source code to your Linux machine"
	read -p "Enter directory where you want to store NWChem $VERSION source code, e.g. /home/$USER/: " NWCHEM_DIR

	if [ -e $NWCHEM_DIR ];then

		wget $NWCHEM_GIT_SRC -P $NWCHEM_DIR

		echo "***********************************************************************************"
		echo ""
		echo "Done!"
		echo ""
		echo "NWChem source code (src) has been downloaded to $NWCHEM_DIR."
		echo "Go to $NWCHEM_DIR and use the following command to uncompress the tarball."
		echo ""
		echo "$ tar -xvf $NWCHEM_SRC"
		echo ""
		echo "***********************************************************************************"
		echo ""

	else
		echo "ERROR: $NWCHEM_DIR not found."
	fi

	;;
	$OPT5)

:<<'comment'
	 (5) Author and Contact
comment

	echo ""
	echo -e "  Rangsiman Ketkaew                         E-Mail: rangsiman1993@gmail.com\n" \
		" Computational Chemistry Research Unit\n" \
		" C403, LC.5, Department of Chemistry       https://sites.google.com/site/rangsiman1993\n" \
		" Thammasat University, 12120 Thailand      https://github.com/rangsimanketkaew \n"

	;;
	$OPT6)
	
	break

	;;
	*)

	echo "ERROR: Invalid option."

	esac
done


