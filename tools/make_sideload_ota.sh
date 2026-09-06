#!/usr/bin/env bash
set -e

# ==============================================================================
# FogOS Elite Gaming Sideload OTA Builder - Motorola Moto G45 5G / G34 5G (fogos)
# Builds a FULL sideloadable OTA for `adb sideload` ("Apply update from ADB"):
#   - Base ROM payload.bin + stock update-binary  -> installs the whole system
#   - FogOS gaming kernel (boot/vendor_boot/dtbo) -> flashed after payload
#   - FogOS gaming configs                        -> installed to /data/fogos
#   - PlayIntegrityFix module                     -> bundled in modules/
# Developer : Prince · VirgoYT (VirgoYT707)
# ==============================================================================

OUT_DIR="$(pwd)/out"
WORK_DIR="$(pwd)/workspace"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_DIR="$WORK_DIR/sideload"
BUILD_DATE=$(date +'%Y%m%d')
ZIP_NAME="VirgoX-v1.0-EliteGaming-fogos-VirgoYT-${BUILD_DATE}-sideload.zip"

BASE_ZIP="${FOGOS_BASE_ZIP:-$WORK_DIR/base_rom.zip}"

if [ ! -f "$BASE_ZIP" ]; then
    echo "[!] Base ROM OTA not found: $BASE_ZIP"
    echo "    FOGOS_BASE_ZIP can point to the base LineageOS OTA zip."
    exit 1
fi

echo "=============================================================================="
echo "  Building VirgoX FULL Sideload OTA (payload.bin + kernel + configs)"
echo "  Base OTA: $(basename "$BASE_ZIP")"
echo "=============================================================================="

rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR/META-INF/com/google/android" \
         "$PKG_DIR/META-INF/com/android" \
         "$PKG_DIR/config" \
         "$PKG_DIR/modules"

# ------------------------------------------------------------------------------
# 1. Adopt the base ROM OTA payload & dynamic-partition update machinery
# ------------------------------------------------------------------------------
echo "[*] Adopting base OTA payload files..."
for f in payload.bin payload_metadata.bin payload_properties.txt care_map.pb otacerts.zip; do
    if unzip -l "$BASE_ZIP" "$f" >/dev/null 2>&1; then
        unzip -o -j "$BASE_ZIP" "$f" -d "$PKG_DIR/" >/dev/null
        echo "    [+] $f"
    fi
done

unzip -o -j "$BASE_ZIP" "META-INF/com/android/metadata" -d "$PKG_DIR/META-INF/com/android/" >/dev/null 2>&1 || true
unzip -o -j "$BASE_ZIP" "META-INF/com/google/android/update-binary" \
    -d "$PKG_DIR/META-INF/com/google/android/" >/dev/null 2>&1 || true
mv "$PKG_DIR/META-INF/com/google/android/update-binary" \
   "$PKG_DIR/META-INF/com/google/android/update-binary.stock" 2>/dev/null || \
   echo "[!] No stock update-binary found; wrapper will only flash kernel + configs."

chmod 0755 "$PKG_DIR/META-INF/com/google/android/update-binary.stock" 2>/dev/null || true

# ------------------------------------------------------------------------------
# 2. Kernel / boot images
# ------------------------------------------------------------------------------
for img in boot vendor_boot dtbo; do
    if [ -f "$OUT_DIR/$img.img" ]; then
        cp "$OUT_DIR/$img.img" "$PKG_DIR/"
        echo "[*] Packing $img.img"
    fi
done

# ------------------------------------------------------------------------------
# 3. FogOS gaming configs + PlayIntegrityFix module
# ------------------------------------------------------------------------------
if [ -d "$OUT_DIR/config" ]; then
    cp "$OUT_DIR"/config/* "$PKG_DIR/config/"
fi
if [ -f "$OUT_DIR/modules/PlayIntegrityFix.zip" ]; then
    cp "$OUT_DIR/modules/PlayIntegrityFix.zip" "$PKG_DIR/modules/"
    echo "[*] Packing modules/PlayIntegrityFix.zip"
fi

# ------------------------------------------------------------------------------
# 4. Wrapper update-binary (applies payload, then flashes FogOS layer)
# ------------------------------------------------------------------------------
STOCK_PRESENT=0
[ -f "$PKG_DIR/META-INF/com/google/android/update-binary.stock" ] && STOCK_PRESENT=1

WRAPPER="$PKG_DIR/META-INF/com/google/android/update-binary"
cat > "$WRAPPER" <<'WRAPEOF'
#!/sbin/sh
# FogOS Elite Gaming update-binary (wrapper)
# $1 = recovery API version, $2 = ui fd, $3 = zip path
OUTFD=$2
ZIP=$3
TMP=/tmp/fogos

ui() {
    echo "ui_print $*" >&$OUTFD
    echo "ui_print" >&$OUTFD
}

ui ""
ui "============================================="
ui " VirgoX Elite Gaming OS - fogos (G45/G34)"
ui " Developer: Prince . VirgoYT"
ui "============================================="
ui ""

mkdir -p $TMP

# --- stage 1: apply stock payload (full system OTA) ---
# unzip the .stock binary from package into $TMP and run it
STOCKBIN=$TMP/update-binary.stock
unzip -o -j "$ZIP" "META-INF/com/google/android/update-binary.stock" -d $TMP >/dev/null 2>&1
if [ -f "$STOCKBIN" ]; then
    chmod 0755 $STOCKBIN
    ui "Installing FogOS system partitions from payload..."
    $STOCKBIN "$1" "$OUTFD" "$ZIP"
    RC=$?
    if [ $RC -ne 0 ]; then
        ui "ERROR: payload update failed (rc=$RC)"
        exit 1
    fi
    ui "System image installed."
else
    ui "WARNING: no stock update-binary found; skipping payload. Kernel + configs only."
fi

ui ""
ui "Flashing FogOS Gaming Kernel..."

# --- stage 2: flash FogOS gaming kernel ---
for img in boot vendor_boot dtbo; do
    if unzip -l "$ZIP" "$img.img" >/dev/null 2>&1; then
        unzip -o -j "$ZIP" "$img.img" -d $TMP >/dev/null 2>&1
        ui "  Flashing $img..."
        dd if=$TMP/$img.img of=/dev/block/by-name/$img bs=4096 2>/dev/null
    fi
done

# --- stage 3: install FogOS configs + PlayIntegrityFix to /data/fogos ---
ui "Installing FogOS configs to /data/fogos..."
mkdir -p /data/fogos/modules
unzip -o "$ZIP" "config/*" -d /data/fogos >/dev/null 2>&1 || true
chmod -R 0755 /data/fogos 2>/dev/null || true

if unzip -l "$ZIP" "modules/*" >/dev/null 2>&1; then
    unzip -o -j "$ZIP" "modules/PlayIntegrityFix.zip" -d /data/fogos/modules >/dev/null 2>&1 || true
    ui "PlayIntegrityFix module saved to /data/fogos/modules/"
fi

ui ""
ui "Done! Rebooting into FogOS Elite Gaming."
ui "Powered by Prince . VirgoYT"
exit 0
WRAPEOF
chmod 0755 "$WRAPPER"

echo "[*] Generated wrapper update-binary:"
head -5 "$WRAPPER"

# ------------------------------------------------------------------------------
# 5. Metadata sanity (keep base OTA metadata for the applied system build)
# ------------------------------------------------------------------------------
if [ ! -f "$PKG_DIR/META-INF/com/android/metadata" ]; then
    cat > "$PKG_DIR/META-INF/com/android/metadata" <<'EOF'
device=fogos
pre-device=fogos
EOF
    echo "[*] Wrote fallback metadata"
fi

# ------------------------------------------------------------------------------
# 6. Zip it up (into repo root so the release workflow can collect it)
# ------------------------------------------------------------------------------
cd "$PKG_DIR"
rm -f "$ROOT_DIR/$ZIP_NAME"
zip -r -9 "$ROOT_DIR/$ZIP_NAME" . >/dev/null
cd "$ROOT_DIR"

SIZE=$(du -h "$ZIP_NAME" | cut -f1)
echo "=============================================================================="
echo "[SUCCESS] FogOS FULL Sideload OTA: $ZIP_NAME ($SIZE)"
echo "Flash with: adb sideload $ZIP_NAME"
echo "=============================================================================="