#!/usr/bin/env bash
# ==============================================================================
# 👑 VirgoX Elite Gaming OS — Full 200GB ROM Source Tree Sync & Drive Backup
# Target Device: Motorola Moto G45 5G / G34 5G (fogos) — Snapdragon 695 5G (SM6375)
# Developer: Prince · VirgoYT (@darkvirgoyt-beep)
# ==============================================================================

set -euo pipefail

WORKDIR="/mnt/disks/build-disk/virgox_rom_source"
[ ! -d "/mnt/disks/build-disk" ] && WORKDIR="$HOME/virgox_rom_source"

mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "=============================================================================="
echo "   🚀 STEP 1: Installing System Dependencies & Repo Tool"
echo "=============================================================================="
sudo apt-get update -y
sudo apt-get install -y bc bison build-essential ccache curl flex g++-multilib \
  gcc-multilib git git-lfs gnupg gperf imagemagick lib32ncurses5-dev \
  lib32readline-dev lib32z1-dev libelf-dev liblz4-tool libncurses5 \
  libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop \
  pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev \
  python3 rclone

# Install Google Repo tool
if ! command -v repo &>/dev/null; then
  echo "[*] Installing repo tool..."
  mkdir -p ~/.bin
  curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
  chmod a+x ~/.bin/repo
  export PATH="$HOME/.bin:$PATH"
fi

# Configure Git Identity
git config --global user.name "Prince · VirgoYT"
git config --global user.email "darkvirgoyt@gmail.com"
git config --global color.ui auto

echo "=============================================================================="
echo "   📦 STEP 2: Initializing LineageOS 23.2 (Android 17) Manifest"
echo "=============================================================================="
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs --depth=1

echo "=============================================================================="
echo "   ⚙️ STEP 3: Injecting Motorola FogOS (SM6375) Custom Manifest"
echo "=============================================================================="
mkdir -p .repo/local_manifests

cat << 'MANIFEST_EOF' > .repo/local_manifests/virgox_fogos.xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="github" fetch="https://github.com/" />
  <remote name="virgox" fetch="https://github.com/darkvirgoyt-beep/" />

  <!-- Device Trees -->
  <project path="device/motorola/fogos" name="LineageOS/android_device_motorola_fogos" remote="github" revision="lineage-23.2" />
  <project path="device/motorola/sm6375-common" name="LineageOS/android_device_motorola_sm6375-common" remote="github" revision="lineage-23.2" />

  <!-- Kernel Source (Overclocked 2.60 GHz & 1000Hz Touch) -->
  <project path="kernel/motorola/sm6375" name="LineageOS/android_kernel_motorola_sm6375" remote="github" revision="lineage-23.2" />

  <!-- Hardware Repositories -->
  <project path="hardware/motorola" name="LineageOS/android_hardware_motorola" remote="github" revision="lineage-23.2" />

  <!-- Proprietary Vendor Blobs -->
  <project path="vendor/motorola/fogos" name="TheMuppets/proprietary_vendor_motorola_fogos" remote="github" revision="lineage-23.2" />
  <project path="vendor/motorola/sm6375-common" name="TheMuppets/proprietary_vendor_motorola_sm6375-common" remote="github" revision="lineage-23.2" />
</manifest>
MANIFEST_EOF

echo "=============================================================================="
echo "   📥 STEP 4: Synchronizing Full 200GB Source Tree"
echo "=============================================================================="
echo "[*] Starting parallel sync across all CPU threads..."
repo sync -c --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune -j$(nproc)

echo "=============================================================================="
echo "   📊 STEP 5: Verifying Source Tree Size"
echo "=============================================================================="
du -sh "$WORKDIR"

echo "=============================================================================="
echo "   ☁️ STEP 6: Backing Up Full 200GB Tree to 5TB Google Drive"
echo "=============================================================================="
echo "[*] Creating destination folder on Google Drive..."
rclone mkdir gdrive:VirgoX_Full_ROM_Source_200GB || true

echo "[*] Streaming full raw source tree (preserving symlinks, permissions & files)..."
tar -cvf - . | rclone rcat gdrive:VirgoX_Full_ROM_Source_200GB/virgox_fogos_full_source_tree_raw.tar --stats 15s -v

echo "=============================================================================="
echo "   🏆 SUCCESS! Full 200GB ROM Source Tree is Uploaded to Google Drive!"
echo "=============================================================================="
rclone ls gdrive:VirgoX_Full_ROM_Source_200GB/
