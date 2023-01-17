#!/usr/bin/env bash

# Script to download and install Doxygen

set -ex

version="${1:-Release_1_9_6}" # Release tag on GitHub
prefix="${2:-/usr/local}"     # Install prefix
tmpdir="/tmp/doxygen-build"   # Temporary build folder

# Build folder
mkdir "$tmpdir"
pushd "$tmpdir"

# Download
git clone --single-branch --depth=1 --branch "$version" \
    https://github.com/doxygen/doxygen.git
# Configure
cmake -Bbuild -Sdoxygen \
    -DCMAKE_INSTALL_PREFIX="$prefix" \
    -DCMAKE_BUILD_TYPE=Release
# Build
cmake --build build -j$(nproc)
# Install
cmake --install build

# Cleanup
popd
rm -rf "$tmpdir"
