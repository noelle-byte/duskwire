#!/usr/bin/env bash

set -euo pipefail

repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
host="LaptopOfDreams"
expected="/home/noelle/Projects/Duskwire"

if [[ "$repo" != "$expected" ]]; then
  cat >&2 <<MESSAGE
Duskwire is currently at:
  $repo

Its host profile currently expects:
  $expected

Move the repository there, or edit repoPath in:
  hosts/$host/variables.nix
MESSAGE
  exit 1
fi

cd "$repo"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init
fi

git add -A

nix_config="experimental-features = nix-command flakes"

if [[ ! -f flake.lock ]]; then
  NIX_CONFIG="$nix_config" nix flake lock
  git add flake.lock
fi

echo "Checking the Duskwire flake..."
NIX_CONFIG="$nix_config" nix flake check --no-build

echo "Building and temporarily activating Duskwire..."
sudo env NIX_CONFIG="$nix_config" \
  nixos-rebuild test --flake ".#$host"

cat <<'MESSAGE'

Duskwire is active for this boot.

Check that Hyprland, Waybar, Eww, Kitty and your applications behave normally.
When satisfied, make it permanent with:

  duskwire switch

Your replaced unmanaged config files are retained with the suffix
.pre-duskwire by Home Manager.
MESSAGE
