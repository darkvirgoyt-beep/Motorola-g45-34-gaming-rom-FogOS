#!/bin/bash
# ==============================================================================
# VirgoX-Elite-GamingOS-Rom Source Compilation Script (fogos)
# Developer: Prince · VirgoYT (VirgoYT707)
# ==============================================================================
set -e

echo "=== [1/4] Setting up FogOS Build Environment ==="
export BUILD_USERNAME=VirgoYT
export BUILD_HOSTNAME=fogos-build
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR=~/.ccache
export USE_CCACHE=1

ccache -M 50G
ccache -o compression=true

PROJECT_ROOT="$PWD"
LINEAGE_DIR="${1:-$HOME/android/lineage}"

if [ ! -d "$LINEAGE_DIR" ]; then
    echo "[!] Lineage directory not found at $LINEAGE_DIR. Creating..."
    mkdir -p "$LINEAGE_DIR"
fi

cd "$LINEAGE_DIR"

if [ ! -f "build/envsetup.sh" ]; then
    echo "=== [2/4] Initializing and Syncing LineageOS Source ==="
    ROM_BASE_BRANCH="${ROM_BASE_BRANCH:-lineage-23.2}"
    repo init -u https://github.com/LineageOS/android.git -b "$ROM_BASE_BRANCH" --depth=1
    mkdir -p .repo/local_manifests
    cp "$PROJECT_ROOT/manifests/fogos.xml" .repo/local_manifests/fogos.xml 2>/dev/null || true
    repo sync -c -j"$(nproc)" --force-sync --no-clone-bundle --no-tags
else
    echo "=== [2/4] Source tree found. Skipping sync. ==="
fi

echo "=== [3/4] Copying Device Configurations ==="
mkdir -p device/motorola/fogos/overlay
mkdir -p device/motorola/fogos/rootdir
mkdir -p device/motorola/fogos/patches
mkdir -p device/motorola/fogos/sysconfig
mkdir -p device/motorola/fogos/virgox/sepolicy
mkdir -p device/motorola/fogos/virgox

cp -r "$PROJECT_ROOT/overlay/"* device/motorola/fogos/overlay/ 2>/dev/null || true
cp -r "$PROJECT_ROOT/rootdir/"* device/motorola/fogos/rootdir/ 2>/dev/null || true
cp "$PROJECT_ROOT/system_ext.prop" device/motorola/fogos/system_ext.prop 2>/dev/null || true
cp -r "$PROJECT_ROOT/patches/"* device/motorola/fogos/patches/ 2>/dev/null || true
cp -r "$PROJECT_ROOT/sysconfig/"* device/motorola/fogos/sysconfig/ 2>/dev/null || true
cp "$PROJECT_ROOT/virgox/product/virgox_fogos.mk" device/motorola/fogos/virgox_fogos.mk
cp "$PROJECT_ROOT/virgox/gaming_profiles.json" device/motorola/fogos/virgox/gaming_profiles.json
cp "$PROJECT_ROOT/virgox/sepolicy/"* device/motorola/fogos/virgox/sepolicy/
# Register the product only if the device tree exposes the standard product list.
if grep -q 'lineage_fogos.mk' device/motorola/fogos/AndroidProducts.mk; then
    grep -q 'virgox_fogos.mk' device/motorola/fogos/AndroidProducts.mk || sed -i 's#$(LOCAL_DIR)/lineage_fogos.mk#$(LOCAL_DIR)/lineage_fogos.mk \\\n    $(LOCAL_DIR)/virgox_fogos.mk#' device/motorola/fogos/AndroidProducts.mk
fi

echo "=== [4/4] Starting Full Build ==="
source build/envsetup.sh
lunch virgox_fogos-userdebug
mka bacon -j"$(nproc)"

echo "=== [✓] FogOS Build Complete for Motorola G45 5G! ==="
