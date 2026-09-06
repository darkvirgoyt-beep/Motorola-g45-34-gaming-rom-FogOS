#!/usr/bin/env bash
set -e

# ==============================================================================
# FogOS Elite Gaming Sideload OTA Builder - Motorola Moto G45 5G / G34 5G (fogos)
# Produces a TWRP / Lineage-recovery flashable package for `adb sideload`
# ("Apply update from ADB"). Flashes the certified gaming kernel images and
# installs FogOS gaming configs for PulseControl - no dynamic partitions touched.
# Developer : Prince · VirgoYT (VirgoYT707)
# ==============================================================================

OUT_DIR="$(pwd)/out"
WORK_DIR="$(pwd)/workspace"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_DIR="$WORK_DIR/sideload"
BUILD_DATE=$(date +'%Y%m%d')
ZIP_NAME="FogOS-v1.0-EliteGaming-fogos-VirgoYT-${BUILD_DATE}-sideload.zip"

echo "=============================================================================="
echo "  Building FogOS Sideload OTA Package (adb apply update compatible)"
echo "=============================================================================="

rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR/META-INF/com/google/android" \
         "$PKG_DIR/META-INF/com/android" \
         "$PKG_DIR/config"

# ------------------------------------------------------------------------------
# 1. Kernel / boot images (recovery-safe physical partitions only)
# ------------------------------------------------------------------------------
IMAGES=()
for img in boot vendor_boot dtbo; do
    if [ -f "$OUT_DIR/$img.img" ]; then
        cp "$OUT_DIR/$img.img" "$PKG_DIR/"
        IMAGES+=("$img")
        echo "[*] Packing $img.img"
    fi
done

if [ "${#IMAGES[@]}" -eq 0 ]; then
    echo "[!] No boot images found in $OUT_DIR, aborting sideload build."
    exit 1
fi

# ------------------------------------------------------------------------------
# 2. FogOS gaming configs (installed to /data/fogos for PulseControl/manual apply)
# ------------------------------------------------------------------------------
if [ -d "$OUT_DIR/config" ]; then
    cp "$OUT_DIR"/config/* "$PKG_DIR/config/"
fi

# ------------------------------------------------------------------------------
# 3. OTA metadata
# ------------------------------------------------------------------------------
cat > "$PKG_DIR/META-INF/com/android/metadata" <<'EOF'
device=fogos
pre-device=fogos
EOF

# ------------------------------------------------------------------------------
# 4. updater-script (edify)
# ------------------------------------------------------------------------------
SCRIPT="$PKG_DIR/META-INF/com/google/android/updater-script"
{
    echo 'ui_print("");'
    echo 'ui_print("=============================================");'
    echo 'ui_print(" FogOS Elite Gaming Edition - fogos (G45/G34)");'
    echo 'ui_print(" Developer: Prince . VirgoYT");'
    echo 'ui_print("=============================================");'
    echo 'ui_print("");'
    echo 'report_progress(0.2);'
    echo 'assert(getprop("ro.product.device") == "fogos" ||'
    echo '       abort("E3004: This package is for fogos (Moto G45/G34 5G); this is " + getprop("ro.product.device") + "."););'
    echo '# -------------------- kernel images --------------------'
    for img in "${IMAGES[@]}"; do
        echo "ui_print(\"Flashing FogOS $img...\");"
        echo "package_extract_file(\"$img.img\", \"/dev/block/by-name/$img\");"
    done
    echo '# -------------------- gaming configs --------------------'
    echo 'ui_print("Installing FogOS gaming configs to /data/fogos...");'
    echo 'package_extract_dir("config", "/data/fogos");'
    echo 'set_metadata_recursive("/data/fogos", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0755, "capabilities", 0x0);'
    echo 'ui_print("");'
    echo 'ui_print("Done! Reboot and launch PulseControl to apply the Gaming profile.");'
    echo 'ui_print("Powered by Prince . VirgoYT");'
} > "$SCRIPT"

echo "[*] Generated updater-script:"
cat "$SCRIPT"

# ------------------------------------------------------------------------------
# 5. Zip it up (into repo root so the release workflow can collect it)
# ------------------------------------------------------------------------------
cd "$PKG_DIR"
rm -f "$ROOT_DIR/$ZIP_NAME"
zip -r -9 "$ROOT_DIR/$ZIP_NAME" META-INF *.img config >/dev/null
cd "$ROOT_DIR"

SIZE=$(du -h "$ZIP_NAME" | cut -f1)
echo "=============================================================================="
echo "[SUCCESS] Sideload OTA: $ZIP_NAME ($SIZE)"
echo "Flash with: adb sideload $ZIP_NAME"
echo "=============================================================================="