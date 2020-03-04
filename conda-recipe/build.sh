##########################################
# Environment variables
##########################################
export condaname="agiletools"
export CFITSIO=$PREFIX
export ROOTSYS=$PREFIX
export AGILE=$PREFIX/agiletools
export C_INCLUDE_PATH=$PREFIX/include
export CPP_INCLUDE_PATH=$PREFIX/include
export ZLIBPATH=$PREFIX/lib

export PFILES=$PFILES:$AGILE/share
export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=$PREFIX/lib:$LIBRARY_PATH
export PATH=$AGILE/bin:$AGILE/scripts:$PATH
export BUILD_ANACONDA=true

########################################
# AGILE ScienceTools
########################################
./downloadScienceTools.sh
./installScienceTools.sh
./downloadIRFConda.sh
./installIRFConda.sh


##########################################
# Copying files
##########################################
cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/activate_${condaname}.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.sh
