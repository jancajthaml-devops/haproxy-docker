Compact HA-Proxy container ( 25.94MB / 10MB compressed )

## Stack

Build from source of [HA-Proxy](http://www.haproxy.org/download) running on top of lightweight [Alphine Linux](https://alpinelinux.org) with services managed by [S6](http://git.skarnet.org/cgi-bin/cgit.cgi/s6/about/) suite.

## Usage

public image from dockerHub `docker pull jancajthaml/haproxy` and provide reference to haproxy.conf file via
volume configuration e.g. `./ha-proxy.conf:/etc/haproxy/haproxy.conf`
