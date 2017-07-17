# Docker-Pi
Cross Compiling for an **emulated** Raspberry Pi using Docker on macOS.

### Docker

Download and install [Docker for Mac](https://store.docker.com/editions/community/docker-ce-desktop-mac).

Determine version of docker engine.

```
$ docker version
Client:
 Version:      17.06.0-ce
 API version:  1.30
 Go version:   go1.8.3
 Git commit:   02c1d87
 Built:        Fri Jun 23 21:31:53 2017
 OS/Arch:      darwin/amd64

Server:
 Version:      17.06.0-ce
 API version:  1.30 (minimum version 1.12)
 Go version:   go1.8.3
 Git commit:   02c1d87
 Built:        Fri Jun 23 21:51:55 2017
 OS/Arch:      linux/amd64
 Experimental: true
```

Pull Raspberry Pi Wheezy image (Jessie will also work).

```
$ docker pull resin/rpi-raspbian:wheezy
```

List Docker images:

```
$ docker images
REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
resin/rpi-raspbian   wheezy              a07e757f18d5        2 weeks ago         92.9MB
```

Verify Raspbian Wheezy:

```
$ docker run -p 19484:19484 -it resin/rpi-raspbian:wheezy /bin/bash # This also creates a persistent container ID.
$ uname -a
Linux 77d4ea6bebc5 4.9.36-moby #1 SMP Wed Jul 12 15:29:07 UTC 2017 armv6l GNU/Linux
```

**Note:**

We need to use port forwarding (-p 19484:19484) in order to connect from a macOS host machine to a docker container thats because [Docker for Mac does not provide a docker0 interface](https://github.com/docker/docker/issues/22753).

### Cross Compile Tools

Install **Homebrew** (if not yet done).

```
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install the GNU ARM Embedded Toolchain.

```
$ brew tap PX4/homebrew-px4
$ brew search gcc-arm-none # Seach for available toolchains.
$ brew install gcc-arm-none-eabi-63 # Pick your preferred toolchain.
```

### Cross Compiling (Hello World from Docker)

**ARM Example**

Download [Hello Docker ARM](https://raw.githubusercontent.com/b2bSec/OSX-RPI-ARM/master/hello_docker_arm.s).

Assemble and link.

```
$ arm-none-eabi-as -o hello_docker_arm.o hello_docker_arm.s
$ arm-none-eabi-ld -o hello_docker_arm hello_docker_arm.o
$ file hello_docker_arm
hello_docker_arm: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, not stripped
```

Copy executable into docker container.

```
$ docker ps -aq # Get container ID.
77d4ea6bebc5
$ docker cp hello_docker_arm 77d4ea6bebc5:/root
```

Run executable:

```
$ docker start 77d4ea6bebc5
$ docker exec 77d4ea6bebc5 /root/hello_docker_arm
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
$ docker cp hello_docker_c 77d4ea6bebc5:/root
```

Run executable:

```
$ docker start 77d4ea6bebc5 # If not already started.
$ docker exec 77d4ea6bebc5 /root/hello_docker_c
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
$ docker cp hello_docker_arm 77d4ea6bebc5:/root
$ docker cp hello_docker_c 77d4ea6bebc5:/root
```

**Note:**

We cannot effectively use **gdbserver** since QEMU does not support the ptrace(2) syscall.
Therefore we need to use QEMUs GDB-stub.

Run executable using QEMUs GDB-stub.

```
$ docker start 77d4ea6bebc5 # If not already started.
$ docker attach 77d4ea6bebc5 # Attach to container (interactive-mode).
$ qemu-arm-static -g 19484 /root/hello_docker_arm
```

Run cross debugger on host machine.

```
$ arm-none-eabi-gdb -q
gdb$ file hello_docker_arm # Load debug symbols.
gdb$ target remote localhost:19484 # Establish connection with QEMUs GDB-stub.
Remote debugging using localhost:19484
_write () at hello_docker_arm.s:7
7	mov r7, #4
(gdb)
```

The process is the same for the C example.

### Credits

Rud Merriam, [hackaday.com](http://hackaday.com/2016/02/03/code-craft-cross-compiling-for-the-raspberry-pi/)

