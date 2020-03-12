ARG BASE_IMAGE=debian:stable-slim
FROM ${BASE_IMAGE} as base

FROM continuumio/miniconda3:latest as builder
ARG ROOT_VERSION=6.20.00
ARG PYTHON_VERSION=3.7

SHELL [ "/bin/bash", "-c" ]

# Add conda-forge and prevent files from being linked instead of copied
RUN conda config --add channels conda-forge && \
    conda config --set allow_softlinks false && \
    conda config --set always_copy true
RUN conda create --yes --quiet -p /opt/condaenv "root=$ROOT_VERSION" "python=$PYTHON_VERSION"
# Forcibly remove some packages to make the final image smaller
RUN eval "$(python -m conda shell.bash hook)" && \
    conda activate /opt/condaenv && \
    conda remove --yes --force-remove \
      pythia8 \
      qt \
      libllvm9 \
      libclang \
      pandoc
RUN rm -rf /opt/condaenv/tutorials /opt/condaenv/ui5

FROM base
COPY --from=builder /opt/condaenv /opt/condaenv
ENV PATH="/opt/condaenv/bin:$PATH"

# Use C.UTF-8 locale to avoid issues with ASCII encoding
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

WORKDIR /home/data
ENV HOME /home

ENTRYPOINT ["/bin/bash"]
