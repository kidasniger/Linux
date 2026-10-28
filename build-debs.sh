#!/usr/bin/env bash
# Construit, sur GitHub (Debian 12), des .deb contenant TOUT pour une installation 100 % hors ligne.
set -eu
cd "$(dirname "$0")"
VER="${VER:-1.0}"
OUT="$PWD/out"; WORK="$PWD/work"
rm -rf "$OUT" "$WORK"; mkdir -p "$OUT" "$WORK"
export DEBIAN_FRONTEND=noninteractive WINEDEBUG=-all

echo "##[group]1/6 Dépôts apt + Wine"
rm -f /etc/apt/apt.conf.d/docker-clean
echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99keep
echo 'APT::Keep-Downloaded-Packages "true";' >> /etc/apt/apt.conf.d/99keep
dpkg --add-architecture i386
sed -i 's/^Components: main$/Components: main contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources 2>/dev/null || true
apt-get update
APT_PKGS="wine wine32 wine64 libwine libwine:i386 winetricks cabextract p7zip-full unzip wget \
 libvulkan1 libvulkan1:i386 vulkan-tools mesa-vulkan-drivers mesa-vulkan-drivers:i386 \
 fonts-wine xvfb xauth"
# on télécharge d'abord (bundle hors ligne), puis on installe pour pouvoir remplir les caches
apt-get install -y --download-only --no-install-recommends $APT_PKGS
apt-get install -y --no-install-recommends $APT_PKGS
N=$(ls /var/cache/apt/archives/*.deb 2>/dev/null | wc -l); echo "$N .deb en cache"; [ "$N" -gt 0 ] || { echo "ERREUR: aucun .deb en cache"; exit 1; }
echo "##[endgroup]"

echo "##[group]2/6 Bundle apt (Wine + Vulkan + deps, dépôt local)"
./scripts/make-apt-deb.sh "$VER" "$OUT" "$WORK"
echo "##[endgroup]"

# --- remplissage des caches winetricks : un dossier par groupe ------------------
fill() { # fill <groupe> <win32|win64> <verbes...>
  local g="$1" arch="$2"; shift 2
  local cache="$WORK/cache-$g" pfx="$WORK/pfx-$g"
  mkdir -p "$cache"
  export W_CACHE="$cache" WINEPREFIX="$pfx" WINEARCH="$arch"
  xvfb-run -a wineboot -u || true
  for v in "$@"; do
    echo "=== [$g] $v ==="
    xvfb-run -a winetricks -q "$v" || echo "!! $v a échoué"
  done
  wineserver -k 2>/dev/null || true
  du -sh "$cache"
}

echo "##[group]3/6 VC++ 2005 → 2022"
fill vcrun win64 vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2015 vcrun2017 vcrun2022
echo "##[endgroup]"
echo "##[group]4/6 .NET 3.5 / 4.0 / 4.5 / 4.8 (préfixe 32-bit obligatoire)"
fill dotnet win32 dotnet35 dotnet40 dotnet45 dotnet48
echo "##[endgroup]"
echo "##[group]5/6 DirectX / DXVK / polices"
fill graphics win64 corefonts d3dcompiler_47 d3dx9 d3dx10 d3dx11_43 dxvk
echo "##[endgroup]"

# vérification : on refuse de publier un cache vide
for g in vcrun dotnet graphics; do
  n=$(find "$WORK/cache-$g" -type f | wc -l)
  [ "$n" -gt 0 ] || { echo "ERREUR : cache $g vide"; exit 1; }
done

# --- dédoublonnage (évite les conflits de fichiers entre paquets dpkg) ----------
for g in dotnet graphics; do
  for prev in vcrun dotnet graphics; do
    [ "$prev" = "$g" ] && break
    (cd "$WORK/cache-$g" && find . -type f | while read -r f; do
       if [ -e "$WORK/cache-$prev/$f" ]; then rm -f "$f"; fi; done)
  done
done

echo "##[group]6/6 Lanceur Rockstar (optionnel)"
mkdir -p "$WORK/cache-rockstar"
if curl -fL --retry 3 -o "$WORK/cache-rockstar/Rockstar-Games-Launcher.exe" \
   "https://gamedownloads.rockstargames.com/public/installer/Rockstar-Games-Launcher.exe"; then
  echo "Lanceur Rockstar téléchargé."
else
  echo "!! Lanceur Rockstar non téléchargé : mets le .exe toi-même (voir README)."
  rm -rf "$WORK/cache-rockstar"
fi
echo "##[endgroup]"

# --- paquets .deb ---------------------------------------------------------------
./scripts/make-cache-deb.sh wine-prereqs-vcrun     "$VER" "$WORK/cache-vcrun"     "Visual C++ 2005-2022 (cache winetricks)" "$OUT"
./scripts/make-cache-deb.sh wine-prereqs-dotnet    "$VER" "$WORK/cache-dotnet"    ".NET 3.5/4.0/4.5/4.8 (cache winetricks)" "$OUT"
./scripts/make-cache-deb.sh wine-prereqs-graphics  "$VER" "$WORK/cache-graphics"  "DirectX, DXVK, d3dcompiler, polices (cache winetricks)" "$OUT"
[ -d "$WORK/cache-rockstar" ] && ./scripts/make-rockstar-deb.sh "$VER" "$WORK/cache-rockstar" "$OUT"
./scripts/make-core-deb.sh "$VER" "$OUT"

cp scripts/install-offline.sh "$OUT/install-offline.sh"; chmod +x "$OUT/install-offline.sh"
( cd "$OUT" && sha256sum * > SHA256SUMS.txt )
ls -lh "$OUT"
