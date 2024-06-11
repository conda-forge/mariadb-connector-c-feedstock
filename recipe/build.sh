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

 cmake ${CMAKE_ARGS} \
     -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_INSTALL_PREFIX=${PREFIX} \
     ..

cmake --build . --config RelWithDebInfo -j

ctest --rerun-faild --output-on-failure --test-dir $SRC_DIR/build/unittest/libmariadb
ctest --rerun-faild --output-on-failure --test-dir $SRC_DIR/build/unittest/mytap

cmake --install . --config RelWithDebInfo --prefix ${PREFIX}