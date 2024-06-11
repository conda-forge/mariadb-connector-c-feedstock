#!/usr/bin/env bash
set -e -x

mkdir build
cd build

 cmake ${CMAKE_ARGS} \
     -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_INSTALL_PREFIX=${PREFIX} \
     ..

cmake --build . --config RelWithDebInfo -j --compile-no-warning-as-error

ctest --rerun-faild --output-on-failure --test-dir $SRC_DIR/build/unittest/libmariadb
ctest --rerun-faild --output-on-failure --test-dir $SRC_DIR/build/unittest/mytap

cmake --install . --config RelWithDebInfo --prefix ${PREFIX}