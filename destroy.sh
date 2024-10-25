#!/usr/bin/env bash

cd "$(dirname "$0")"

for f in edge-01 master-01 master-02 master-03 worker-01 worker-02 worker-03; do
	incus delete $f --force
done
