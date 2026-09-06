#!/usr/bin/env bash
# ==============================================================================
# VirgoX Elite GamingOS — Boot Animation Generator
# Creates bootanimation.zip from PNG frame sequences
# Developer: Prince · VirgoYT (VirgoYT707)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BOOT_DIR="$SCRIPT_DIR"
OUTPUT_DIR="$(dirname "$SCRIPT_DIR")/prebuilt/bootanimation"

# ── Boot Animation Resolution ──
# Moto G45 5G: 720x1600 (HD+ LCD)
# We use the display width x height
WIDTH=720
HEIGHT=1600
FPS=30

echo "=============================================="
echo "  VirgoX Elite GamingOS Boot Animation"
echo "  Resolution: ${WIDTH}x${HEIGHT} @ ${FPS}fps"
echo "=============================================="

# Validate frame directories
if [ ! -d "$BOOT_DIR/part0" ] || [ -z "$(ls "$BOOT_DIR/part0"/*.png 2>/dev/null)" ]; then
    echo "[!] ERROR: No PNG frames found in bootanimation/part0/"
    echo "    Add your intro animation frames as sequential PNGs:"
    echo "    part0/frame_0000.png, frame_0001.png, ..."
    echo ""
    echo "    Frame specs:"
    echo "    - Resolution: ${WIDTH}x${HEIGHT}"
    echo "    - Format: PNG (RGBA or RGB)"
    echo "    - Naming: Sequential numbering"
    exit 1
fi

# Create desc.txt (Android boot animation descriptor)
# Format: WIDTH HEIGHT FPS
# Then for each part: type count pause [path]
#   type: p = play part, c = complete (play once then stop)
#   count: 0 = infinite loop, N = play N times
#   pause: frames to pause after this part
cat > "$BOOT_DIR/desc.txt" << EOF
$WIDTH $HEIGHT $FPS
c 1 0 part0
c 0 0 part1
EOF

echo "[*] Created desc.txt"
echo "    Part 0: Intro (plays once)"
echo "    Part 1: Loop (repeats until boot completes)"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Package into bootanimation.zip (must use STORED compression, no deflate)
cd "$BOOT_DIR"
zip -r -0 "$OUTPUT_DIR/bootanimation.zip" desc.txt part0/ part1/ 2>/dev/null

FINAL_SIZE=$(du -h "$OUTPUT_DIR/bootanimation.zip" | cut -f1)
echo ""
echo "[✓] Boot animation packaged successfully!"
echo "    Output: $OUTPUT_DIR/bootanimation.zip ($FINAL_SIZE)"
echo "    Install path: /system/product/media/bootanimation.zip"
echo ""
echo "    To test on device:"
echo "    adb push bootanimation.zip /data/local/tmp/"
echo "    adb shell setprop ctl.stop bootanim"
echo "    adb shell setprop persist.bootanimation.file /data/local/tmp/bootanimation.zip"
echo "    adb shell setprop ctl.start bootanim"
