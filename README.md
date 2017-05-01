Compact HA-Proxy container ( 13.9MB / 7 MB compressed )

## Stack

Build from source of [HA-Proxy](http://www.haproxy.org/download) running on top of lightweight [Alphine Linux](https://alpinelinux.org).

## Usage

```
docker run --rm -it --log-driver none jancajthaml/haproxy:latest haproxy \
       -f /etc/haproxy/haproxy.conf \
       -v ./ha-proxy.conf:/etc/haproxy/haproxy.conf
```
