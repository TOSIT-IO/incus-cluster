# TDP Incus

Launch a fully-featured virtual TDP Hadoop cluster with a single command _or_ customize the infrastructure.

## Requirements

- incus
- openssh
- yq

Incus will provide qemu VM through libvirt currently

## Start Environment

```bash
./launch.sh
```

## Stop Environment

```bash
./destroy.sh
```

## Enter in VM

```bash
incus shell edge-01
```

## Enter using SSH

```bash
ssh -i data/incus_key incus@edge-01.tdp
```
