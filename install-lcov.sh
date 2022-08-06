#!/usr/bin/env bash

# Script to download and install LCOV

set -ex

version="${1:-v1.15}"         # Release tag on GitHub
prefix="${2:-/usr/local}"     # Install prefix
tmpdir="/tmp/lcov-build"      # Temporary build folder

# Build folder
mkdir "$tmpdir"
pushd "$tmpdir"

# Download
git clone --single-branch --depth=1 --branch "$version" \
    https://github.com/linux-test-project/lcov.git
# Install
make -C lcov install PREFIX="$prefix"

# Cleanup
popd
rm -rf "$tmpdir"
