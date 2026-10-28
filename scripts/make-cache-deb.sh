#!/usr/bin/env bash
# make-cache-deb.sh <nom> <ver> <dossier-cache> <description> <out>
set -eu
P="$1"; VER="$2"; SRC="$3"; DESC="$4"; OUT="$5"
R="$(mktemp -d)"
mkdir -p "$R/DEBIAN" "$R/opt/wine-prereqs/cache"
cp -a "$SRC/." "$R/opt/wine-prereqs/cache/"
cat > "$R/DEBIAN/control" <<CTL
Package: $P
Version: $VER
Architecture: all
Maintainer: kidasniger <noreply@example.com>
Description: $DESC
 Fichiers Microsoft pré-téléchargés pour installation hors-ligne via winetricks.
CTL
dpkg-deb -Zxz -z1 --build "$R" "$OUT/${P}_${VER}_all.deb"
rm -rf "$R"
