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
FPS=60

echo "=============================================="
echo "  VirgoX Elite GamingOS Boot Animation"
echo "  Resolution: ${WIDTH}x${HEIGHT} @ ${FPS}fps (960 Frames)"
echo "=============================================="

# Create desc.txt (Android boot animation descriptor)
cat > "$BOOT_DIR/desc.txt" << EOF
$WIDTH $HEIGHT $FPS
c 1 0 part0
c 1 0 part1
c 1 0 part2
c 0 0 part3
EOF

echo "[*] Created desc.txt"
echo "    Part 0: Neural Convergence (240 frames @ 60fps = 4s)"
echo "    Part 1: VX Monogram Synthesis (240 frames @ 60fps = 4s)"
echo "    Part 2: Holi SM6375 Turbo Ignition (240 frames @ 60fps = 4s)"
echo "    Part 3: Ultra Pulsing Core Loop (240 frames @ 60fps = 4s)"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Package into bootanimation.zip (must use STORED compression, no deflate)
cd "$BOOT_DIR"
zip -r -0 "$OUTPUT_DIR/bootanimation.zip" desc.txt part0/ part1/ part2/ part3/ 2>/dev/null

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
