#!/usr/bin/env bash

set -eu -o pipefail

if ! command -v tvix &>/dev/null; then
  echo "tvix must be available in your path"
  exit 1
fi

# create a nixpkgs symlink for tvix, it can't use 'fetchGit'
rm -f nixpkgs && nix build '.#nixpkgs-src' -o nixpkgs

day="${1:?Please supply the day to run as the only argument, such as 'day01' or 'day01.part1'}"
subattr=""
if [[ "$day" == *"."* ]]; then
  subattr=".${day#*.}"
fi

day="${day%%.*}"

tvix --strict -E "(import ./$day (rec {nixpkgs = import ./nixpkgs {}; lib = import ./lib.nix { pkgs = nixpkgs; }; }))$subattr"
