FROM alpine:latest

MAINTAINER yangliu

RUN apk update && \
  apk --no-cache upgrade && \
  apk --no-cache add libsodium git python && \
  cd ~ && \
  git clone -b akkariiin/dev https://github.com/shadowsocksrr/shadowsocksr.git && \
  mkdir -p /etc/shadowsocksr

VOLUME ["/etc/shadowsocksr"]

EXPOSE $SSR_SERVER_PORT

CMD python /root/shadowsocksr/shadowsocks/server.py -c /etc/shadowsocksr/config.json
