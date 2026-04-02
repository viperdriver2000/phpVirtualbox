# phpVirtualbox-docker

Docker container for [phpVirtualBox](http://sourceforge.net/projects/phpvirtualbox/) — a web interface to manage remote VirtualBox instances, compatible with VirtualBox 6.x.

Fork of [jazzdd86/phpVirtualbox](https://github.com/jazzdd86/phpVirtualbox) using the [pasha1st VB 6.x build](https://github.com/pasha1st/phpvirtualbox-6/).

> **Note:** This project is kept for reference. phpVirtualBox is largely unmaintained upstream.

## Quick Start

```bash
docker run -d \
  --name phpvirtualbox \
  -p 8080:80 \
  -e SRV1_HOSTPORT=192.168.1.10:18083 \
  -e SRV1_NAME=MyServer \
  -e SRV1_USER=vboxuser \
  -e SRV1_PW=secret \
  viperdriver2000/phpvirtualbox
```

Default login: **admin / admin** (phpVirtualBox built-in auth).

## Build

```bash
docker build -t phpvirtualbox .
```

## Environment Variables

### Server Configuration

Each VirtualBox server is configured via a set of prefixed environment variables. The prefix (`SRV1`, `SRV2`, etc.) groups the variables for one server.

| Variable | Required | Description |
|---|---|---|
| `{ID}_HOSTPORT` | yes | IP/hostname and port of vboxwebsrv (e.g. `192.168.1.1:18083`) |
| `{ID}_NAME` | no | Display name in the UI |
| `{ID}_USER` | no | vboxwebsrv username (default: `username`) |
| `{ID}_PW` | no | vboxwebsrv password (default: `password`) |
| `{ID}_CONF_{option}` | no | Per-server config override |

### Global Configuration

| Variable | Description |
|---|---|
| `CONF_noAuth=true` | Disable authentication |
| `CONF_browserRestrictFolders` | Restrict file browser paths (comma-separated) |
| `CONF_{varName}` | Override any phpVirtualBox config variable |

Comma-separated values are automatically converted to arrays.

## Multiple Servers

```bash
docker run -d --name phpvirtualbox -p 8080:80 \
  -e SRV1_HOSTPORT=192.168.1.1:18083 \
  -e SRV1_NAME=Server1 \
  -e SRV1_USER=user1 \
  -e SRV1_PW=pass1 \
  -e SRV1_CONF_authMaster=true \
  -e SRV2_HOSTPORT=192.168.1.2:18083 \
  -e SRV2_NAME=Server2 \
  -e SRV2_USER=user2 \
  -e SRV2_PW=pass2 \
  viperdriver2000/phpvirtualbox
```

When using multiple servers, set `authMaster=true` on one server to use it for authentication.

## Docker Compose

```yaml
services:
  phpvirtualbox:
    build: .
    container_name: phpvirtualbox
    ports:
      - "8080:80"
    environment:
      SRV1_HOSTPORT: "192.168.1.10:18083"
      SRV1_NAME: "VBox-Server"
      SRV1_USER: "vboxuser"
      SRV1_PW: "secret"
    restart: unless-stopped
```

## Running vboxwebsrv as a Container

Use [jazzdd86/vboxwebsrv](https://github.com/jazzdd86/vboxwebsrv) to establish a secure SSH tunnel to the VirtualBox host:

```bash
docker run -d --name vbox_websrv \
  -v ./ssh:/root/.ssh \
  -e USE_KEY=1 \
  jazzdd/vboxwebsrv user@192.168.1.10

docker run -d --name phpvirtualbox -p 8080:80 \
  -e SRV1_HOSTPORT=vbox_websrv:18083 \
  -e SRV1_NAME=MyServer \
  -e SRV1_USER=vboxuser \
  -e SRV1_PW=secret \
  viperdriver2000/phpvirtualbox
```

## Endpoints

| Path | Description |
|---|---|
| `/` | phpVirtualBox web UI |
| `/healthz` | Health check |
