FROM golang:1.17.2-buster as builder

# Container variables
# ENV \
#   TERM="xterm" \
#   # LANG=C.UTF-8 \
#   LANG="en_US.UTF-8" \
#   # LANGUAGE=C.UTF-8 \
#   LANGUAGE="en_US.UTF-8" \
#   # LC_ALL=C.UTF-8 \
#   LC_ALL="en_US.UTF-8" \
#   TIMEZONE="Asia/Shanghai"

# install related dependencies
RUN set -eux; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
            fuse \
            git \
        ; \
        rm -rf /var/lib/apt/lists/*; \
        sync

ENV GOPATH \$HOME/go

RUN go env -w GOPATH=\$HOME/go && \
    go get -u github.com/mattn/go-sqlite3 && \
    go get -u github.com/hanwen/go-fuse/fs && \
    go get -u golang.org/x/crypto/blake2b


RUN git clone -b v0.75 https://github.com/oniony/TMSU.git /TMSU

WORKDIR /TMSU

RUN mkdir -p bin; \
    go build -o bin/tmsu github.com/oniony/TMSU

RUN go test github.com/oniony/TMSU/...; \
    cd tests && ./runall

# RUN make && make install
