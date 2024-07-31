mkdir build && cd build

:: Set INSTALL_DOCREADMEDIR to a junk path to avoid installing the README into PREFIX
cmake %CMAKE_ARGS% ^
      -GNinja ^
      -DCMAKE_BUILD_TYPE="Release" ^
      -DCMAKE_C_FLAGS="-I%LIBRARY_INC%" ^
      -DCMAKE_CXX_FLAGS="-I%LIBRARY_INC%" ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -DINSTALL_DOCREADMEDIR_STANDALONE="%cd%/junk" ^
      -DINSTALL_DOCDIR="%cd%/junk" ^
      -DWITH_SSL=ON ^
      -DDEFAULT_SSL_VERIFY_SERVER_CERT=OFF ^
      -DAUTH_GSSAPI=ON ^
      ..

cmake --build . --config RelWithDebInfo -j

if errorlevel 1 exit 1
ctest --rerun-failed --output-on-failure --test-dir %SRC_DIR%\build\unittest\libmariadb
ctest --rerun-failed --output-on-failure --test-dir %SRC_DIR%\build\unittest\mytap

cmake --install .
if errorlevel 1 exit 1
