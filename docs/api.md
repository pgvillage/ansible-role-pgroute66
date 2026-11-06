# pgvillage.pgroute66 API

This document describes all variables that can be set to configure the `pgvillage.pgroute66` role.
Defaults are defined in [defaults/main.yml](../defaults/main.yml).

## Installation

| Variable | Default | Description |
|----------|---------|-------------|
| `pgroute66_packages` | `["pgroute66"]` | Packages to install from the configured package repositories. |
| `pgroute66_local_packages` | `[]` | Local package files (e.g. rpm's from the role `files` dir) that are copied to `/tmp` and installed from there. |
| `pgroute66_package_state` | `present` | State passed to the package module for all packages (e.g. `present`, `latest`, `absent`). |
| `pgroute66_deploydir` | `/usr/bin` | Directory where systemd expects the pgroute66 binary. Used in the systemd unit to start pgroute66. |

## Directories, users and certificates

| Variable | Default | Description |
|----------|---------|-------------|
| `pgroute66_scriptdir` | `/opt/pgroute66` | Directory where the HAProxy check scripts (`checkpgprimary.sh` and `checkpgstandby.sh`) are deployed. On hosts with SELinux enabled it is labeled `bin_t` (persistent, `community.general.sefcontext`), so HAProxy may run the scripts. |
| `pgroute66_selinux_packages` | `[policycoreutils-python-utils]` | Packages for managing SELinux file contexts, installed on hosts with SELinux enabled. |
| `pgroute66_configdir` | `/etc/pgroute66` | Directory where the pgroute66 config file (`config.yaml`) is deployed. |
| `pgroute66_osuser` | `pgroute66` | OS user created for pgroute66. Owns the client certificates in `~/.postgresql`. |
| `pgroute66_osgroup` | `pgroute66` | Primary OS group of `pgroute66_osuser`. |
| `pgroute66_cert_managed` | `false` | When `true`, client certificates are deployed to `~/.postgresql` of `pgroute66_osuser`. |

When `pgroute66_cert_managed` is `true`, the following variables must be defined (e.g. by a certificate role):

| Variable | Deployed as |
|----------|-------------|
| `certs.client.postgres` | `~/.postgresql/root.crt` |
| `certs.client.pgroute66` | `~/.postgresql/postgresql.crt` |
| `private_keys.client.pgroute66` | `~/.postgresql/postgresql.key` |

## pgroute66 service

| Variable | Default | Description |
|----------|---------|-------------|
| `pgroute66_bind` | `127.0.0.1` | Address the pgroute66 API listens on. |
| `pgroute66_port` | `8080` | Port the pgroute66 API listens on. **Note:** the HAProxy check scripts expect pgroute66 on `localhost:8080`. |
| `pgroute66_restart_wait_timeout` | `60` | Seconds to wait, after a restart, until the pgroute66 API answers on `pgroute66_port`, before restarting pgroute66 on the next host (see [Restarts](#restarts)). |
| `pgroute66_loglevel` | `info` | Log level of pgroute66 (e.g. `debug`, `info`, `warn`, `error`). |
| `pgroute66_verbosity` | `3` | Verbosity of pgroute66 logging. |

### Restarts

The role restarts pgroute66 when its package (`pgroute66_packages` or `pgroute66_local_packages`) is installed or
upgraded, or when the systemd unit (e.g. a changed `pgroute66_deploydir`, like `/usr/local/bin` to `/usr/bin`), the
config or the client certificates change. Restarts are rolling: one host at a time, and the role waits until the
pgroute66 API answers again (up to `pgroute66_restart_wait_timeout` seconds) before it restarts pgroute66 on the next
host, so HAProxy on the other hosts can still ask pgroute66 for the primary. On Ubuntu, exclude `pgroute66.service`
from needrestart, so it does not restart pgroute66 on all hosts at once after an upgrade.

## PostgreSQL nodes

| Variable | Default | Description |
|----------|---------|-------------|
| `pgroute66_pgnodes_group` | `hacluster` | Inventory group containing the PostgreSQL nodes pgroute66 should monitor. |
| `pgroute66_pgport` | `5432` | Port PostgreSQL listens on, on all nodes in `pgroute66_pgnodes_group`. |
| `pgroute66_dbname` | `postgres` | Database pgroute66 connects to, to check the role of each PostgreSQL node. |

## Full configuration

### `pgroute66_config`

The complete pgroute66 configuration, rendered as yaml into `{{ pgroute66_configdir }}/config.yaml`.
By default it is derived from the variables above, with one entry under `hosts` for every host in `pgroute66_pgnodes_group`:

```yaml
pgroute66_config:
  hosts:
    <inventory_hostname>:
      host: <inventory_hostname>
      port: "{{ pgroute66_pgport }}"
      dbname: "{{ pgroute66_dbname }}"
  loglevel: "{{ pgroute66_loglevel }}"
  verbosity: "{{ pgroute66_verbosity }}"
  bind: "{{ pgroute66_bind }}"
  port: "{{ pgroute66_port }}"
```

Override this variable completely when full control over the configuration is required.
Note that the individual variables above (under `pgroute66_config`) have no effect when `pgroute66_config` is overridden.