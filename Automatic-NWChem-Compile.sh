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
version 1.3 Support OpenMPI, MPICH, MVAPICH2, and Intel MPI
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
	 export NWCHEM_TOP="/absolute/path/to/top/directory/of/nwchem/"
comment

	read -p "Enter absolute path of NWChem top directory: [/home/$USER/nwchem-${VERSION}]: " inp
	if [ -z $inp ];then
		USER_NWCHEM_TOP="/home/$USER/nwchem-${VERSION}"
	else
		if [ ! -d $inp ];then
			echo "Directory you entered does not exist."
			exit 1
		fi
	fi

	read -p "Enter NWChem target: [LINUX64]: " inp
	if [[ -z $inp || ${inp,,} == "linux64" ]];then
		USER_NWCHEM_TARGET="LINUX64"
	else
		echo "ERROR: This program supports only LINUX64 target"
		exit 1
	fi

	read -p "Enter NWChem target: [all]: " inp
	if [[ -z $inp || ${inp,,} == "all" ]];then
		USER_NWCHEM_MODULES="all"
	else
		USER_NWCHEM_MODULES="$inp"
	fi

	read -p "Compile with Python: [Yes]/No: " inp
	if [[ -z $inp || ${inp,,} == "yes" ]];then
		CHECK_PYTHON="y"
		USER_NWCHEM_MODULES="${USER_NWCHEM_MODULES} python"

		read -p "Enter version of Python you are using: 2.6/[2.7]: " inp
		if [ -z $inp ];then
			USER_PYTHON_VERSION="2.7"
		else
			USER_PYTHON_VERSION=$inp
		fi

		read -p "Enter absolute path of Python directory: [/usr]: " inp
		if [ -z $inp ];then
			USER_PYTHON_HOME="/usr"
		else
			USER_PYTHON_HOME=$inp
			if [ ! -d $USER_PYTHON_HOME ];then
				echo "ERROR: Directory you entered does not exist."
				exit 1
			fi
		fi

		read -p "Use Python 64 bit: [Yes]/No: " inp
		if [[ -z $inp || ${inp,,} == "yes" ]];then
			USER_PYTHON64="y"
		elif [ ${inp,,} == "no" ];then
			USER_PYTHON64="n"
		else
			echo "ERROR: You entered incorrect answer."
			exit 1
		fi

		read -p "Enter type of Python library: [so]: " inp
		if [ -z $inp ];then
			USER_PYTHONLIBTYPE="so"
		else
			USER_PYTHONLIBTYPE=$inp
		fi

	elif [ ${inp,,} == "no" ];then
		CHECK_PYTHON="n"
		USER_PYTHON_VERSION=""
		USER_PYTHON_HOME=""
		USER_PYTHON64=""
		USER_PYTHONLIBTYPE=""

	else
		echo "ERROR: You entered incorrect answer."
		exit 1
	fi

	read -p "Compile with special method: [Yes]/No: " inp
	if [[ -z $inp || ${inp,,} == "yes" ]];then
		CHECK_SPECIAL_METHOD="y"
	elif [ ${inp,,} == "no" ];then
		CHECK_SPECIAL_METHOD="n"
	else
		echo "ERROR: You entered incorrect answer."
		exit 1
	fi

	read -p "Compile with MPI: [yes]/no: " inp
	if [[ -z $inp || ${inp,,} == "yes" ]];then
	
		USER_MPI_INCLUDE=$(${USER_NWCHEM_TOP}/src/tools/guess-mpidefs | awk '{if(NR==1) print $0}')
		USER_MPI_LIB=$(${USER_NWCHEM_TOP}/src/tools/guess-mpidefs | awk '{if(NR==2) print $0}')
		USER_LIBMPI=$(${USER_NWCHEM_TOP}/src/tools/guess-mpidefs | awk '{if(NR==3) print $0}')
	elif [ ${inp,,} == "no" ];then
		CHECK_MPI="n"
	else
		echo "ERROR: You entered incorrect answer."
		exit 1
	fi

	read -p "Compile with OpenMP: [yes]/no: " inp
	if [[ -z $inp || ${inp,,} == "yes" ]];then
		CHECK_OPENMP="y"
	elif [ ${inp,,} == "no" ];then
		CHECK_OPENMP="n"
	else
		echo "ERROR: You entered incorrect answer."
		exit 1
	fi

	read -p "Compile with OpenBLAS: [yes]/no: " inp
	if [[ -z $inp || ${inp,,} == "yes" ]];then
		USER_BLAS_SIZE="4"
		USER_BLAS_LIB="-lopenblas -lpthread -lrt"
	elif [ ${inp,,} == "no" ];then
		USER_BLAS_SIZE=""
		USER_BLAS_LIB=""
	else
		echo "ERROR: You entered incorrect answer."
		exit 1
	fi

	read -p "Compile with ARMCI method: [yes]/no: " inp
	if [[ -z $inp || ${inp,,} == "yes" ]];then
			read -p "Enter ARMCI Network: [MPI-PR]: " inp
			if [[ -z $inp || ${inp,,} == "mpi-pr" ]];then
				USER_ARMCI_NETWORK="MPI-PR"
			else
				USER_ARMCI_NETWORK=$inp
			fi
	elif [ ${inp,,} == "no" ];then
		USER_ARMCI_NETWORK=""
	else
		echo "ERROR: You entered incorrect answer."
		exit 1
	fi

	read -p "C++ and FC Compilers, [gnu]/intel: " inp
	if [[ -z $inp || ${inp,,} == "yes" ]];then
		USER_CC="gcc"
		USER_FC="gfortran"
	elif [ ${inp,,} == "intel" ];then
		USER_CC="icc"
		USER_FC="ifort"
	else
		echo "ERROR: You entered incorrect answer."
		exit 1
	fi

	read -p "Convert 64to32bit: [yes]/no: " inp
	if [[ -z $inp || ${inp,,} == "yes" ]];then
		USER_64TO32="y"
	elif [ ${inp,,} == "no" ];then
		USER_64TO32="n"
	else
		echo "ERROR: You entered incorrect answer."
		exit 1
	fi

cat << EOF > $PWD/INSTALL_NWCHEM.sh
#!/bin/bash

#######################################################################
## This script was generated by Automatic NWChem Compilation program ##
##            https://github.com/rangsimanketkaew/NWChem             ##
#######################################################################

# ------------------------- NWCHEM Parameter ------------------------
export NWCHEM_TOP=${USER_NWCHEM_TOP}
export NWCHEM_TARGET=${USER_NWCHEM_TARGET}
export NWCHEM_LONG_PATHS=y
export NWCHEM_FSCHECK=N
export USE_NOFSCHECK=TRUE
export LARGE_FILES=TRUE
# ------------------------- NWChem module ---------------------------
export NWCHEM_MODULES=${USER_NWCHEM_MODULES}
# ------------------------- Special method compilation---------------
export MRCC_THEORY=${CHECK_SPECIAL_METHOD}
export EACCSD=${CHECK_SPECIAL_METHOD}
export IPCCSD=${CHECK_SPECIAL_METHOD}
export CCSDTQ=${CHECK_SPECIAL_METHOD}
export CCSDTLR=${CHECK_SPECIAL_METHOD}
# ------------------------- Python Libraries ------------------------
export USE_PYTHONCONFIG=${CHECK_PYTHON}
export PYTHONVERSION=${USER_PYTHON_VERSION}
export PYTHONHOME=${USER_PYTHON_HOME}
export USE_PYTHON64=${USER_PYTHON64}
export PYTHONLIBTYPE=${USER_PYTHONLIBTYPE}
# ------------------------- OpenMPI libraries -----------------------
export USE_OPENMP=${CHECK_OPENMP}
# ------------------------- MPI libraries ---------------------------
export USE_MPI=${CHECK_MPI}
export USE_MPIF=${CHECK_MPI}
export USE_MPIF4=${CHECK_MPI}
export MPI_INCLUDE=${USER_MPI_INCLUDE}
export MPI_LIB=${USER_MPI_LIB}
export LIBMPI=${USER_MPILIB}
# ------------------------- MATH libraries --------------------------
export BLAS_SIZE=${USER_BLAS_SIZE}
export BLASOPT=${USER_BLAS_LIB}
# ------------------------- ARMCI method ----------------------------
export ARMCI_NETWORK=${USER_ARMCI_NETWORK}
# ------------------------- Compilers -------------------------------
export CC=${USER_CC}
export FC=${USER_FC}
# ------------------------- Convert 64to32bit -----------------------
export USE_64TO32=${USER_64TO32}

# ------------------------- Compile ---------------------------------
export MAKEMODULES=${USER_NWCHEM_MODULES}
make nwchem_config ${MAKEMODULES} >& make_config.log
make 64_to_32 >& make_64to32.log
export MAKEOPTS="USE_64TO32=${USER_64TO32}"
make FC=${FC} ${MAKEOPTS} >& make_compile.log

EOF

	echo ""
	echo "====================================================================="
	echo "Install NWChem version $VERSION with Message Passing Interface (MPI)"
	echo ""
	echo "Configuration compilation has been saved."
	echo "Please check $PWD/INSTALL_NWCHEM.sh"
	echo "====================================================================="
	echo ""

	read -p "Enter YES to start compiling: " COMPILE

	if [ $COMPILE == YES ] || [ $COMPILE == yes ] || [ $COMPILE == y ]; then

		export NWCHEM_TOP=${USER_NWCHEM_TOP}
		export NWCHEM_LINUX={$USER_NWCHEM_TARGET}

		echo ""
		echo " NWChem compilation and installation started!!!"
		echo ""
		echo " This can take 20-50 minutes. :-)"
		echo ""
		echo " >>>>>>> Please do not terminate this terminal. <<<<<<<"
		echo ""

		cp $PWD/INSTALL_NWCHEM.sh ${NWCHEM_TOP}/src
		cd ${NWCHEM_TOP}/src
		chmod +x INSTALL_NWCHEM.sh
		# Compile
		./INSTALL_NWCHEM.sh
		#
		wait
		cp make_compile.log make_compile.log.2
		echo " Compilation and installation have finished!!!"
		echo " Checking if NWChem is installed correctly ..."
		echo ""
		echo " -------------------------------------------------------------"
		echo ""
	fi

	if [ -e ${NWCHEM_TOP}/bin/${NWCHEM_TOP}/nwchem ]; then

		echo " ======================================================="
		echo " Congratulations! NWChem has been compiled successfully."
		echo " ======================================================="
		echo ""
		echo " NWChem executable can be found at ${NWCHEM_TOP}/bin/${NWCHEM_TOP}/nwchem"
		echo " Log file is at ${NWCHEM_TOP}/src/compile*.log"
		echo ""
		echo " You can try running NWChem by using the following command"
		echo ""
		echo " $ ${NWCHEM_TOP}/bin/${NWCHEM_TARGET}/nwchem"

	else
		if [ -e ${NWCHEM_TOP}/src/make_compile.log.2 ];then

			echo " ==========================================="
			echo " Unfortunately, program compilation failed!"
			echo " ==========================================="
			echo ""
			echo " Check following files to view Log."
			echo ""
			echo " ${NWCHEM_TOP}/src/make_config.log"
			echo " ${NWCHEM_TOP}/src/make_64to32.log"
			echo " ${NWCHEM_TOP}/src/make_compile.log"
			echo ""
			echo " Please look at the end of LOG file to see error message."
			echo " You can send the log file to me via e-mail: rangsiman1993@gmail.com"
			echo " Otherwise, consult NWChem developer at http://www.nwchem-sw.org/index.php/Special:AWCforum"
			echo ""

			rm ${NWCHEM_TOP}/src/make_compile.log.2
		fi
	fi

	;;
	$OPT3)

:<<'comment'
	 (3) Creat NWChem Resource file 
	  Create .nwchemrc file that point to directory of NWChem data and libraries.
comment

	if [ ! -e $HOME/.nwchemrc ];then

		read -p "Enter absolute path of NWChem top directory: e.g. /home/$USER/nwchem-${VERSION}: " inp

		if [ -e $inp/src/basis ]; then

			touch $HOME/.nwchemrc
			echo -e \
			"nwchem_basis_library $inp/src/basis/libraries/ \n" \
			"nwchem_nwpw_library $inp/src/nwpw/libraryps/ \n" \
			"ffield amber \n" \
			"amber_1 $inp/src/data/amber_s/ \n" \
			"amber_2 $inp/src/data/amber_q/ \n" \
			"amber_3 $inp/src/data/amber_x/ \n" \
			"amber_4 $inp/src/data/amber_u/ \n" \
			"spce    $inp/src/data/solvents/spce.rst \n" \
			"charmm_s $inp/src/data/charmm_s/ \n" \
			"charmm_x $inp/src/data/charmm_x/" > $HOME/.nwchemrc
			echo "NWChem resouce file has been created: $HOME/.nwchemrc"

		else
			echo "ERROR: Basis set directory \"$inp/src/basis\" not found."

		fi
	else
		echo "You already have NWChem resource file which is at $HOME/.nwchemrc."
		echo "Remove an existing resource file if you want to create a new one."

	fi

	;;
	$OPT4)
	
:<<'comment'
	 (4) Download NWChem source code
	  Download the tarball of nwchem-$VERSION to the present folder.
comment

	echo "Download NWChem $VERSION source code from Github repository"
	read -p "Enter directory where you want to place NWChem $VERSION source code: [/home/$USER/]: " NWCHEM_DIR

	if [ -z $NWCHEM_DIR ];then
		NWCHEM_DIR="/home/$USER/"
	fi

	if [ -d $NWCHEM_DIR ];then

		wget $NWCHEM_GIT_SRC -P $NWCHEM_DIR

		echo " "
		echo " Done! NWChem source code (src) has been downloaded to $NWCHEM_DIR."
		echo ""

		read -p "Do you want to extract the tarball now?: [Yes]/No: " inp
		if [[ -z $inp || ${inp,,} == "yes" ]];then
			tar -xvf $NWCHEM_DIR/$NWCHEM_SRC
		fi

		echo " Uncompressing NWChem tarball done!"
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


