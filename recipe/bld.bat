mkdir build
cd build

cmake ^
    -G "Visual Studio 17 2022" -A x64 ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DHEYOKA_BUILD_TESTS=yes ^
    -DHEYOKA_WITH_SLEEF=yes ^
    -DHEYOKA_WITH_MPPP=yes ^
    ..

cmake --build . --config Release -j1

set PATH=%PATH%;%CD%\Release

ctest --output-on-failure -j%CPU_COUNT% -V -C Release

cmake --build . --config Release --target install
