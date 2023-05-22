# tftpd-hpa (tftpd)

**A lightweight tftp-server (tftpd-hpa)**

⚠️ This container is used for the TrueNAS SCALE app `tftpd-hpa`. ⚠️

⚠️ While it should work, it's not intended to be used as a standalone container. ⚠️

`GitHub` - truenas/containers - https://github.com/truenas/containers/tree/master/apps/tftpd-hpa

## Index

1. [Usage](#1-usage)
  1.1 [docker run](#11-docker-run)
2. [Environment Variables](#2-environment-variables)
3. [Volumes](#3-volumes)
4. [Ports](#4-ports)

## 1 Usage

### 1.1 docker run

**Example 1 - run without arguments (environment variables will be used):**
**This is the recommended way to use this container !!!**

```shell
docker run -d \
    --name tftpd-hpa \
    -e TZ="Europe/Berlin" \
    -v /path/of/some/files:/tftpboot \
    -p 69:69/udp \
    truenas/tftpd-hpa:latest
```

**Example 2 - run with specified environment variables:**
**CREATE=1: allow uploads, even if file doesn't exist**
**MAPFILE="": do not use the mapfile**

```shell
docker run -d \
    --name tftpd-hpa \
    -e TZ="Europe/Berlin" \
    -e CREATE=1 \
    -e MAPFILE="" \
    -v /path/of/some/files:/tftpboot \
    -p 69:69/udp \
    truenas/tftpd-hpa:latest
```

**Example 3 - run with arguments (environment variables will be ignored):**
**in.tftpd --foreground --address 0.0.0.0:69 --user tftp <your arguments>**

```shell
docker run -d \
    --name tftpd-hpa \
    -e TZ="Europe/Berlin" \
    -v /path/of/some/files:/tftpboot \
    -p 69:69/udp \
    truenas/tftpd-hpa:latest \
    --create --secure --verbose /tftpboot
```

**Example 4 - run with arguments with optional 'in.tftpd' as first argument:**
**in.tftpd --foreground --address 0.0.0.0:69 --user tftp <your arguments>**

```shell
docker run -d \
    --name tftpd-hpa \
    -e TZ="Europe/Berlin" \
    -v /path/of/some/files:/tftpboot \
    -p 69:69/udp \
    truenas/tftpd-hpa:latest \
    in.tftpd --create --secure --verbose /tftpboot
```

**Example 5 - run without arguments and custom MAPFILE:**
**you need to VOLUME your MAPFILE**

```shell
docker run -d \
    --name tftpd-hpa \
    -e TZ="Europe/Berlin" \
    -e MAPFILE=/mapfile \
    -v /path/of/some/files:/tftpboot \
    -v /path/of/your/mapfile:/mapfile \
    -p 69:69/udp \
    truenas/tftpd-hpa:latest
```

### 2 Environment Variables

For more information, see [tftpd-hpa man pages](https://manpages.debian.org/testing/tftpd-hpa/tftpd.8.en.html)

- `TZ` - Specifies the server timezone - **Default: `UTC`**
- `BLOCKSIZE` - Specifies the maximum permitted block size
- `CREATE` - Allow new files to be created - **Default: `0`** (only upload files, if they already exist)
- `MAPFILE` - Specify the use of filename remapping - **Default: `""`**
  (leave empty, if you don't want to use a mapfile)
- `PERMISSIVE` - Perform no additional permissions checks - **Default: `0`**
- `PORTRANGE` - Force the server port number (the Transaction ID) to be in the specified range of port numbers - **Default: `4096:32760`**
- `REFUSE` - Indicate that a specific RFC 2347 TFTP option should never be accepted
- `RETRANSMIT` - Determine the default timeout, in microseconds, before the first packet is retransmitted - **Default: `""`**
- `SECURE` - Change root directory on startup - **Default: `1`**
- `TIMEOUT` - This specifies how long, in seconds, to wait for a second connection before terminating the server - **Default: `""`**
- `UMASK` - Sets the umask for newly created files
- `VERBOSE` - Increase the logging verbosity of tftpd - **Default: `1`**
- `VERBOSITY` - Set the verbosity value from 0 to 4 - **Default: `3`**

### 3 Volumes

- `/tftpboot` - tftp root directory ->
  **your directory needs to be at least 0555 (dr-xr-xr-x), owned by root or uid=9069, gid=9069** or **0757** when `CREATE=1`
- `/mapfile` - mapfile for tftpd-hpa -> your mapfile needs to be at least 0444 (-r--r--r--), owned by root or uid=9069, gid=9069

### 4 Ports

- `69/udp` - TFTP Port
