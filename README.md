# Incus cluster

Manage a cluster with Incus.

## Requirements

- incus
- openssh

## Config file

In your project dir, create incus.yml file
Example in the project

## Start Environment

```bash
export TDP_HOME=<Path>
./incus-cluster up
```

## Stop Environment

```bash
./incus-cluster stop
```

## Delete Environment

```bash
./incus-cluster delete
```

## Enter in VM

```bash
incus shell <vm>
```

## Enter using SSH

```bash
ssh -i data/incus_key <admin_user>@<vm>
```
