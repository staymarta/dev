# StayMarta Local Development Environment

This repo contains everything you need to start hacking on the StayMarta backend!

## Setup

### Prerequisites

* [docker](https://docker.io) EXCEPT Mac, see below.

### Install

```bash

$ setup.sh
```

... and you're done!

Rancher will be accessible at http://127.0.0.1:8080.

#### Controlling the Stack

After creation, you have two options:

  * `start.sh` - starts the entire stack
  * `cleanup.sh` - customizable removal of the stack.

## Things to come...

* Build Pipeline integration
* Quick Deploys to Development
* Automatic Rancher Snapshots *from* production.

## Reporting Errors

Please attach a full log, and the output of a couple of commands:

`docker-machine ls`

`docker ps`

These commands will help us debug issues much faster!

## FAQ

### How do I deploy?

Coming soon...

### I don't like rebuilding images!

Simple, just mirror your service to /storage (using rsync, or whatever)

and then write code in the following dir `./storage/<your-dir>`

Then, in container, use something to refresh it on filesystem change.

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
