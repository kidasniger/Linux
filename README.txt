wine-prereqs-offline — construit sur GitHub, s'installe SANS Internet
======================================================================

A) SUR GITHUB (une seule fois, avec Internet)
  1. Crée un dépôt GitHub (public = minutes illimitées) et envoie TOUT le contenu de ce ZIP,
     y compris le dossier caché .github (sur Android : envoie via l'interface web "Add file > Upload files"
     et vérifie que .github/workflows/build-debs.yml est bien présent).
  2. Onglet Actions > "Build wine-prereqs offline debs" > Run workflow.
  3. Attends le vert (30 à 90 min). Télécharge l'artifact "wine-prereqs-offline" (zip).
     Pour une Release avec les fichiers séparés : crée un tag, ex. "git tag v1.0 && git push --tags".

B) SUR TON LINUX (Deepin / Debian 12), SANS Internet
  1. Décompresse l'artifact : tu obtiens ces fichiers
       wine-prereqs-apt_1.0_all.deb       (Wine, winetricks, Vulkan, Mesa + dépendances)
       wine-prereqs-vcrun_1.0_all.deb     (Visual C++ 2005 → 2022)
       wine-prereqs-dotnet_1.0_all.deb    (.NET 3.5 / 4.0 / 4.5 / 4.8)
       wine-prereqs-graphics_1.0_all.deb  (DirectX d3dx9/10/11, d3dcompiler_47, DXVK, polices)
       wine-prereqs-rockstar_1.0_all.deb  (Rockstar Games Launcher .exe, si téléchargé)
       wine-prereqs_1.0_all.deb           (commandes d'installation)
       install-offline.sh
  2. Dans ce dossier :   chmod +x install-offline.sh && ./install-offline.sh
  3. Puis, SANS sudo :   wine-prereqs-setup

Notes
  - Deux préfixes Wine : ~/.wine-jeux (64-bit) et ~/.wine-dotnet32 (32-bit, obligatoire pour dotnet35/40).
  - NVIDIA : installe le pilote propriétaire via le gestionnaire de pilotes Deepin.
  - Si le lanceur Rockstar n'a pas pu être téléchargé par GitHub, copie ton .exe et lance :
        wine-prereqs-setup /chemin/Rockstar-Games-Launcher.exe
  - Les paquets sont construits sur Debian 12 (base de Deepin 23).
