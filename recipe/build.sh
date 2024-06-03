#!/usr/bin/env bash
set -e -x

mkdir build
cd build

 cmake ${CMAKE_ARGS} \
     -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_INSTALL_PREFIX=${PREFIX} \
     ..

make -k -j${CPU_COUNT}
ctest --rerun-faild --output-on-failure --test-dir $SRC_DIR/build/unittest/libmariadb
ctest --rerun-faild --output-on-failure --test-dir $SRC_DIR/build/unittest/mytap
# make install
cmake --build .