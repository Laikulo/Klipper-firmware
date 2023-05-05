ARG build_version=main
FROM ghcr.io/laikulo/klipper-firmware/build:${build_version}
ARG canboot_repo="https://github.com/Arksine/CanBoot.git" canboot_ref="master"
RUN mkdir canboot dist && \
    cd canboot && \
    git init && \
    git fetch --depth 1 "${canboot_repo}" "${canboot_ref}" && \
    git checkout FETCH_HEAD
ENV CANBOOT_DIR="/home/builder/canboot"
ADD cannery.sh /home/builder/scripts
ENTRYPOINT [ "/home/builder/scripts/cannery.sh" ]

