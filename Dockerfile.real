ARG GCC_VERSION
ARG PYTHON_VERSION

# Base -------------------------------------------------------------------------

FROM ghcr.io/tttapa/docker-python-build:gcc${GCC_VERSION}-py${PYTHON_VERSION} \
    as base

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y \
        zip unzip && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

FROM base as ninja

RUN wget https://github.com/ninja-build/ninja/releases/download/v1.11.0/ninja-linux.zip && \
    unzip ninja-linux.zip && \
    rm -f ninja-linux.zip && \
    mv ninja "/usr/local/bin"
RUN ninja --version

# Documentation ----------------------------------------------------------------

FROM ninja as doxygen

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y \
        bison flex graphviz libjson-perl libperlio-gzip-perl perl && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

COPY install-lcov.sh .
RUN bash ./install-lcov.sh "v1.15" "/usr/local"

COPY install-doxygen.sh .
RUN bash ./install-doxygen.sh "master" "/usr/local"

# Scientific -------------------------------------------------------------------

FROM ninja as casadi

COPY install-casadi.sh .
RUN bash install-casadi.sh "/opt/casadi"

FROM ninja as casadi-static

COPY install-casadi-static.sh .
RUN bash install-casadi-static.sh "/opt/casadi-static"

FROM ninja as eigen

COPY install-eigen.sh .
RUN bash install-eigen.sh "/opt/eigen"

FROM ninja as gtest

COPY install-gtest.sh .
RUN bash install-gtest.sh "/opt/gtest"

# Alpaqa -----------------------------------------------------------------------

# Full build with shared CasADi
FROM ninja as alpaqa-build

COPY --from=eigen /opt/eigen/ /usr/local/
COPY --from=gtest /opt/gtest/ /usr/local/
COPY --from=casadi /opt/casadi/ /usr/local/
RUN ldconfig

# Full build with static CasADi
FROM ninja as alpaqa-build-static

COPY --from=eigen /opt/eigen/ /usr/local/
COPY --from=gtest /opt/gtest/ /usr/local/
COPY --from=casadi-static /opt/casadi-static/ /usr/local/
RUN ldconfig

# Documentation with basic dependencies (no CasADi)
FROM doxygen as alpaqa-docs

COPY --from=eigen /opt/eigen/ /usr/local/
COPY --from=gtest /opt/gtest/ /usr/local/

# Limited Ubuntu image for testing Linux package
FROM ubuntu:jammy as alpaqa-test-base
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y \
        gcc g++ gfortran \
        cmake ninja-build \
        python3-dev python3-pip python3-venv \
        git zip unzip wget && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

FROM alpaqa-test-base as alpaqa-test

COPY --from=eigen /opt/eigen/ /usr/local/
COPY --from=gtest /opt/gtest/ /usr/local/
COPY --from=casadi /opt/casadi/ /usr/local/
RUN ldconfig

FROM alpaqa-test-base as alpaqa-test-static

COPY --from=eigen /opt/eigen/ /usr/local/
COPY --from=gtest /opt/gtest/ /usr/local/
RUN ldconfig
