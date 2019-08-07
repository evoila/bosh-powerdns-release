#!/bin/sh
set -e

path=$(dirname $0)

cd $path
bosh create-release --force

bosh upload-release

bosh -d bosh-powerdns-release deploy manifests/pdns-lite.yml -n 
