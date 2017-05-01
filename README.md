Compact HA-Proxy container ( 13.9MB / 7 MB compressed )

## Stack

Build from source of [HA-Proxy](http://www.haproxy.org/download) running on top of lightweight [Alphine Linux](https://alpinelinux.org).

## Usage

```
docker run --rm -it --log-driver none \
       -p 8080:8080 \
       -p 7000:7000 \
       -v $$(pwd)/example/haproxy.conf:/etc/haproxy/haproxy.conf \
       jancajthaml/haproxy:latest haproxy -f /etc/haproxy/haproxy.conf
```
