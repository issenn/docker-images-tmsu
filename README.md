# TMSU Docker

Build TMSU from source and use it from a docker container.

## Quick start

#### Build

```sh
git clone git@github.com:issenn/docker-images-tmsu.git
cd docker-images-tmsu/0.7/buster && \
    docker build \
        --build-arg HTTP_PROXY="socks5://10.0.0.131:10808" \
        --build-arg HTTPS_PROXY="socks5://10.0.0.131:10808" \
        -t tmsu:0.7.5-buster .
```

#### Alias

```sh
alias tmsu-docker='docker run \
                  -it \
                  --device /dev/fuse \
                  --cap-add SYS_ADMIN \
                  --security-opt apparmor:unconfined \
                  -v $(pwd):/working tmsu:0.7.5-buster \
                  /bin/zsh'
```

#### Start

`tmsu-docker`

## Usage

#### Build any version of TMSU.

`make build TMSU_VERSION=$VERSION`

#### Enter the tmsu-docker container.

```sh
docker run \
-it \
--device /dev/fuse \
--cap-add SYS_ADMIN \
--security-opt apparmor:unconfined \
-v $(pwd):/working tmsu:$VERSION-buster \
/bin/zsh
```

The options device, cap-add, and security-opt are to make docker work with FUSE, which enables `tmsu mount`.

#### TMSU quick tour

https://tmsu.org/
