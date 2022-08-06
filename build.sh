#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"
set -ex

gcc_version=11
for py_version in 3.7 3.8 3.9 3.10 3.11; do
    docker buildx build \
        --build-arg GCC_VERSION=$gcc_version \
        --build-arg PYTHON_VERSION=$py_version \
        --target alpaqa-build-static \
        --tag tttapa/alpaqa-build-static:gcc$gcc_version-py$py_version \
        .
    docker buildx build \
        --build-arg GCC_VERSION=$gcc_version \
        --build-arg PYTHON_VERSION=$py_version \
        --target alpaqa-build \
        --tag tttapa/alpaqa-build:gcc$gcc_version-py$py_version \
        .
done
py_version=3.10
docker buildx build \
    --build-arg GCC_VERSION=$gcc_version \
    --build-arg PYTHON_VERSION=$py_version \
    --target alpaqa-docs \
    --tag tttapa/alpaqa-docs:gcc$gcc_version-py$py_version \
    .
docker buildx build \
    --build-arg GCC_VERSION=$gcc_version \
    --build-arg PYTHON_VERSION=$py_version \
    --target alpaqa-test \
    --tag tttapa/alpaqa-test:gcc$gcc_version-py$py_version \
    .
docker buildx build \
    --build-arg GCC_VERSION=$gcc_version \
    --build-arg PYTHON_VERSION=$py_version \
    --target alpaqa-test-static \
    --tag tttapa/alpaqa-test-static:gcc$gcc_version-py$py_version \
    .
wait