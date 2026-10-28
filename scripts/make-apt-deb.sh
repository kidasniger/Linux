#!/usr/bin/env bash
# wine-prereqs-apt : dépôt apt local (tous les .deb Wine/Vulkan + dépendances)
set -eu
VER="$1"; OUT="$2"; WORK="$3"
P=wine-prereqs-apt; R="$WORK/$P"
rm -rf "$R"; mkdir -p "$R/DEBIAN" "$R/opt/wine-prereqs/apt"
cp /var/cache/apt/archives/*.deb "$R/opt/wine-prereqs/apt/"
apt-get install -y --no-install-recommends dpkg-dev >/dev/null
( cd "$R/opt/wine-prereqs/apt" && dpkg-scanpackages -m . /dev/null | gzip -9c > Packages.gz )
cat > "$R/DEBIAN/control" <<CTL
Package: $P
Version: $VER
Architecture: all
Maintainer: kidasniger <noreply@example.com>
Description: Dépôt apt local hors-ligne : Wine, winetricks, Vulkan, Mesa
 Installer ensuite avec : sudo wine-prereqs-system
CTL
dpkg-deb -Zxz -z6 --build "$R" "$OUT/${P}_${VER}_all.deb"
