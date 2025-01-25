What is it?
===========

This project was created just for learning perl sockets, forking mechanics and OS signals.

This is NOT production-ready server, tool, utility, library or framework.

Requirements
------------

Before running this script please install:

- perl
- perl sockets library

Installation depends from OS.

Running
-------

```sh
perl server.pl
```

Stress test
------------

For testing this server recommended to use Apache Bench utility.
Install it, if it is not already installed.

```sh
# for Debian like systems
apt install -y apache2-utils
# for Alpine
apk add apache2-utils
# for RedHat like systems
yum install -y httpd-tools
```

Run server. Then run test:

```sh
ab -n 50000 -c 10 -s 120 http://127.0.0.1:5000/
```

Read about command line arguments to tune it for your own environment.
