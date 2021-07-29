#!/usr/bin/env bash

if [[ "$target_platform" == osx-* ]]; then
    export ENABLE_MPPP=no
    # Workaround for missing C++17 feature when building the tests.
    # Also, workaround for compile issue on older OSX SDKs.
    export CXXFLAGS="$CXXFLAGS -DCATCH_CONFIG_NO_CPP17_UNCAUGHT_EXCEPTIONS -D_LIBCPP_DISABLE_AVAILABILITY"
elif [[ "$target_platform" == linux-aarch64 ||  "$target_platform" == linux-ppc64le ]]; then
    export ENABLE_MPPP=no
else
    export ENABLE_MPPP=yes
fi

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DHEYOKA_WITH_MPPP=$ENABLE_MPPP \
    -DHEYOKA_BUILD_TESTS=yes \
    -DHEYOKA_WITH_SLEEF=yes \
    -DHEYOKA_ENABLE_IPO=yes \
    -DBoost_NO_BOOST_CMAKE=ON \
    -DHEYOKA_INSTALL_LIBDIR=lib \
    ..

make -j${CPU_COUNT} VERBOSE=1

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
ctest -j${CPU_COUNT} --output-on-failure
fi

make install
