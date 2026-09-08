#!/usr/bin/env bash
set -e

# ==============================================================================
# VirgoX Elite Gaming OS - Custom Boot Splash & Bootloader Warning Remover
# For Motorola Moto G45 5G / Moto G34 5G (fogos / SM6375)
# Developer : Prince · VirgoYT (VirgoYT707)
# ==============================================================================

echo "=============================================================================="
echo "   VirgoX Elite Gaming OS - Custom Boot Splash & Bootloader Warning Remover"
echo "           For Motorola Moto G45 5G / Moto G34 5G (fogos / SM6375)"
echo "                   Maintained by: Prince · VirgoYT"
echo "=============================================================================="
echo ""

echo "[*] Checking Fastboot connection..."
if ! fastboot devices | grep -q 'fastboot'; then
    echo "[ERROR] No device found in fastboot mode."
    echo "Please connect your device in bootloader mode (Hold Power + Volume Down)."
    exit 1
fi

echo "[OK] Device detected!"
echo "[*] Flashing VirgoX Ultra-Premium Cyberpunk Boot Splash to 'logo' partition..."
if [ -f logo.bin ]; then
    fastboot flash logo logo.bin
elif [ -f logo.img ]; then
    fastboot flash logo logo.img
else
    echo "[ERROR] logo.bin / logo.img not found in current directory!"
    exit 1
fi

echo "[*] Rebooting device into system..."
fastboot reboot
echo ""
echo "=============================================================================="
echo "[SUCCESS] Bootloader warning screen eliminated! Enjoy VirgoX Elite Gaming OS."
echo "                       Powered by Prince · VirgoYT"
echo "=============================================================================="
