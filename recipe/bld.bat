mkdir build && cd build

:: Set INSTALL_DOCREADMEDIR to a junk path to avoid installing the README into PREFIX
cmake %CMAKE_ARGS% ^
	-GNinja ^
	-DCMAKE_BUILD_TYPE="Release" ^
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
	-DDEFAULT_SSL_VERIFY_SERVER_CERT=OFF ^
	-DWITH_SSL=OPENSSL ^
	 ..

cmake --build . --config RelWithDebInfo -j --target install

if errorlevel 1 exit 1
ctest --rerun-failed --output-on-failure --test-dir %SRC_DIR%\build\unittest\libmariadb
ctest --rerun-failed --output-on-failure --test-dir %SRC_DIR%\build\unittest\mytap

cmake --install .
if errorlevel 1 exit 1
