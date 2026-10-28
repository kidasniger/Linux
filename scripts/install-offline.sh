#!/usr/bin/env bash
# Mets ce script dans le même dossier que tous les .deb téléchargés, puis :  ./install-offline.sh
set -eu
cd "$(dirname "$0")"
sudo dpkg -i wine-prereqs-apt_*.deb wine-prereqs-vcrun_*.deb wine-prereqs-dotnet_*.deb \
             wine-prereqs-graphics_*.deb wine-prereqs_*.deb
ls wine-prereqs-rockstar_*.deb >/dev/null 2>&1 && sudo dpkg -i wine-prereqs-rockstar_*.deb
sudo wine-prereqs-system
echo; echo "Dernière étape, SANS sudo :  wine-prereqs-setup"
