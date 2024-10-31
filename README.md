# TDP Incus

Launch a fully-featured virtual TDP Hadoop cluster with a single command _or_ customize the infrastructure.

## Requirements

- incus
- openssh
- jq

Incus will provide qemu VM through libvirt currently

## Start Environment

```bash
export TDP_HOME=<Path>
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

If machine IPs defined in `/etc/hosts`:

```bash
ssh -i data/incus_key incus@edge-01.tdp
```
Else:

```bash
ssh -i data/incus_key incus@192.168.56.10
```

## Containerized Incus as client

In order to be sure for the commands in the scripts to work on a another Incus server which could be on your host, an Incus client with the version 6.6 has been dockeried.

0. If it has not been done add your host ip address in your Incus server with the following command:

    ```sh
    incus config set core.https_address=<host-ip>:<port>
    ```
    By default the port taken is `8443` if not specified.

    Then create a token which you will need for the client authorization.

    ```sh
    incus config trust add tdp-incus-container
    ```

1. Build the image:

    ```sh
    docker build -t incus-container dev
    ```

2. Run the container from the tdp-dev or tdp-getting-started directory:

    ```sh
    docker run --rm -it -v $PWD:/home/tdp --user $(id -u):$(id -g) incus-container
    ```
3. Add The the Incus server on your host as remote server with the same IP and port specified in point 0:

    ```sh
    incus remote add incus-host-server <host-ip>:<port>
    ```

    It will show you a certificate fingerprint and ask you if you confirm. Type `y`. And then paste the token that you have created with the server.

    Again if the port number is not specified it will default to port `8443`.

4. Make Incus use the remote Server:

    ```sh
    incus remote switch incus-host-server
    ```

    Cincus remote listan be verified with the command `incus remote list`. The remote with the tag `(current)` in its name column is the currently used one.

5. Now the machines can be launched:

    ```sh
    ./launch
    ```
