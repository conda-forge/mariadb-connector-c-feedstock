#!/usr/bin/env bash
set -e -x

# For linux-ppc64le
if [[ "${target_platform}" == "linux-ppc64le" ]]; then
  # avoid error 'relocation truncated to fit: R_PPC64_REL24'
  export CFLAGS="$(echo ${CFLAGS} | sed 's/-fno-plt//g') -fplt"
  export CXXFLAGS="$(echo ${CXXFLAGS} | sed 's/-fno-plt//g') -fplt"
fi

mkdir build
cd build

# -Wno-inline-asm => For osx-arm64, to prevent throwing an error on compilation.
if [[ "${target_platform}" == "osx-arm64" ]]; then
    cmake ${CMAKE_ARGS} \
    -DWITH_EXTERNAL_ZLIB=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DDEFAULT_SSL_VERIFY_SERVER_CERT=OFF \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -CMAKE_COMPILE_WARNING_AS_ERROR=OFF \
     ..
else 
    cmake ${CMAKE_ARGS} \
    -DWITH_EXTERNAL_ZLIB=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DDEFAULT_SSL_VERIFY_SERVER_CERT=OFF \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
     ..
fi

cmake --build . --config RelWithDebInfo -j --target install

# Added for osx-arm
if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
   ctest --rerun-failed --output-on-failure --test-dir $SRC_DIR/build/unittest/libmariadb
   ctest --rerun-failed --output-on-failure --test-dir $SRC_DIR/build/unittest/mytap
fi

cmake --install . --config RelWithDebInfo --prefix ${PREFIX}
