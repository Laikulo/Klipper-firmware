ARG build_version=main
FROM ghcr.io/laikulo/klipper-firmware/build:${build_version}
ARG klipper_repo="https://github.com/klipper3d/klipper.git" klipper_ref="master"
RUN mkdir klipper dist && \
    cd klipper && \
    git init && \
    git fetch --depth 1 "${klipper_repo}" "${klipper_ref}" && \
    git checkout FETCH_HEAD
ENV KLIPPER_DIR="/home/builder/klipper"
ADD factory.sh /home/builder/scripts/
ENTRYPOINT [ "/home/builder/scripts/factory.sh" ]

