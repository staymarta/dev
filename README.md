# StayMarta Local Development Environment

This repo contains everything you need to start hacking on the StayMarta backend!

## Setup

### Prerequisites

* [docker](https://docker.io)
* [docker-compose] (https://docs.docker.com/compose/install/)

Mac

* [Tunnelblick](https://tunnelblick.net/downloads.html) (For 172.16.0.0 access)

### Install

```bash

$ setup.sh
$ docker-compose up
```

## Things to come...

* Build Pipeline integration
* Quick Deploys to Development
* Automatic Rancher Snapshots *from* production.

## Reporting Errors

Please attach a full log, and the output of a couple of commands:

`docker ps`

`docker-compose logs`

These commands will help us debug issues much faster!

## FAQ

### How do I deploy?

Coming soon...

### What's the difference between `storage` and `services`

Services is intended for git repos, things that will be pulled on clone.

Storage is intended for binaries, things like a `postgres` database.

### I don't like rebuilding images!

Add a volume in the docker-compose to target ./storage/<service>:/in/container/dir

## Default Configuration

### Vault

Vault Keys

```
Unseal Key 1: g54wsONvE6kZR+mP7jgigmKCUSwsKlqqEHjCu0xe3H0B
Unseal Key 2: d2J37fYnqgit8rc5K8t4knrvWC93WP6zcLYEtxbHSDMC
Unseal Key 3: R/OMiVObKzDvdjiaKSaPQFnwy0NSMFn777u6agxIgzwD
Unseal Key 4: hp73T5RKZjF/KaI9WLjvINhSR3Qlc7hpL6HwBB2xzJcE
Unseal Key 5: tg8MKzH25wk9rS2eWlUY8vtN1BgAGx8hsKxO2Qc+B5gF
Initial Root Token: 13984518-9666-3c1d-1c45-e53edb8ae393
```

Vault Setup

```bash
$ vault mount postgres
$ vault write postgresql/config/connection \
connection_url="postgresql://postgres@postgres:5432/postgres?sslmode=disable"
$ vault write postgresql/config/lease lease=1h lease_max=24h
$ vault write postgresql/roles/readonly \
    sql="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"
```

## License

BSD-3-Clause
