ARG build_version=main
FROM ghcr.io/laikulo/klipper-firmware/build:${build_version}
ARG klipper_repo="https://github.com/klipper3d/klipper.git" klipper_ref="master"
RUN git clone --depth 1 --branch "${klipper_ref}" "${klipper_repo}" klipper
ENV KLIPPER_DIR="/home/builder/klipper"
ADD factory.sh /home/builder/klipper/scripts/
ENTRYPOINT [ "/home/builder/klipper/scripts/factory.sh" ]

