## Create script for setting environment variable
## You can use the script that you used to compile your NWChem.

## Navigate to sub-directtory where you have modified the code, says

cd $NWCHEM_TOP/src/nwdft/scf_dft
make

# Recompile using command
cd $NWCHEM_TOP/src
make link
