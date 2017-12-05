FROM alpine:3.6
LABEL maintainer "ymajik <ymajik@gmail.com"

ENV GRAFANA_VERSION=4.6.2
ENV GLIBC_VERSION=2.26-r0
ENV GOSU_VERSION=1.10

RUN set -ex &&\
  addgroup -S grafana &&\
  adduser -S -G grafana grafana &&\
  apk add --no-cache ca-certificates openssl fontconfig bash &&\
  apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community dumb-init &&\
  wget -q -O /usr/sbin/gosu https://github.com/tianon/gosu/releases/download/"$GOSU_VERSION"/gosu-amd64 &&\
  chmod +x /usr/sbin/gosu  &&\
  wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub &&\
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/"$GLIBC_VERSION"/glibc-"$GLIBC_VERSION".apk &&\
  apk add glibc-"$GLIBC_VERSION".apk &&\
  wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-"$GRAFANA_VERSION".linux-x64.tar.gz &&\
  tar -xzf grafana-"$GRAFANA_VERSION".linux-x64.tar.gz &&\
  mv grafana-"$GRAFANA_VERSION"/ grafana/ &&\
  mv grafana/bin/* /usr/local/bin/ &&\
  mkdir -p /grafana/{dashboards,data,logs,plugins} &&\
  mkdir /var/lib/grafana/ &&\
  ln -s /grafana/plugins /var/lib/grafana/plugins &&\
  grafana-cli plugins update-all &&\
  rm -f grafana/conf/*.ini &&\
  rm grafana-"$GRAFANA_VERSION".linux-x64.tar.gz /etc/apk/keys/sgerrand.rsa.pub glibc-"$GLIBC_VERSION".apk &&\
  chown -R grafana:grafana /grafana &&\
  rm -rf /var/cache/apk/*

VOLUME  ["/grafana"]
COPY ./config/defaults.ini /grafana/conf/
COPY ./run.sh /run.sh

EXPOSE 3000

ENTRYPOINT ["/run.sh"]
