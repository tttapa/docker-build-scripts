#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"
set -ex

for py_version in 3.7 3.8 3.9 3.10 3.11; do
    docker buildx build \
        --build-arg PYTHON_VERSION=$py_version \
        --target alpaqa-python-build \
        --tag tttapa/alpaqa-python-build:py$py_version \
        .
done
py_version=3.10
docker buildx build \
    --build-arg PYTHON_VERSION=$py_version \
    --target alpaqa-build \
    --tag tttapa/alpaqa-build:py$py_version \
    .
docker buildx build \
    --build-arg PYTHON_VERSION=$py_version \
    --target alpaqa-build-static \
    --tag tttapa/alpaqa-build-static:py$py_version \
    .
docker buildx build \
    --build-arg PYTHON_VERSION=$py_version \
    --target alpaqa-docs \
    --tag tttapa/alpaqa-docs:py$py_version \
    .
docker buildx build \
    --build-arg PYTHON_VERSION=$py_version \
    --target alpaqa-test \
    --tag tttapa/alpaqa-test:py$py_version \
    .
docker buildx build \
    --build-arg PYTHON_VERSION=$py_version \
    --target alpaqa-test-static \
    --tag tttapa/alpaqa-test-static:py$py_version \
    .
wait