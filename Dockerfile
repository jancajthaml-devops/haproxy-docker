FROM alpine:latest

MAINTAINER Jan Cajthaml <jan.cajthaml@gmail.com>

ENV     HAPROXY_MAJOR=1.6 \
        HAPROXY_VERSION=1.6.3

COPY etc /etc

RUN addgroup -S haproxy && \
    adduser -D -S -h /var/cache/haproxy -s /sbin/nologin -G haproxy haproxy && \
    apk add --update libcap && \
    set -x \
    && apk add --no-cache --virtual .build-deps \
        curl \
        gcc \
        libc-dev \
        linux-headers \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev && \
    curl -SL "http://www.haproxy.org/download/${HAPROXY_MAJOR}/src/haproxy-${HAPROXY_VERSION}.tar.gz" -o haproxy.tar.gz && \
    tar -xzf haproxy.tar.gz -C /tmp && \
    make -j$(getconf _NPROCESSORS_ONLN) -C /tmp/haproxy-${HAPROXY_VERSION} \
                                            TARGET=linux2628 \
                                            USE_PCRE=1 PCREDIR= \
                                            USE_OPENSSL=1 \
                                            USE_ZLIB=1 \
                                            all \
                                            install-bin && \
    rm -rf /tmp/haproxy-${HAPROXY_VERSION} && \
    rm haproxy.tar.gz && \
    runDeps="$( \
        scanelf --needed --nobanner --recursive /usr/local \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" && \
    apk add --virtual .haproxy-rundeps $runDeps && \
    apk del .build-deps

USER haproxy

STOPSIGNAL SIGQUIT

CMD ["haproxy", "-f", "/etc/haproxy/haproxy.conf"]
