#!/usr/bin/env bash
set -e -x

# For linux-ppc64le
if [[ "$target_platform" == "linux-ppc64le" ]]; then
  # avoid error 'relocation truncated to fit: R_PPC64_REL24'
  export CFLAGS="$(echo ${CFLAGS} | sed 's/-fno-plt//g') -fplt"
  export CXXFLAGS="$(echo ${CXXFLAGS} | sed 's/-fno-plt//g') -fplt"
fi

mkdir build
cd build

if [[ "${target_platform}" == *"osx"* ]]; then
    cmake ${CMAKE_ARGS} \
        -DWITH_EXTERNAL_ZLIB=ON \
        -DWITH_ZLIB=system \
        -DCMAKE_BUILD_TYPE=Release \
        -DWITH_SSL=ON \
        -DDEFAULT_SSL_VERIFY_SERVER_CERT=OFF \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        ..

    # cmake --build . --config RelWithDebInfo -j -DWITH_EXTERNAL_ZLIB=ON

elif [[ "${target_platform}" == *"linux"* ]]; then
    cmake ${CMAKE_ARGS} \
        -DCMAKE_BUILD_TYPE=Release \
        -DWITH_SSL=ON \
        -DDEFAULT_SSL_VERIFY_SERVER_CERT=OFF \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        ..
fi

cmake --build . --config RelWithDebInfo -j --target install

ctest --rerun-failed --output-on-failure --test-dir $SRC_DIR/build/unittest/libmariadb
ctest --rerun-failed --output-on-failure --test-dir $SRC_DIR/build/unittest/mytap

cmake --install . --config RelWithDebInfo --prefix ${PREFIX}
