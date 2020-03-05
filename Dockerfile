ARG BASE_IMAGE=python:3.7-slim
FROM ${BASE_IMAGE} as base

SHELL [ "/bin/bash", "-c" ]

FROM base as builder

ARG ROOT_VERSION=6.20.00

# As this is builder can split up RUNs to make debugging easier
RUN apt-get -qq -y update && \
    apt-get -qq -y install \
      gcc \
      g++ \
      gfortran \
      git \
      wget \
      cmake \
      zlibc \
      libblas3 \
      zlib1g-dev \
      libbz2-dev \
      libx11-dev \
      libxext-dev \
      libxft-dev \
      libxml2-dev \
      libxpm-dev \
      libz-dev && \
    apt-get -y autoclean && \
    apt-get -y autoremove
# c.f. https://root.cern.ch/building-root#options
RUN mkdir code && \
    cd code && \
    wget https://root.cern/download/root_v${ROOT_VERSION}.source.tar.gz && \
    tar xvfz root_v${ROOT_VERSION}.source.tar.gz && \
    mkdir build && \
    cd build && \
    cmake \
      -Dcxx14=ON \
      -Dtmva=OFF \
      -Dpython=ON \
      -DPYTHON_EXECUTABLE=$(which python3) \
      -DPYTHON_INCLUDE_DIR=$(python3 -c "from distutils import sysconfig; print(sysconfig.get_python_inc(True))") \
      -DPYTHON_LIBRARY=$(python3 -c "from distutils import sysconfig; print(sysconfig.get_config_var('LIBDIR'))") \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      ../root-${ROOT_VERSION} && \
    cmake --build . -- -j$(($(nproc) - 1)) && \
    cmake --build . --target install

FROM base
RUN apt-get -qq -y update && \
    apt-get -qq -y install \
      gcc \
      g++ \
      zlibc \
      libblas3 \
      zlib1g-dev \
      libbz2-dev \
      libx11-dev \
      libxext-dev \
      libxft-dev \
      libxml2-dev \
      libxpm-dev \
      libz-dev && \
    apt-get -y autoclean && \
    apt-get -y autoremove
# Use C.UTF-8 locale to avoid issues with ASCII encoding
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV PYTHONPATH=/usr/local/lib:$PYTHONPATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/include /usr/local/include
COPY --from=builder /usr/local/share /usr/local/share
COPY --from=builder /usr/local/etc /usr/local/etc

WORKDIR /home/data
ENV HOME /home

ENTRYPOINT ["/bin/bash"]
