FROM alpine:latest

ARG VERSION=0.100.1-r0

RUN apk update && \
  apk add bash \
  clamav=${VERSION}

RUN mkdir /run/clamav
RUN chown -R clamav:clamav /run/clamav

RUN chmod 700 /etc/clamav/freshclam.conf

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

WORKDIR /
CMD ./startup.sh
