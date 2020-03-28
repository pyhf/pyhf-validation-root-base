ARG BASE_IMAGE=atlasamglab/stats-base:root6.20.00-python3.7
FROM ${BASE_IMAGE} as base

RUN apt-get -qq -y update && \
    apt-get -qq -y install --no-install-recommends \
      curl \
      git && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt-get/lists/*

WORKDIR /home/data
ENV HOME /home

ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["/bin/bash"]
