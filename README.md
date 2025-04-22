# Incus cluster

Manage a cluster with Incus.

## Requirements

- incus
- openssh

## Install

Symlink incus-cluster into .local/bin

```bash
ln -s /path/to/here/incus-cluster ${HOME}/.local/bin
```

Alternatively, add incus-cluster dir into your path
In .bashrc/.zshrc:
```sh
export PATH="$PATH:/path/to/here/"
```

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
