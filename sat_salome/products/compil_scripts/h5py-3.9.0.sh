#!/bin/bash                                                                                                                                                                              

echo "##########################################################################"
echo "h5py" $VERSION
echo "##########################################################################"

rm -rf ${BUILD_DIR}
mkdir ${BUILD_DIR}
cd $BUILD_DIR
cp -r $SOURCE_DIR/* .

if [ -n "$SAT_HPC" ]  && [ -n "$MPI_ROOT_DIR" ]; then
    echo "WARNING: setting CC and CXX environment variables and target MPI wrapper"
    export CXX="${MPI_CXX_COMPILER}"
    export CC="${MPI_C_COMPILER}"
fi

echo "*** ${PYTHONBIN} -m pip install . --cache-dir=${BUILD_DIR}/cache/pip --prefix=${PRODUCT_INSTALL}"
if ! ${PYTHONBIN} -m pip install . --cache-dir="${BUILD_DIR}/cache/pip" --prefix="${PRODUCT_INSTALL}"; then
    echo "pip install ${PRODUCT_NAME} fails"
    exit 1
fi

if [ -d ${PRODUCT_INSTALL}/lib64 ];then
    mv ${PRODUCT_INSTALL}/lib64 ${PRODUCT_INSTALL}/lib
fi

if [ -d ${PRODUCT_INSTALL}/lib/python${PYTHON_VERSION}/dist-packages ]; then
    mv ${PRODUCT_INSTALL}/lib/python${PYTHON_VERSION}/dist-packages ${PRODUCT_INSTALL}/lib/python${PYTHON_VERSION}/site-packages
fi

echo
echo "########## END"

