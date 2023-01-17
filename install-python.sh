#!/usr/bin/env bash

set -ex

version="${1:-3.10}"
prefix="${2:-/usr/local}"
builddir="/tmp"

function build_cpython {
    # opts="--with-lto --enable-optimizations"
    # opts="--with-lto"
    case $version in
        3.7)
            full_version="3.7.16";;
        3.8)
            full_version="3.8.16";;
        3.9)
            full_version="3.9.16";;
        3.10)
            full_version="3.10.9";;
        3.11)
            full_version="3.11.1";;
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
}

function install_pypy {
    case $version in
        pypy3.7)
            full_version="7.3.9";;
        pypy3.8)
            full_version="7.3.11";;
        pypy3.9)
            full_version="7.3.11";;
    esac
    mkdir -p "$prefix"
    wget -O- "https://downloads.python.org/pypy/$version-v$full_version-linux64.tar.bz2" | tar -xj --strip-components=1 -C "$prefix"
}

if [[ $version == pypy* ]]; then
    install_pypy
else
    build_cpython
fi
