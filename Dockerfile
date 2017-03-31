FROM alpine:latest

MAINTAINER Jan Cajthaml <jan.cajthaml@gmail.com>

ENV S6_OVERLAY_VERSION v1.18.1.5
ENV GODNSMASQ_VERSION 1.0.7

ENV HAPROXY_MAJOR 1.6
ENV HAPROXY_VERSION 1.6.3

RUN addgroup -S balancer && \
    adduser -S -G balancer balancer

RUN apk add --update libcap

RUN set -x \
    && apk add --no-cache --virtual .build-deps \
        curl \
        gcc \
        libc-dev \
        linux-headers \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev

RUN curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz \
    | tar xvfz - -C / && \
    curl -sSL https://github.com/janeczku/go-dnsmasq/releases/download/${GODNSMASQ_VERSION}/go-dnsmasq-min_linux-amd64 -o /bin/go-dnsmasq && \
    addgroup go-dnsmasq &&     adduser -D -g "" -s /bin/sh -G go-dnsmasq go-dnsmasq &&     setcap CAP_NET_BIND_SERVICE=+eip /bin/go-dnsmasq


RUN set -x \
    && curl -SL "http://www.haproxy.org/download/${HAPROXY_MAJOR}/src/haproxy-${HAPROXY_VERSION}.tar.gz" -o haproxy.tar.gz \
    && tar -xzf haproxy.tar.gz -C /tmp \
    && mv "/tmp/haproxy-$HAPROXY_VERSION" /tmp/haproxy \
    && rm haproxy.tar.gz

RUN cd /tmp/haproxy \
    && make -C /tmp/haproxy \
        TARGET=linux2628 \
        USE_PCRE=1 PCREDIR= \
        USE_OPENSSL=1 \
        USE_ZLIB=1 \
        all \
        install-bin \
    && rm -rf /tmp/haproxy

RUN runDeps="$( \
        scanelf --needed --nobanner --recursive /usr/local \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --virtual .haproxy-rundeps $runDeps \
    && apk del .build-deps

RUN apk info

# Add the files
ADD etc /etc
ADD usr /usr

ENTRYPOINT ["/init"]
CMD []
