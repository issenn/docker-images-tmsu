ARG BASE_IMAGE=golang:1.15.15-buster

FROM ${BASE_IMAGE} AS build-stage

ARG VERSION=0.7.5

# install related dependencies
RUN set -eux; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
            g++ \
            gcc \
            make \
            pkg-config \
            fuse \
            git \
        ; \
        rm -rf /var/lib/apt/lists/*; \
        sync

RUN go get -u github.com/mattn/go-sqlite3 && \
    go get -u github.com/hanwen/go-fuse/fuse && \
    # go get -u github.com/hanwen/go-fuse/v2/fs && \
    go get -u golang.org/x/crypto/blake2b

RUN git clone -b v${VERSION} https://github.com/oniony/TMSU.git /TMSU

WORKDIR /TMSU

RUN make && make install


FROM debian:buster AS prod

# Container variables
ENV \
  TERM="xterm" \
  # LANG=C.UTF-8 \
  LANG="en_US.UTF-8" \
  # LANGUAGE=C.UTF-8 \
  LANGUAGE="en_US.UTF-8" \
  # LC_ALL=C.UTF-8 \
  LC_ALL="en_US.UTF-8" \
  TIMEZONE="Asia/Shanghai"

RUN set -eux; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
            zsh \
            fuse \
        ; \
        rm -rf /var/lib/apt/lists/*; \
        chsh -s $(which zsh); \
        sync

COPY --from=build-stage /TMSU/bin/tmsu /usr/bin/
COPY --from=build-stage /TMSU/misc/bin/mount.tmsu /usr/sbin/
COPY --from=build-stage /TMSU/misc/bin/tmsu-* /usr/bin/
COPY --from=build-stage /usr/share/man/man1/tmsu.1.gz /usr/share/man/man1/
COPY --from=build-stage /TMSU/misc/zsh/_tmsu /usr/share/zsh/site-functions/

WORKDIR /TMSU
