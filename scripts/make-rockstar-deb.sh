#!/usr/bin/env bash
set -eu
VER="$1"; SRC="$2"; OUT="$3"; P=wine-prereqs-rockstar
R="$(mktemp -d)"; mkdir -p "$R/DEBIAN" "$R/opt/wine-prereqs/launchers"
cp "$SRC"/*.exe "$R/opt/wine-prereqs/launchers/"
cat > "$R/DEBIAN/control" <<CTL
Package: $P
Version: $VER
Architecture: all
Maintainer: kidasniger <noreply@example.com>
Description: Rockstar Games Launcher (.exe) pour installation hors-ligne
CTL
dpkg-deb -Zxz -z1 --build "$R" "$OUT/${P}_${VER}_all.deb"
