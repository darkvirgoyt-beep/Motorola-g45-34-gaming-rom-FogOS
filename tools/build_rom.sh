#!/usr/bin/env bash
set -e

# ==============================================================================
# VirgoX Elite Gaming OS Builder Script for Motorola Moto G45 5G (fogos)
# Developer : Prince · VirgoYT (VirgoYT707)
# ==============================================================================

WORK_DIR="$(pwd)/workspace"
OUT_DIR="$(pwd)/out"
mkdir -p "$WORK_DIR" "$OUT_DIR" "$OUT_DIR/tools" "$OUT_DIR/modules"

echo "=============================================================================="
echo "      Starting VirgoX Elite Gaming OS Build for Moto G45 (fogos)"
echo "                   Developer: Prince · VirgoYT"
echo "=============================================================================="

# 1. Obtain Base ROM for fogos
echo "[1/7] Fetching base ROM for fogos..."

if [ -n "$BASE_ROM_PATH" ] && [ -f "$BASE_ROM_PATH" ]; then
    echo "[*] Using local base ROM override: $BASE_ROM_PATH"
    cp "$BASE_ROM_PATH" "$WORK_DIR/base_rom.zip"
elif [ -n "$BASE_ROM_URL" ]; then
    echo "[*] Downloading base ROM override from: $BASE_ROM_URL"
    curl -L "$BASE_ROM_URL" -o "$WORK_DIR/base_rom.zip"
else
    echo "[*] Querying latest official LineageOS base ROM for fogos..."
    BUILDS_JSON=$(curl -s "https://download.lineageos.org/api/v2/devices/fogos/builds" || true)
    LATEST_ZIP_URL=$(echo "$BUILDS_JSON" | jq -r '.[0].files[] | select(.filename | endswith(".zip")) | .url' 2>/dev/null || true)
    LATEST_ZIP_NAME=$(echo "$BUILDS_JSON" | jq -r '.[0].files[] | select(.filename | endswith(".zip")) | .filename' 2>/dev/null || true)

    if [ -z "$LATEST_ZIP_URL" ] || [ "$LATEST_ZIP_URL" == "null" ]; then
        echo "[!] LineageOS API unavailable or empty, falling back to direct nightly mirror..."
        LATEST_ZIP_URL="https://mirrorbits.lineageos.org/full/fogos/20260905/lineage-23.2-20260905-nightly-fogos-signed.zip"
        LATEST_ZIP_NAME="lineage-23.2-20260905-nightly-fogos-signed.zip"
    fi

    echo "[*] Downloading base ROM: $LATEST_ZIP_NAME"
    curl -L --retry 3 --retry-delay 5 "$LATEST_ZIP_URL" -o "$WORK_DIR/base_rom.zip"
fi

if [ ! -f "$WORK_DIR/base_rom.zip" ]; then
    echo "[!] ERROR: Failed to obtain base ROM zip. Exiting."
    exit 1
fi
echo "[*] Base ROM ready: $(du -h "$WORK_DIR/base_rom.zip" | cut -f1)"

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
PULSE_APK=$(find "$WORK_DIR/kernel_assets" -name "*PulseControl*.apk" 2>/dev/null | head -n 1)
if [ -z "$PULSE_APK" ] || [ ! -f "$PULSE_APK" ]; then
    echo "[*] Downloading PulseControl APK from FogOS-PulseControl repository..."
    mkdir -p "$WORK_DIR/pulse_assets"
    gh release download --repo "darkvirgoyt-beep/FogOS-PulseControl" --dir "$WORK_DIR/pulse_assets" --pattern "*.apk" || true
    PULSE_APK=$(find "$WORK_DIR/pulse_assets" -name "*PulseControl*.apk" 2>/dev/null | head -n 1)
fi

if [ -n "$PULSE_APK" ] && [ -f "$PULSE_APK" ]; then
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
cp patches/fogos_gaming.prop "$OUT_DIR/config/fogos_gaming.prop" || true
cp patches/game_spoofing.xml "$OUT_DIR/config/game_spoofing.xml" || true
cp patches/game_mode_config.xml "$OUT_DIR/config/game_mode_config.xml" || true
cp sysconfig/gaming_power_whitelist.xml "$OUT_DIR/config/gaming_power_whitelist.xml" || true
cp patches/init.fogos.gaming.rc "$OUT_DIR/config/init.fogos.gaming.rc" || true
cp patches/fogos_game_network.sh "$OUT_DIR/config/fogos_game_network.sh" || true
cp patches/fogos_ram_optimizer.sh "$OUT_DIR/config/fogos_ram_optimizer.sh" || true
cp rootdir/init.fogos.rc "$OUT_DIR/config/init.fogos.rc" || true
cp system_ext.prop "$OUT_DIR/config/system_ext.prop" || true
echo "These configs have been baked into the system partitions. They are kept here for documentation purposes." > "$OUT_DIR/config/README.txt"

# Install required tools for image manipulation
if ! command -v simg2img &> /dev/null; then
    echo "[*] Installing android-sdk-libsparse-utils and e2fsprogs..."
    sudo apt-get update -y && sudo apt-get install -y android-sdk-libsparse-utils e2fsprogs || true
fi

SYSTEM_IMG="$WORK_DIR/extracted/system.img"
if [ -f "$SYSTEM_IMG" ]; then
    echo "[*] Injecting configs into system.img..."
    # Convert to raw
    simg2img "$SYSTEM_IMG" "$WORK_DIR/extracted/system.raw.img" 2>/dev/null || cp "$SYSTEM_IMG" "$WORK_DIR/extracted/system.raw.img"
    
    # Check and resize filesystem cleanly
    sudo e2fsck -y -f "$WORK_DIR/extracted/system.raw.img" || true
    truncate -s +100M "$WORK_DIR/extracted/system.raw.img" 2>/dev/null || true
    sudo resize2fs "$WORK_DIR/extracted/system.raw.img" || true
    
    # Mount
    MNT_DIR="$WORK_DIR/mnt_system"
    mkdir -p "$MNT_DIR"
    sudo mount -o loop,rw "$WORK_DIR/extracted/system.raw.img" "$MNT_DIR"
    
    # Check if system is root or system/system
    if [ -d "$MNT_DIR/system" ]; then
        SYS_ROOT="$MNT_DIR/system"
    else
        SYS_ROOT="$MNT_DIR"
    fi
    
    sudo mkdir -p "$SYS_ROOT/bin" "$SYS_ROOT/etc/init" "$SYS_ROOT/etc/sysconfig" "$SYS_ROOT/priv-app/FogOS-PulseControl" "$SYS_ROOT/media"
    
    if [ -f "$OUT_DIR/tools/FogOS-PulseControl.apk" ]; then
        echo "[*] Pre-installing FogOS-PulseControl into /system/priv-app/..."
        sudo cp "$OUT_DIR/tools/FogOS-PulseControl.apk" "$SYS_ROOT/priv-app/FogOS-PulseControl/FogOS-PulseControl.apk"
        sudo chmod 644 "$SYS_ROOT/priv-app/FogOS-PulseControl/FogOS-PulseControl.apk"
    fi
    
    [ -f "patches/fogos_ram_optimizer.sh" ] && sudo cp patches/fogos_ram_optimizer.sh "$SYS_ROOT/bin/fogos_ram_optimizer.sh" && sudo chmod 755 "$SYS_ROOT/bin/fogos_ram_optimizer.sh"
    [ -f "patches/fogos_game_network.sh" ] && sudo cp patches/fogos_game_network.sh "$SYS_ROOT/bin/fogos_game_network.sh" && sudo chmod 755 "$SYS_ROOT/bin/fogos_game_network.sh"
    [ -f "patches/init.fogos.gaming.rc" ] && sudo cp patches/init.fogos.gaming.rc "$SYS_ROOT/etc/init/init.fogos.gaming.rc"
    [ -f "rootdir/init.fogos.rc" ] && sudo cp rootdir/init.fogos.rc "$SYS_ROOT/etc/init/init.fogos.rc"
    [ -f "patches/game_mode_config.xml" ] && sudo cp patches/game_mode_config.xml "$SYS_ROOT/etc/game_mode_config.xml"
    [ -f "patches/game_spoofing.xml" ] && sudo cp patches/game_spoofing.xml "$SYS_ROOT/etc/game_spoofing.xml"
    [ -f "sysconfig/gaming_power_whitelist.xml" ] && sudo cp sysconfig/gaming_power_whitelist.xml "$SYS_ROOT/etc/sysconfig/gaming_power_whitelist.xml"
    
    if [ -f "patches/fogos_gaming.prop" ]; then
        if [ -f "$SYS_ROOT/build.prop" ]; then
            sudo sh -c "cat patches/fogos_gaming.prop >> $SYS_ROOT/build.prop"
        elif [ -f "$SYS_ROOT/etc/build.prop" ]; then
            sudo sh -c "cat patches/fogos_gaming.prop >> $SYS_ROOT/etc/build.prop"
        fi
    fi
    
    # Package custom boot animation if not yet compiled
    if [ ! -f "prebuilt/bootanimation/bootanimation.zip" ] && [ -f "bootanimation/desc.txt" ]; then
        echo "[*] Packaging custom bootanimation.zip from frames..."
        mkdir -p prebuilt/bootanimation
        (cd bootanimation && zip -r -0 ../prebuilt/bootanimation/bootanimation.zip desc.txt part0/ part1/ part2/ part3/ 2>/dev/null || true)
    fi

    # Install custom boot animation into /system/media/
    if [ -f "prebuilt/bootanimation/bootanimation.zip" ]; then
        echo "[*] Installing VirgoX custom boot animation into /system/media/..."
        sudo mkdir -p "$SYS_ROOT/media"
        sudo cp "prebuilt/bootanimation/bootanimation.zip" "$SYS_ROOT/media/bootanimation.zip"
        sudo chmod 644 "$SYS_ROOT/media/bootanimation.zip"
    fi

    # Install custom wallpapers
    if [ -d "prebuilt/wallpapers" ]; then
        echo "[*] Installing VirgoX wallpapers..."
        sudo mkdir -p "$SYS_ROOT/media/wallpaper"
        sudo cp prebuilt/wallpapers/*.{jpg,png} "$SYS_ROOT/media/wallpaper/" 2>/dev/null || true
    fi
    
    sudo umount "$MNT_DIR"
    
    rm "$SYSTEM_IMG"
    img2simg "$WORK_DIR/extracted/system.raw.img" "$SYSTEM_IMG" || mv "$WORK_DIR/extracted/system.raw.img" "$SYSTEM_IMG"
    rm -f "$WORK_DIR/extracted/system.raw.img"
fi

SYS_EXT_IMG="$WORK_DIR/extracted/system_ext.img"
if [ -f "$SYS_EXT_IMG" ] && [ -f "system_ext.prop" ]; then
    echo "[*] Injecting configs into system_ext.img..."
    simg2img "$SYS_EXT_IMG" "$WORK_DIR/extracted/system_ext.raw.img" 2>/dev/null || cp "$SYS_EXT_IMG" "$WORK_DIR/extracted/system_ext.raw.img"
    sudo e2fsck -y -f "$WORK_DIR/extracted/system_ext.raw.img" || true
    truncate -s +20M "$WORK_DIR/extracted/system_ext.raw.img" 2>/dev/null || true
    sudo resize2fs "$WORK_DIR/extracted/system_ext.raw.img" || true
    
    MNT_EXT="$WORK_DIR/mnt_system_ext"
    mkdir -p "$MNT_EXT"
    sudo mount -o loop,rw "$WORK_DIR/extracted/system_ext.raw.img" "$MNT_EXT"
    
    if [ -f "$MNT_EXT/build.prop" ]; then
        sudo sh -c "cat system_ext.prop >> $MNT_EXT/build.prop"
    elif [ -f "$MNT_EXT/etc/build.prop" ]; then
        sudo sh -c "cat system_ext.prop >> $MNT_EXT/etc/build.prop"
    fi
    
    sudo umount "$MNT_EXT"
    
    rm "$SYS_EXT_IMG"
    img2simg "$WORK_DIR/extracted/system_ext.raw.img" "$SYS_EXT_IMG" || mv "$WORK_DIR/extracted/system_ext.raw.img" "$SYS_EXT_IMG"
    rm -f "$WORK_DIR/extracted/system_ext.raw.img"
fi

PRODUCT_IMG="$WORK_DIR/extracted/product.img"
if [ -f "$PRODUCT_IMG" ]; then
    echo "[*] Injecting boot animation and configs into product.img..."
    simg2img "$PRODUCT_IMG" "$WORK_DIR/extracted/product.raw.img" 2>/dev/null || cp "$PRODUCT_IMG" "$WORK_DIR/extracted/product.raw.img"
    sudo e2fsck -y -f "$WORK_DIR/extracted/product.raw.img" || true
    truncate -s +50M "$WORK_DIR/extracted/product.raw.img" 2>/dev/null || true
    sudo resize2fs "$WORK_DIR/extracted/product.raw.img" || true
    
    MNT_PROD="$WORK_DIR/mnt_product"
    mkdir -p "$MNT_PROD"
    sudo mount -o loop,rw "$WORK_DIR/extracted/product.raw.img" "$MNT_PROD"
    
    if [ -f "prebuilt/bootanimation/bootanimation.zip" ]; then
        sudo mkdir -p "$MNT_PROD/media"
        sudo cp "prebuilt/bootanimation/bootanimation.zip" "$MNT_PROD/media/bootanimation.zip"
        sudo chmod 644 "$MNT_PROD/media/bootanimation.zip"
    fi
    
    sudo umount "$MNT_PROD"
    
    rm "$PRODUCT_IMG"
    img2simg "$WORK_DIR/extracted/product.raw.img" "$PRODUCT_IMG" || mv "$WORK_DIR/extracted/product.raw.img" "$PRODUCT_IMG"
    rm -f "$WORK_DIR/extracted/product.raw.img"
fi

# Copy Flasher scripts
cp flasher/flash_all.bat "$OUT_DIR/"
cp flasher/flash_all.sh "$OUT_DIR/"
chmod +x "$OUT_DIR/flash_all.sh"

# Copy image files to output directory
echo "[6/7] Assembling flashable partition images..."
cp "$WORK_DIR"/extracted/*.img "$OUT_DIR/"

# 6. Create Fastboot Flashable ZIP
echo "[7/7] Packaging VirgoX Elite Gaming OS distribution..."
BUILD_DATE=$(date +'%Y%m%d')
VIRGOX_VERSION="1.0"
RELEASE_ZIP_NAME="VirgoX-Elite-GamingOS-v${VIRGOX_VERSION}-fogos-Android17-${BUILD_DATE}.zip"

cd "$OUT_DIR"
sha256sum *.img > SHA256SUMS.txt
zip -r -9 "../$RELEASE_ZIP_NAME" ./*

cd "$WORK_DIR/.."

echo "[8/9] Building VirgoX Sideload OTA package (adb sideload)..."
FOGOS_BASE_ZIP="$WORK_DIR/base_rom.zip" bash tools/make_sideload_ota.sh

# 9. Build Official Android A/B OTA package with payload.bin and correct structure
echo "[9/9] Assembling Official Android A/B OTA package with payload.bin..."
OTA_PKG_DIR="$WORK_DIR/official_ota"
mkdir -p "$OTA_PKG_DIR"
unzip -q -o "$WORK_DIR/base_rom.zip" "payload.bin" "payload_properties.txt" "care_map.pb" "apex_info.pb" "META-INF/*" -d "$OTA_PKG_DIR" || true

# Copy standalone payload.bin to output directory so users can download raw payload.bin directly
cp "$WORK_DIR/payload.bin" "$OUT_DIR/payload.bin"
[ -f "$OTA_PKG_DIR/payload_properties.txt" ] && cp "$OTA_PKG_DIR/payload_properties.txt" "$OUT_DIR/payload_properties.txt"

OFFICIAL_OTA_ZIP="VirgoX-Elite-GamingOS-v${VIRGOX_VERSION}-fogos-Android17-${BUILD_DATE}-Official-OTA.zip"
cd "$OTA_PKG_DIR"
zip -r -0 "../$OFFICIAL_OTA_ZIP" ./*
cd "$WORK_DIR/.."
mv "$WORK_DIR/$OFFICIAL_OTA_ZIP" "./$OFFICIAL_OTA_ZIP"

echo "=============================================================================="
echo "[SUCCESS] VirgoX Elite Gaming OS built successfully!"
echo "Fastboot package: $RELEASE_ZIP_NAME"
echo "Official OTA package (payload.bin): $OFFICIAL_OTA_ZIP"
echo "Sideload package: $(ls VirgoX-*-sideload.zip 2>/dev/null | head -n 1)"
echo "Standalone payload.bin: out/payload.bin"
echo "=============================================================================="
