FROM casjaysdevdocker/debian:latest AS build

ARG DEBIAN_VERSION="bullseye"

ARG DEFAULT_DATA_DIR="/home/x11user/.local/share/torbrowser/Browser/TorBrowser/Data/Browser" \
  DEFAULT_CONF_DIR="/usr/local/share/template-files/config" \
  DEFAULT_TEMPLATE_DIR="/usr/local/share/template-files/defaults"

ENV LANG=en_US.utf8 \
  TZ="America/New_York" \
  SHELL="/bin/bash" \
  TERM="xterm-256color" \
  DEBIAN_FRONTEND="noninteractive" \
  TOR_BROWSER_VERSION="11.5.4"

RUN set -ex; \
  rm -Rf "/etc/apt/sources.list" ; \
  mkdir -p "${DEFAULT_DATA_DIR}" "${DEFAULT_CONF_DIR}" "${DEFAULT_TEMPLATE_DIR}" "/etc/sudoers.d" "/tmp/tor-profile"; \
  echo 'export DEBIAN_FRONTEND="noninteractive"' >"/etc/profile.d/apt.sh" && chmod 755 "/etc/profile.d/apt.sh" && \
  echo "deb http://deb.debian.org/debian ${DEBIAN_VERSION} main contrib non-free" >>"/etc/apt/sources.list" ; \
  echo "deb http://deb.debian.org/debian ${DEBIAN_VERSION}-updates main contrib non-free" >>"/etc/apt/sources.list" ; \
  echo "deb http://deb.debian.org/debian-security/ ${DEBIAN_VERSION}-security main contrib non-free" >>"/etc/apt/sources.list" ; \
  apt-get update -yy && apt-get upgrade -yy && apt-get install -yy \
  bash \
  sudo \
  tini \
  x11-apps \
  xz-utils \
  iproute2 \
  firefox-esr && \
  apt-get remove firefox-esr -yy && \
  useradd --shell /bin/bash --create-home --home-dir /home/x11user x11user && \
  usermod -a -G audio,video x11user && \
  echo "x11user ALL=(ALL) NOPASSWD: ALL" >"/etc/sudoers.d/x11user" && \
  apt-get clean ; \
  rm -rf /lib/systemd/system/multi-user.target.wants/* ; \
  rm -rf /etc/systemd/system/*.wants/* ; \
  rm -rf /lib/systemd/system/local-fs.target.wants/* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*udev* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*initctl* ; \
  rm -rf /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* ; \
  rm -rf /lib/systemd/system/systemd-update-utmp*

COPY ./bin/. /usr/local/bin/
COPY ./config/. ${DEFAULT_CONF_DIR}/
COPY ./data/. /tmp/tor-profile/

RUN install-tor-browser && \
  cp -Rf /tmp/tor-profile/tor/. ${DEFAULT_DATA_DIR}/ && \
  chown -Rf x11user:x11user "/home/x11user"

RUN echo 'Running cleanup' ; \
  update-alternatives --install /bin/sh sh /bin/bash 1 ; \
  rm -Rf /usr/share/doc/* /usr/share/info/* ; \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ; \
  rm -Rf /usr/local/bin/.gitkeep /config /data /var/lib/apt/lists/* ; \
  rm -rf /lib/systemd/system/multi-user.target.wants/* ; \
  rm -rf /etc/systemd/system/*.wants/* ; \
  rm -rf /lib/systemd/system/local-fs.target.wants/* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*udev* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*initctl* ; \
  rm -rf /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* ; \
  rm -rf /lib/systemd/system/systemd-update-utmp* ; \
  if [ -d "/lib/systemd/system/sysinit.target.wants" ]; then cd "/lib/systemd/system/sysinit.target.wants" && rm $(ls | grep -v systemd-tmpfiles-setup) ; fi

#FROM scratch

ARG PHP_SERVER="php" \
  NODE_VERSION="14" \
  NODE_MANAGER="system" \
  SERVICE_PORT="" \
  EXPOSE_PORTS="" \
  LICENSE="MIT" \
  IMAGE_NAME="tor-browser" \
  BUILD_VERSION="latest" \
  TIMEZONE="America/New_York" \
  BUILD_DATE="2022-10-15"

LABEL maintainer="CasjaysDev <docker-admin@casjaysdev.com>" \
  org.opencontainers.image.vendor="CasjaysDev" \
  org.opencontainers.image.authors="CasjaysDev" \
  org.opencontainers.image.vcs-type="Git" \
  org.opencontainers.image.name="${IMAGE_NAME}" \
  org.opencontainers.image.base.name="${IMAGE_NAME}" \
  org.opencontainers.image.license="${LICENSE}" \
  org.opencontainers.image.vcs-ref="${BUILD_VERSION}" \
  org.opencontainers.image.build-date="${BUILD_DATE}" \
  org.opencontainers.image.version="${BUILD_VERSION}" \
  org.opencontainers.image.schema-version="${BUILD_VERSION}" \
  org.opencontainers.image.url="https://hub.docker.com/r/casjaysdevdocker/${IMAGE_NAME}" \
  org.opencontainers.image.vcs-url="https://github.com/casjaysdevdocker/${IMAGE_NAME}" \
  org.opencontainers.image.url.source="https://github.com/casjaysdevdocker/${IMAGE_NAME}" \
  org.opencontainers.image.documentation="https://hub.docker.com/r/casjaysdevdocker/${IMAGE_NAME}" \
  org.opencontainers.image.description="Containerized version of ${IMAGE_NAME}"

ENV LANG=en_US.utf8 \
  ENV=~/.bashrc \
  SHELL="/bin/bash" \
  PORT="${SERVICE_PORT}" \
  TERM="xterm-256color" \
  PHP_SERVER="${PHP_SERVER}" \
  NODE_VERSION="${NODE_VERSION}" \
  NODE_MANAGER="${NODE_MANAGER}" \
  CONTAINER_NAME="${IMAGE_NAME}" \
  TZ="${TZ:-America/New_York}" \
  TIMEZONE="${TZ:-$TIMEZONE}" \
  HOSTNAME="casjaysdev-${IMAGE_NAME}" \
  USER="x11user"

#COPY --from=build /. /

USER x11user
WORKDIR /home/x11user

VOLUME [ "/tmp/.X11-unix", "${HOME}/.Xauthority", ]

EXPOSE $EXPOSE_PORTS

CMD [ "$@" ]
ENTRYPOINT [ "tini", "-p", "SIGTERM", "--", "/usr/local/bin/entrypoint-tor-browser.sh" ]
HEALTHCHECK --start-period=1m --interval=2m --timeout=3s CMD [ "/usr/local/bin/entrypoint-tor-browser.sh", "healthcheck" ]

