#!/usr/bin/env bash

set -e

version="0.54.1"

echo "--------"
grep 'url = "https://caido.download/releases/' package.nix | sed 's/.* url = "//;s/";//' | while read -r URL; do
    nix-hash --type sha256 --to-sri "$(nix-prefetch-url "${URL//\$\{version\}/$version}" --type sha256)"
    echo "--------"
done
