#!/bin/sh

PACKER_CACHE_DIR=../../../packer_cache packer build -on-error=ask packer/ubuntu_bionic.json

