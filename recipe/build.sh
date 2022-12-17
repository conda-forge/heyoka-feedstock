#!/usr/bin/env bash

if [[ "$target_platform" == osx-* ]]; then
    # Workaround for compile issues on older OSX SDKs.
    export CXXFLAGS="$CXXFLAGS -fno-aligned-allocation -DCATCH_CONFIG_NO_CPP17_UNCAUGHT_EXCEPTIONS -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# IPO setup.
if [[ "$target_platform" == linux-ppc64le ]]; then
    export ENABLE_IPO=no
else
    export ENABLE_IPO=yes
fi

# Static build setup.
if [[ "$target_platform" == linux-ppc64le ]]; then
    export ENABLE_STATIC=no
else
    export ENABLE_STATIC=yes
fi

# Build & run the tests?
if [[ "$target_platform" == linux-ppc64le || "$target_platform" == linux-aarch64 || "$target_platform" == osx-* ]]; then
    export ENABLE_TESTS=no
else
    export ENABLE_TESTS=yes
fi

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DHEYOKA_WITH_MPPP=YES \
    -DHEYOKA_BUILD_TESTS=$ENABLE_TESTS \
    -DHEYOKA_WITH_SLEEF=YES \
    -DHEYOKA_ENABLE_IPO=$ENABLE_IPO \
    -DBoost_NO_BOOST_CMAKE=ON \
    -DHEYOKA_INSTALL_LIBDIR=lib \
    -DHEYOKA_FORCE_STATIC_LLVM=$ENABLE_STATIC \
    -DHEYOKA_HIDE_LLVM_SYMBOLS=$ENABLE_STATIC \
    ..

make -j${CPU_COUNT} VERBOSE=1

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" && "$ENABLE_TESTS" == yes ]]; then
    ctest -j${CPU_COUNT} --output-on-failure
fi

make install
