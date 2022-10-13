# Base -------------------------------------------------------------------------

FROM ubuntu:jammy as build-base

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y \
        cmake make ninja-build g++ gcc git wget ca-certificates && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

FROM ghcr.io/tttapa/docker-centos7-toolchain:0.0.1a2 as compat-build-base

USER root
RUN chown develop /opt
USER develop

# Python -----------------------------------------------------------------------

FROM ubuntu:jammy as python

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        gcc g++ \
        wget ca-certificates \
        bzip2 \
        make pkg-config autotools-dev automake libpcre3-dev \
        zlib1g-dev libbz2-dev libssl-dev uuid-dev libffi-dev libreadline-dev \
        libsqlite3-dev libbz2-dev libncurses5-dev libreadline6-dev \
        libgdbm-dev libgdbm-compat-dev liblzma-dev && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ARG PYTHON_VERSION
COPY install-python.sh .
RUN bash install-python.sh ${PYTHON_VERSION} "/opt/python"

# Documentation ----------------------------------------------------------------

FROM build-base as doxygen

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y \
        bison flex && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

COPY --from=python /opt/python/ /usr/local/

COPY install-doxygen.sh .
RUN bash ./install-doxygen.sh "master" "/opt/doxygen"

FROM build-base as docs

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y \
        graphviz libjson-perl libperlio-gzip-perl perl && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

COPY install-lcov.sh .
RUN bash ./install-lcov.sh "v1.15" "/usr/local"

COPY --from=doxygen /opt/doxygen/ /usr/local/

# Scientific -------------------------------------------------------------------

FROM compat-build-base as casadi

COPY install-casadi.sh .
RUN bash install-casadi.sh "/opt/casadi"

FROM compat-build-base as casadi-static

COPY install-casadi-static.sh .
RUN bash install-casadi-static.sh "/opt/casadi-static"

FROM compat-build-base as eigen

COPY install-eigen.sh .
RUN bash install-eigen.sh "/opt/eigen"

FROM compat-build-base as gtest

COPY install-gtest.sh .
RUN bash install-gtest.sh "/opt/gtest"

# Alpaqa -----------------------------------------------------------------------

# Full build with shared CasADi
FROM compat-build-base as alpaqa-build

COPY --from=eigen /opt/eigen/ /usr/local/
COPY --from=gtest /opt/gtest/ /usr/local/
COPY --from=casadi /opt/casadi/ /usr/local/
USER root
RUN ldconfig
USER develop

# Full build with static CasADi
FROM compat-build-base as alpaqa-build-static

COPY --from=eigen /opt/eigen/ /usr/local/
COPY --from=gtest /opt/gtest/ /usr/local/
COPY --from=casadi-static /opt/casadi-static/ /usr/local/
USER root
RUN ldconfig
USER develop

# Python build
FROM alpaqa-build-static as alpaqa-python-build

COPY --from=python /opt/python/ /usr/local/
USER root
RUN ldconfig
USER develop

# Documentation with basic dependencies (no CasADi)
FROM docs as alpaqa-docs

COPY --from=eigen /opt/eigen/ /usr/local/
COPY --from=gtest /opt/gtest/ /usr/local/
COPY --from=casadi-static /opt/casadi-static/ /usr/local/
COPY --from=python /opt/python/ /usr/local/
RUN ldconfig

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
