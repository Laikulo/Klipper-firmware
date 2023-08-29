ARG build_version=main
FROM ghcr.io/laikulo/klipper-firmware/build:${build_version}
ARG katapult_repo="https://github.com/Arksine/Katapult.git" katapult_ref="master"
RUN mkdir katapult dist && \
    cd katapult && \
    git init && \
    git fetch --depth 1 "${katapult_repo}" "${katapult_ref}" && \
    git checkout FETCH_HEAD
ENV KATAPULT_DIR="/home/builder/katapult"
ADD cannery.sh /home/builder/scripts
ENTRYPOINT [ "/home/builder/scripts/cannery.sh" ]

