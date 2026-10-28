#!/usr/bin/env bash
# wine-prereqs : méta-paquet + commandes wine-prereqs-system / wine-prereqs-setup
set -eu
VER="$1"; OUT="$2"; P=wine-prereqs
R="$(mktemp -d)"; mkdir -p "$R/DEBIAN" "$R/usr/bin"
install -m755 scripts/wine-prereqs-system "$R/usr/bin/wine-prereqs-system"
install -m755 scripts/wine-prereqs-setup  "$R/usr/bin/wine-prereqs-setup"
cat > "$R/DEBIAN/control" <<CTL
Package: $P
Version: $VER
Architecture: all
Maintainer: kidasniger <noreply@example.com>
Recommends: wine-prereqs-apt, wine-prereqs-vcrun, wine-prereqs-dotnet, wine-prereqs-graphics
Description: Wine + prérequis Windows 100 % hors ligne
 1) sudo wine-prereqs-system   (installe Wine/Vulkan depuis le dépôt local)
 2) wine-prereqs-setup         (sans sudo : remplit le préfixe Wine)
CTL
dpkg-deb -Zxz -z1 --build "$R" "$OUT/${P}_${VER}_all.deb"
rm -rf "$R"
