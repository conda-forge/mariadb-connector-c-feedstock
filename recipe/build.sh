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

if [[ $target_platform == *"osx"* ]]; then
    cmake ${CMAKE_ARGS} \
        -DWITH_EXTERNAL_ZLIB=ON \
        -DWITH_ZLIB=system \
        -DCMAKE_BUILD_TYPE=Release \
        -DWITH_SSL=ON \
        -DDEFAULT_SSL_VERIFY_SERVER_CERT=OFF \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        ..
#elif [[$target_platform == osx-arm64 ]] && [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
    # Build all intermediate codegen binaries for the build platform
    # xref: https://cmake.org/pipermail/cmake/2013-January/053252.html
#    env -u SDKROOT -u CONDA_BUILD_SYSROOT -u CMAKE_PREFIX_PATH \
#        -u CXXFLAGS -u CPPFLAGS -u CFLAGS -u LDFLAGS \
#        cmake -S$SRC_DIR -Bbuild.codegen -GNinja \
#            -DWITH_ICU=system \
#            -DWITH_EXTERNAL_ZLIB=ON \
#            -DDEFAULT_SSL_VERIFY_SERVER_CERT=OFF \
#            -DWITH_ZSTD=system \
#            -DWITH_PROTOBUF=system \
#            -DCMAKE_PREFIX_PATH=$BUILD_PREFIX \
#            -DCMAKE_C_COMPILER=$CC_FOR_BUILD \
#            -DCMAKE_CXX_COMPILER=$CXX_FOR_BUILD \
#            -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc \
#            -DCMAKE_CXX_FLAGS="-isystem $BUILD_PREFIX/include" \
#            -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,$BUILD_PREFIX/lib -L$BUILD_PREFIX/lib"
#
#    cmake --build build.codegen -- \
#        xprotocol_plugin comp_err comp_sql gen_lex_hash libmysql_api_test \
#        json_schema_embedder gen_lex_token gen_keyword_list comp_client_err \
#        cno_huffman_generator
#
#    # Put the codegen binaries in $PATH
#    export PATH=$SRC_DIR/build.codegen/runtime_output_directory:$PATH
#    export PATH=$SRC_DIR/build.codegen/router/src/json_schema_embedder:$PATH
#
#    # Tell cmake about our cross compilation
#    _xtra_cmake_args+=(${CMAKE_ARGS})

    # The MySQL CMake files use TRY_RUN/CHECK_C_SOURCE_RUNS to inspect certain
    # properties about the build environment. Since we are cross compiling, we
    # cannot run these executables (which target the host platform) on the
    # build platform, so we tell CMake about their results explicitly:

    ## 11.1 SDK does support CLOCK_GETTIME with CLOCK_MONOTONIC and CLOCK_REALTIME as arguments
#    _xtra_cmake_args+=(-DHAVE_CLOCK_GETTIME_EXITCODE=0)
#    _xtra_cmake_args+=(-DHAVE_CLOCK_REALTIME_EXITCODE=0)

    ## Tell the build system that our cross compiler version is sufficient for the build
#    _xtra_cmake_args+=(-DHAVE_SUPPORTED_CLANG_VERSION_EXITCODE=0)

    ## Use the protoc from the build platform as it needs to be exec'd
#    _xtra_cmake_args+=(-DPROTOBUF_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc)

    # Copied from the osx-64 build
#    _xtra_cmake_args+=(-DHAVE___BUILTIN_FFS=1)

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
