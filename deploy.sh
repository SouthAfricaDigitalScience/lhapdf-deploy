#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add boost/1.63.0-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
module add  python/2.7.13-gcc-${GCC_VERSION}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
rm -rf  *
../configure \
--prefix=${SOFT_DIR}-gcc-${GCC_VERSION}-boost-${BOOST_VERSION} \
--with-boost=${BOOST_DIR} \
--enable-shared
make

make install
echo "Creating the modules file directory ${HEP}"
mkdir -p ${HEP}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/gmp-deploy"
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}
module add boost/1.63.0-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
module add  python/2.7.13-gcc-${GCC_VERSION}
setenv LHAPDF_VERSION       $VERSION
setenv LHAPDF_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(LHAPDF_DIR)/lib
setenv CFLAGS            "-I$::env(LHAPDF_DIR)/include $CFLAGS"
setenv LDFLAGS           "-L$::env(LHAPDF_DIR)/lib $LDFLAGS"
MODULE_FILE
) > ${HEP}/${NAME}/${VERSION}-gcc-${GCC_VERSION}-boost-${BOOST_VERSION}

echo "Checking module availability "
module  avail ${NAME}
echo "Checking module "
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}-boost-${BOOST_VERSION}
echo "attempting install of PDF set"
lhapdf install MMHT2014nlo68cl
lhapdf install MMHT2014lo68cl
