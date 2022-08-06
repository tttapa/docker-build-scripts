ARG GCC_VERSION
ARG PYTHON_VERSION

# Base -------------------------------------------------------------------------

FROM ghcr.io/tttapa/docker-python-build:gcc${GCC_VERSION}-py${PYTHON_VERSION} \
    as base
RUN touch "gcc${GCC_VERSION}-py${PYTHON_VERSION}"

FROM base as ninja
RUN touch "ninja"

# Documentation ----------------------------------------------------------------

FROM ninja as doxygen
RUN touch "doxygen"

# Scientific -------------------------------------------------------------------

FROM ninja as casadi
COPY install-casadi.sh .

FROM ninja as casadi-static
COPY install-casadi-static.sh .

FROM ninja as eigen
COPY install-eigen.sh .

FROM ninja as gtest
COPY install-gtest.sh .

# Alpaqa -----------------------------------------------------------------------

# Full build with shared CasADi
FROM ninja as alpaqa-build
RUN touch "alpaqa-build"

# Full build with static CasADi
FROM ninja as alpaqa-build-static
RUN touch "alpaqa-build-static"

# Documentation with basic dependencies (no CasADi)
FROM doxygen as alpaqa-docs
RUN touch "alpaqa-docs"

# Limited Ubuntu image for testing Linux package
FROM ubuntu:jammy as alpaqa-test-base
RUN touch "alpaqa-test-base"

FROM alpaqa-test-base as alpaqa-test
RUN touch "alpaqa-test"

FROM alpaqa-test-base as alpaqa-test-static
RUN touch "alpaqa-test-static"
