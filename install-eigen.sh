#!/usr/bin/env bash

prefix="$1" # Installation directory prefix
build_type="${2:-RelWithDebInfo}"
version="master"

if [ -z "$prefix" ]; then
    if [ -z "$VIRTUAL_ENV" ]; then
        echo "No active virtual environment, refusing to install."
        exit 1
    else
        prefix="$VIRTUAL_ENV"
    fi
fi

set -ex
export CMAKE_PREFIX_PATH="$prefix:$CMAKE_PREFIX_PATH"
export PKG_CONFIG_PATH="$prefix/lib/pkgconfig:$PKG_CONFIG_PATH"

pushd /tmp

# Eigen
[ -d eigen ] \
 || git clone --single-branch --depth=1 --branch "$version" \
    https://gitlab.com/libeigen/eigen.git
pushd eigen
cmake -S. -Bbuild \
    -G "Ninja Multi-Config" \
    -D CMAKE_INSTALL_PREFIX="$prefix" \
    -D CMAKE_POSITION_INDEPENDENT_CODE=On
cmake --build build -j --config $build_type
cmake --install build --config $build_type
popd

popd
