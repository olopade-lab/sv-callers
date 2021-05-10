FROM ubuntu:16.04

ARG MANTA_VERSION=1.1.0

RUN apt-get update && \
    apt-get install -y bzip2 gcc g++ make python zlib1g-dev wget && \
    cd /usr/local/bin && \
    wget https://github.com/Illumina/manta/releases/download/v${MANTA_VERSION}/manta-${MANTA_VERSION}.release_src.tar.bz2 && \
    tar -xjf /usr/local/bin/manta-${MANTA_VERSION}.release_src.tar.bz2 && \
    sed -i 's/MAX_QSCORE = 70/MAX_QSCORE = 71/' /usr/local/bin/manta-${MANTA_VERSION}.release_src/src/c++/lib/blt_util/qscore_cache.hh && \
    mkdir /usr/local/bin/manta-${MANTA_VERSION}.release_src/build && cd /usr/local/bin/manta-${MANTA_VERSION}.release_src/build && \
    mkdir -r /usr/local/bin/manta/bin && \
    ../configure --jobs=4 --prefix=/usr/local/bin/manta && \
    make install

WORKDIR /usr/local/bin/manta/bin