#!/usr/bin/env bash
set -e

# ==============================================================================
# FogOS Recovery Sideload Flasher - Motorola Moto G45 5G / G34 5G (fogos)
# Developer : Prince · VirgoYT (VirgoYT707)
# ==============================================================================

ROM_ZIP="$1"

if [ -z "$ROM_ZIP" ]; then
    ROM_ZIP=$(ls FogOS-*.zip 2>/dev/null | head -n 1)
fi

if [ ! -f "$ROM_ZIP" ]; then
    echo "[ERROR] No FogOS ROM zip specified or found in current directory!"
    echo "Usage: ./scripts/recovery_sideload.sh <path-to-FogOS-ROM.zip>"
    exit 1
fi

echo "=============================================================================="
echo "         FogOS Recovery Sideload Installer for Moto G45 (fogos)"
echo "                   Maintained by: Prince · VirgoYT"
echo "=============================================================================="
echo ""
echo "[1/4] Checking device in Fastboot mode..."
if ! fastboot devices | grep -q 'fastboot'; then
    echo "[ERROR] Device not found in fastboot mode. Connect phone in bootloader!"
    exit 1
fi

echo "[2/4] Flashing FogOS Gaming Kernel boot image..."
[ -f boot.img ] && fastboot flash boot boot.img
[ -f vendor_boot.img ] && fastboot flash vendor_boot vendor_boot.img
[ -f dtbo.img ] && fastboot flash dtbo dtbo.img

echo "[3/4] Rebooting into Lineage / FogOS Recovery..."
fastboot reboot recovery

echo ""
echo "=============================================================================="
echo " ACTION REQUIRED ON YOUR PHONE SCREEN:"
echo " 1. Select 'Factory reset' -> 'Format data/factory reset'"
echo " 2. Return to Main Menu -> Select 'Apply update' -> 'Apply from ADB'"
echo "=============================================================================="
read -p "Press [Enter] once your phone shows 'Now send the package you want to apply'..."

echo "[4/4] Sideloading $ROM_ZIP..."
adb sideload "$ROM_ZIP"

echo ""
echo "[SUCCESS] Flashing complete! Select 'Reboot system now' in Recovery."
echo "Powered by Prince · VirgoYT."
