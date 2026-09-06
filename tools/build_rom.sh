#!/usr/bin/env bash
set -e

# ==============================================================================
# FogOS Elite Gaming ROM Builder Script for Motorola Moto G45 5G (fogos)
# Developer : Prince · VirgoYT (VirgoYT707)
# ==============================================================================

WORK_DIR="$(pwd)/workspace"
OUT_DIR="$(pwd)/out"
mkdir -p "$WORK_DIR" "$OUT_DIR" "$OUT_DIR/tools" "$OUT_DIR/modules"

echo "=============================================================================="
echo "      Starting FogOS Elite Gaming ROM Build for Moto G45 (fogos)"
echo "                   Developer: Prince · VirgoYT"
echo "=============================================================================="

# 1. Fetch Base LineageOS ROM for fogos
echo "[1/7] Fetching latest official base ROM for fogos..."
BUILDS_JSON=$(curl -s "https://download.lineageos.org/api/v2/devices/fogos/builds")
LATEST_ZIP_URL=$(echo "$BUILDS_JSON" | jq -r '.[0].files[] | select(.filename | endswith(".zip")) | .url')
LATEST_ZIP_NAME=$(echo "$BUILDS_JSON" | jq -r '.[0].files[] | select(.filename | endswith(".zip")) | .filename')

if [ -z "$LATEST_ZIP_URL" ] || [ "$LATEST_ZIP_URL" == "null" ]; then
    echo "[!] Fallback to nightly mirror URL..."
    LATEST_ZIP_URL="https://mirrorbits.lineageos.org/full/fogos/20260905/lineage-23.2-20260905-nightly-fogos-signed.zip"
    LATEST_ZIP_NAME="lineage-fogos-base.zip"
fi

echo "[*] Downloading base ROM: $LATEST_ZIP_NAME"
curl -L "$LATEST_ZIP_URL" -o "$WORK_DIR/base_rom.zip"

# 2. Extract payload.bin
echo "[2/7] Extracting partitions from base ROM..."
unzip -q -o "$WORK_DIR/base_rom.zip" "payload.bin" -d "$WORK_DIR"

# Install payload-dumper-go if missing
if ! command -v payload-dumper-go &> /dev/null; then
    echo "[*] Installing payload-dumper-go..."
    curl -sL https://github.com/ssut/payload-dumper-go/releases/download/1.3.0/payload-dumper-go_1.3.0_linux_amd64.tar.gz | tar -xz -C /usr/local/bin/
fi

payload-dumper-go -o "$WORK_DIR/extracted" "$WORK_DIR/payload.bin"

# 3. Pull VirgoYT Gaming Kernel & PulseControl
echo "[3/7] Pulling VirgoYT Gaming Kernel and PulseControl app..."
KERNEL_REPO="darkvirgoyt-beep/Motorola-g45-34-gaming-kernel-Fogos-new"
mkdir -p "$WORK_DIR/kernel_assets"
gh release download --repo "$KERNEL_REPO" --dir "$WORK_DIR/kernel_assets" --pattern "*" || true

# Find VirgoYT custom boot.img
VIRGO_BOOT=$(find "$WORK_DIR/kernel_assets" -name "*boot*.img" | head -n 1)
if [ -f "$VIRGO_BOOT" ]; then
    echo "[*] Integrating VirgoYT Gaming Kernel: $(basename "$VIRGO_BOOT")"
    cp "$VIRGO_BOOT" "$WORK_DIR/extracted/boot.img"
else
    echo "[!] No custom boot found in release, using extracted base boot."
fi

# Find PulseControl APK
PULSE_APK=$(find "$WORK_DIR/kernel_assets" -name "*PulseControl*.apk" | head -n 1)
if [ -f "$PULSE_APK" ]; then
    echo "[*] Found PulseControl companion APK: $(basename "$PULSE_APK")"
    cp "$PULSE_APK" "$OUT_DIR/tools/FogOS-PulseControl.apk"
fi

# 4. Download Companion Tools (SmartPack Kernel Manager & Play Integrity Fix)
echo "[4/7] Downloading Kernel Manager and Play Integrity Fix..."
curl -sL "https://github.com/SmartPack/SmartPack-Kernel-Manager/releases/download/v17.7/app-fdroid-release.apk" -o "$OUT_DIR/tools/SmartPack-Kernel-Manager.apk" || true
curl -sL "https://github.com/KOWX712/PlayIntegrityFix/releases/download/v4.7-inject-s/PlayIntegrityFix_v4.7-1-inject-s.zip" -o "$OUT_DIR/modules/PlayIntegrityFix.zip" || true

# 5. Integrate Elite Gaming Tweaks & Configurations
echo "[5/7] Injecting FogOS Elite Gaming configs, init.rc, and GameManager interventions..."
mkdir -p "$OUT_DIR/config"
cp patches/fogos_gaming.prop "$OUT_DIR/config/fogos_gaming.prop"
cp patches/game_spoofing.xml "$OUT_DIR/config/game_spoofing.xml"
cp patches/game_mode_config.xml "$OUT_DIR/config/game_mode_config.xml"
cp sysconfig/gaming_power_whitelist.xml "$OUT_DIR/config/gaming_power_whitelist.xml" || true
cp patches/init.fogos.gaming.rc "$OUT_DIR/config/init.fogos.gaming.rc"
cp rootdir/init.fogos.rc "$OUT_DIR/config/init.fogos.rc" || true
cp system_ext.prop "$OUT_DIR/config/system_ext.prop" || true

# Copy Flasher scripts
cp flasher/flash_all.bat "$OUT_DIR/"
cp flasher/flash_all.sh "$OUT_DIR/"
chmod +x "$OUT_DIR/flash_all.sh"

# Copy image files to output directory
echo "[6/7] Assembling flashable partition images..."
cp "$WORK_DIR"/extracted/*.img "$OUT_DIR/"

# 6. Create Fastboot Flashable ZIP
echo "[7/7] Packaging FogOS Elite Gaming ROM distribution..."
BUILD_DATE=$(date +'%Y%m%d')
RELEASE_ZIP_NAME="FogOS-v1.0-EliteGaming-fogos-VirgoYT-${BUILD_DATE}.zip"

cd "$OUT_DIR"
sha256sum *.img > SHA256SUMS.txt
zip -r -9 "../$RELEASE_ZIP_NAME" ./*

echo "=============================================================================="
echo "[SUCCESS] FogOS Elite Gaming ROM built successfully!"
echo "Package: $RELEASE_ZIP_NAME"
echo "=============================================================================="
