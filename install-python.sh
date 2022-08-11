#!/usr/bin/env bash

set -ex

version="${1:-3.10}"
prefix="${2:-/usr/local}"
builddir="/tmp"
# opts="--with-lto --enable-optimizations"
# opts="--with-lto"

case $version in 
  3.7)
    full_version="3.7.13";;
  3.8)
    full_version="3.8.13";;
  3.9)
    full_version="3.9.13";;
  3.10)
    full_version="3.10.6";;
  3.11)
    full_version="3.11.0"
    version_suffix="rc1";;
esac
python="Python-${full_version}${version_suffix}"

# Download and extract the Python source code
mkdir -p "$builddir"
pushd "$builddir"
if [ ! -d "$python" ]; then
    wget -O- "https://www.python.org/ftp/python/$full_version/$python.tgz" | tar -xz
fi

pushd "$python"
./configure --prefix="$prefix" \
    --enable-ipv6 \
    --enable-shared \
    $opts \
    'LDFLAGS=-Wl,-rpath,\$$ORIGIN/../lib'

make -j$(($(nproc) + 2))
# make altinstall
make install

popd
popd
rm -rf "$builddir"
