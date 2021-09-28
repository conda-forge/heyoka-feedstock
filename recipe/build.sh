#!/usr/bin/env bash

# mp++ setup.
if [[ "$target_platform" == osx-* || "$target_platform" == linux-aarch64 ]]; then
    export ENABLE_MPPP=no
else
    export ENABLE_MPPP=yes
fi

# IPO setup.
if [[ "$target_platform" == linux-ppc64le ]]; then
    export ENABLE_IPO=no
else
    export ENABLE_IPO=yes
fi

# Build & run the tests?
if [[ "$target_platform" == linux-ppc64le || "$target_platform" == linux-aarch64 ]]; then
    export ENABLE_TESTS=no
else
    export ENABLE_TESTS=yes
fi

# Workaround for missing C++17 feature when building the tests.
# Also, workaround for compile issue on older OSX SDKs.
if [[ "$target_platform" == osx-* ]]; then
    export CXXFLAGS="$CXXFLAGS -DCATCH_CONFIG_NO_CPP17_UNCAUGHT_EXCEPTIONS -D_LIBCPP_DISABLE_AVAILABILITY"
fi

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DHEYOKA_WITH_MPPP=$ENABLE_MPPP \
    -DHEYOKA_BUILD_TESTS=$ENABLE_TESTS \
    -DHEYOKA_WITH_SLEEF=yes \
    -DHEYOKA_ENABLE_IPO=$ENABLE_IPO \
    -DBoost_NO_BOOST_CMAKE=ON \
    -DHEYOKA_INSTALL_LIBDIR=lib \
    ..

make -j${CPU_COUNT} VERBOSE=1

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" && "$target_platform" != linux-ppc64le && "$target_platform" != linux-aarch64 ]]; then
    ctest -j${CPU_COUNT} --output-on-failure
fi

make install
