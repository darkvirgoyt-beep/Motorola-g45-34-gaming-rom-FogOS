#!/bin/bash
# ==============================================================================
# FogOS Elite Gaming ROM - Source Compilation Script (fogos)
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

LINEAGE_DIR="${1:-$HOME/android/lineage}"

if [ ! -d "$LINEAGE_DIR" ]; then
    echo "[!] Lineage directory not found at $LINEAGE_DIR. Creating and initializing..."
    mkdir -p "$LINEAGE_DIR"
fi

cd "$LINEAGE_DIR"

echo "=== [2/4] Initializing Environment Setup ==="
source build/envsetup.sh
croot

echo "=== [3/4] Configuring Target Device: fogos ==="
breakfast fogos

echo "=== [4/4] Starting Full Build: mka bacon ==="
mka bacon -j"$(nproc)"

echo "=== [✓] FogOS Build Complete for Motorola G45 5G! ==="
