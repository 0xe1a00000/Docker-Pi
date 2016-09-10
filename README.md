# OSX-RPI-ARM
Cross Compiling for an **emulated** Raspberry Pi using Docker on OS X.

### Docker

Download and install [Docker for Mac](https://www.docker.com/products/docker#/mac).

```sh
$ shasum -a 256 Docker.dmg
c6ec6c637efa347427e86168c8d963deb5770b1d67a99f64096c1554b635bd8b
```

Determine version of docker engine.

```sh
$ docker --version
Docker version 1.12.0, build 8eab29e # Stable version
```

Pull Raspberry Pi base image (Jessie).

```sh
$ docker pull resin/rpi-raspbian:jessie
```

Verify Raspbian Jessie:

```sh
$ docker run --rm -i -t resin/rpi-raspbian:jessie uname -a
Linux 44b8100ce292 4.4.15-moby #1 SMP Thu Jul 28 22:03:07 UTC 2016 armv7l GNU/Linux
```
### Cross Compile Tools

Install **Homebrew** (if not yet done).

```sh
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```



