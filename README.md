# Docker-Pi
Cross Compiling for an **emulated** Raspberry Pi using Docker on OS X.

### Docker

Download and install [Docker for Mac](https://www.docker.com/products/docker#/mac).

```
$ shasum -a 256 Docker.dmg
c6ec6c637efa347427e86168c8d963deb5770b1d67a99f64096c1554b635bd8b
```

Determine version of docker engine.

```
$ docker --version
Docker version 1.12.0, build 8eab29e # Stable version.
```

Pull Raspberry Pi Wheezy image (Jessie will also work).

```
$ docker pull resin/rpi-raspbian:wheezy
```

List Docker images:

```
$ docker images
REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
resin/rpi-raspbian   wheezy              991a10be15c3        2 days ago          84.5 MB
```

Verify Raspbian Wheezy:

```
$ docker run -p 19484:19484 -it resin/rpi-raspbian:wheezy /bin/bash # This also creates a persistent container ID.
$ uname -a
Linux 5f62767eaeb9 4.4.15-moby #1 SMP Thu Jul 28 22:03:07 UTC 2016 armv7l GNU/Linux
$ exit
```

**Note:**

We need to use port forwarding (-p 19484:19484) in order to connect from a OS X host machine to a docker container thats because [Docker for Mac does not provide a docker0 interface](https://github.com/docker/docker/issues/22753).

### Cross Compile Tools

Install **Homebrew** (if not yet done).

```
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install the GNU ARM Embedded Toolchain.

```
$ brew tap PX4/homebrew-px4
$ brew search gcc-arm-none # Seach for available toolchains.
$ brew install gcc-arm-none-eabi-54 # Pick your preferred toolchain.
```

### Cross Compiling (Hello World from Docker)

**ARM Example**

Download [Hello Docker ARM](https://raw.githubusercontent.com/b2bSec/OSX-RPI-ARM/master/hello_docker_arm.s).

Assemble and link.

```
$ arm-none-eabi-as -o hello_docker_arm.o hello_docker_arm.s
$ arm-none-eabi-ld -o hello_docker_arm hello_docker_arm.o
$ file hello_docker_arm
hello_docker_arm: ELF 32-bit LSB executable, ARM, version 1 (SYSV), statically linked, not stripped
```

Copy executable into docker container.

```
$ docker ps -aq # Get container ID.
b51bd10d3fe6
$ docker cp hello_docker_arm b51bd10d3fe6:/root
```

Run executable:

```
$ docker start b51bd10d3fe6
$ docker exec b51bd10d3fe6 /root/hello_docker_arm
___ARM: Hello World from Docker___
```

**C Example**

Download [Hello Docker C](https://raw.githubusercontent.com/b2bSec/OSX-RPI-ARM/master/hello_docker_c.c).

Compile, assemble, and Link.

```
$ arm-none-eabi-gcc --specs=rdimon.specs -lgcc -lc -lm -lrdimon -o hello_docker_c hello_docker_c.c
```

Copy executable into docker container.

```
$ docker cp hello_docker_c b51bd10d3fe6:/root
```

Run executable:

```
$ docker start b51bd10d3fe6 # If not already started.
$ docker exec b51bd10d3fe6 /root/hello_docker_c
___C: Hello World from Docker___
```

### Cross Debugging

Build executables with debug symbols enabled.

```
$ arm-none-eabi-as -g -o hello_docker_arm.o hello_docker_arm.s
$ arm-none-eabi-ld -o hello_docker_arm hello_docker_arm.o
$ arm-none-eabi-gcc -ggdb -c hello_docker_c.c
$ arm-none-eabi-gcc --specs=rdimon.specs -lgcc -lc -lm -lrdimon -o hello_docker_c hello_docker_c.o
```

Copy executables into docker container.

```
$ docker cp hello_docker_arm b51bd10d3fe6:/root
$ docker cp hello_docker_c b51bd10d3fe6:/root
```

**Note:**

We cannot effectively use **gdbserver** since QEMU does not support the ptrace(2) syscall.
Therefore we need to use QEMUs GDB-stub.

Run executable using QEMUs GDB-stub.

```
$ docker start b51bd10d3fe6 # If not already started.
$ docker attach b51bd10d3fe6 # Attach to container (interactive-mode).
$ qemu-arm-static -g 19484 /root/hello_docker_arm
```

Run cross debugger on host machine.

```
$ arm-none-eabi-gdb -q
gdb$ file hello_docker_arm # Load debug symbols.
gdb$ target remote localhost:19484 # Establish connection with QEMUs GDB-stub.
```

The process is the same for the C example.

### Credits

Rud Merriam, [hackaday.com](http://hackaday.com/2016/02/03/code-craft-cross-compiling-for-the-raspberry-pi/)

