FROM opensuse/tumbleweed:latest
ARG gcc_version=11 python_version=39
RUN zypper -n ar -C "obs://home:Laikulo:cross-pru" cross-pru && \
    zypper --gpg-auto-import-keys ref && \
    zypper -n in tar gzip git shadow \
        make gcc${gcc_version} gcc${gcc_version}-c++ cpp${gcc_version} \
        python${python_version} python${python_version}-curses \
        cross-avr-binutils cross-avr-gcc${gcc_version} avr-libc \
        cross-pru-binutils cross-pru-gcc${gcc_version} cross-pru-newlib-devel gnuprumcu \
        cross-arm-none-gcc${gcc_version} cross-arm-none-newlib-devel && \
    alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 309 && \
    alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 11 && \
    alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 11 && \
    alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-11 11 && \
    curl -L "https://more.musl.cc/11/x86_64-linux-musl/or1k-linux-musl-cross.tgz" | tar -xz -C /opt
ENV PATH=${PATH}:/opt/or1k-linux-musl-cross/bin/
RUN useradd -m builder
USER builder
ADD scripts/ /home/builder/scripts/
WORKDIR /home/builder
