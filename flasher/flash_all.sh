#!/usr/bin/env bash
set -e

# ==============================================================================
# FogOS Gaming ROM Flasher - Motorola Moto G45 5G / G34 5G (fogos)
# Developer : Prince · VirgoYT (VirgoYT707)
# ==============================================================================

echo "=============================================================================="
echo "             FogOS Gaming Edition for Motorola G45 / G34 5G"
echo "                  Maintained by: Prince · VirgoYT"
echo "=============================================================================="
echo ""

echo "[*] Checking Fastboot connection..."
if ! fastboot devices | grep -q 'fastboot'; then
    echo "[ERROR] No device found in fastboot mode."
    echo "Please connect your device in bootloader mode (Power + Volume Down)."
    exit 1
fi

echo "[OK] Device detected!"
echo "[*] Flashing FogOS Gaming Kernel (VirgoYT)..."
fastboot flash boot boot.img
[ -f vendor_boot.img ] && fastboot flash vendor_boot vendor_boot.img
[ -f dtbo.img ] && fastboot flash dtbo dtbo.img

echo "[*] Rebooting into fastbootd mode..."
fastboot reboot fastboot
sleep 5

echo "[*] Flashing dynamic partitions..."
if [ -f super.img ]; then
    fastboot flash super super.img
else
    [ -f system.img ] && fastboot flash system system.img
    [ -f system_ext.img ] && fastboot flash system_ext system_ext.img
    [ -f product.img ] && fastboot flash product product.img
    [ -f vendor.img ] && fastboot flash vendor vendor.img
fi

echo ""
read -p "[*] Format userdata/factory reset? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    fastboot -w
fi

echo "[*] Rebooting to system..."
fastboot reboot
echo "[*] Done! Powered by Prince · VirgoYT."
