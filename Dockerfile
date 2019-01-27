FROM ubuntu:bionic

ENV TZ=America/Chicago
RUN    ln --symbolic --no-dereference --force /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

RUN    echo "deb https://dl.bintray.com/sbt/debian /" >> /etc/apt/sources.list.d/sbt.list                    \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823

RUN apt update && apt upgrade --yes
RUN apt install --yes                                                        \
        autoconf bison build-essential clang++-6.0 clang-6.0 cmake coreutils \
        diffutils flex gcc git libboost-test-dev libffi-dev libgmp-dev       \
        libjemalloc-dev libmpfr-dev libstdc++6 libtool libxml2               \
        libyaml-cpp-dev llvm-6.0 m4 make maven opam openjdk-8-jdk pandoc     \
        pkg-config python3 python-jinja2 python-pygments python-recommonmark \
        python-sphinx sbt scala time unifdef zlib1g-dev

RUN curl -sSL https://get.haskellstack.org/ | sh

RUN cpan install App::FatPacker Getopt::Declare String::Escape String::ShellQuote UUID::Tiny

RUN    git clone 'https://github.com/z3prover/z3' --branch=z3-4.8.4 \
    && cd z3                     \
    && python scripts/mk_make.py \
    && cd build                  \
    && make -j8                  \
    && make install              \
    && cd ../..                  \
    && rm -rf z3

ARG USER_ID=1000
ARG GROUP_ID=1000
RUN    groupadd --gid $GROUP_ID user \
    && useradd --create-home --uid $USER_ID --shell /bin/sh --gid user user

USER $USER_ID:$GROUP_ID
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain 1.28.0

RUN    cd /home/user                                                          \
    && git clone 'https://github.com/kframework/k' --branch=nightly-0f3835d3a \
    && ./k/k-distribution/src/main/scripts/bin/k-configure-opam-dev           \
    && rm -rf k

RUN    cd /home/user                                                             \
    && git clone 'https://github.com/input-output-hk/sbt-verify' --branch=v0.4.1 \
    && cd sbt-verify                                                             \
    && sbt publishLocal                                                          \
    && cd ../                                                                    \
    && rm -rf sbt-verify