FROM alpine:latest

ARG VERSION=0.100.1-r0

RUN apk update && \
  apk add bash \
  clamav=${VERSION}

RUN mkdir /run/clamav
RUN chown -R clamav:clamav /run/clamav

RUN chmod 700 /etc/clamav/freshclam.conf

COPY mdg-clamav.sh /mdg-clamav.sh
RUN chmod +x /mdg-clamav.sh

WORKDIR /
CMD ./mdg-clamav.sh
