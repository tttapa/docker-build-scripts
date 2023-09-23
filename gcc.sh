#!/usr/bin/env bash

set -ex

update-alternatives --remove "cc"         "/usr/bin/cc"
update-alternatives --remove "cpp"        "/usr/bin/cpp"
update-alternatives --remove "c++"        "/usr/bin/c++"
update-alternatives --remove "gcc"        "/usr/bin/gcc"
update-alternatives --remove "g++"        "/usr/bin/g++"
update-alternatives --remove "gfortran"   "/usr/bin/gfortran"
update-alternatives --remove "gcov"       "/usr/bin/gcov"
update-alternatives --remove "gcov-dump"  "/usr/bin/gcov-dump"
update-alternatives --remove "gcov-tool"  "/usr/bin/gcov-tool"
update-alternatives --remove "gcc-ar"     "/usr/bin/gcc-ar"
update-alternatives --remove "gcc-ranlib" "/usr/bin/gcc-ranlib"
update-alternatives --remove "gcc-nm"     "/usr/bin/gcc-nm"
update-alternatives --remove "lto-dump"   "/usr/bin/lto-dump"

for v in "$@"; do
    update-alternatives \
        --install "/usr/bin/cc"       "cc" "$(which gcc-$v)" $(($v * 10)) \
        --slave "/usr/bin/cpp"        "cpp" "$(which cpp-$v)" \
        --slave "/usr/bin/c++"        "c++" "$(which g++-$v)" \
        --slave "/usr/bin/gcc"        "gcc" "$(which gcc-$v)" \
        --slave "/usr/bin/g++"        "g++" "$(which g++-$v)" \
        --slave "/usr/bin/gfortran"   "gfortran" "$(which gfortran-$v)" \
        --slave "/usr/bin/gcov"       "gcov" "$(which gcov-$v)" \
        --slave "/usr/bin/gcov-dump"  "gcov-dump" "$(which gcov-dump-$v)" \
        --slave "/usr/bin/gcov-tool"  "gcov-tool" "$(which gcov-tool-$v)" \
        --slave "/usr/bin/gcc-ar"     "gcc-ar" "$(which gcc-ar-$v)" \
        --slave "/usr/bin/gcc-ranlib" "gcc-ranlib" "$(which gcc-ranlib-$v)" \
        --slave "/usr/bin/gcc-nm"     "gcc-nm" "$(which gcc-nm-$v)" \
        --slave "/usr/bin/lto-dump"   "lto-dump" "$(which lto-dump-$v)"
done
