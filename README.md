# StayMarta Local Development Environment

This repo contains everything you need to start hacking on the StayMarta backend!

## Setup

### Prerequisites

**NOTICE** Mac users should see [Install](#install)

* [docker](https://docker.io)
* [docker-compose](https://docs.docker.com/compose/install/)

### Install

Make sure to clone recursively.

```bash
$ git clone --recursive git://github.com/staymarta/dev

# Checkout all submodules to master, to prevent merge issues.
$ cd "dev"
$ for submodule in $(ls services); do pushd "services/$submodule"; git checkout master; popd; done
```

#### What to do if you forgot to clone recursively:

```bash
$ git submodule init
$ git submodule update
```

#### Mac

```bash
# Install Homebrew (if you don't have it)
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install Docker for Mac & Tunnelblick
$ brew cask install tunnelblick docker
```

Install the `openvpn` profile in `development/docker-mac-network` called `docker-for-mac.ovpn`. This will enable you to access the internal container network, `172.18.0.0/32`. If you aren't working with services in stack, this isn't needed.

**NOTICE** Services will not work with this solution unless they expose a port. You can solve this by doing something like this:

```yaml
services:
  vault:
    # Docker maps this to a random port, but is :80 in container (iptables hack)
    ports: [ "80" ]
```

### Binaries

A few scripts are provided to help interact with the stack. They are in `bin/`. You can setup an automatic `.env` in plugin with your shell, or `source .env` before working in this environment. This will expose each binary into your `PATH`.

Example:

```bash
$ source .env
$ vault # vault -> ./bin/vault -> container -> vault
```



## Things to come...

* Production Data Integration
* Image based stack services (i.e Jenkins)

## Reporting Errors

Please attach a full log, and the output of a couple of commands:

`docker ps`

`docker-compose logs`

These commands will help us debug issues much faster!

Soon we'll have a script for this.

## FAQ

### What's the difference between `storage` and `services`

Services is intended for git repos, things that will be pulled on clone.

Storage is intended for binaries, things like a `postgres` database.

### I don't like rebuilding images!

Add a volume in the docker-compose to target ./storage/<service>:/in/container/dir

## Default Configuration

### ArangoDB

Password: `supersecretpassword`

## License

BSD-3-Clause
