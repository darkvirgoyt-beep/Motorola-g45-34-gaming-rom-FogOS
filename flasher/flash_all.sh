#!/usr/bin/env bash
set -e

# ==============================================================================
# VirgoX Elite Gaming OS Flasher - Motorola Moto G45 5G / G34 5G (fogos)
# Developer : Prince · VirgoYT (VirgoYT707)
# ==============================================================================

echo "=============================================================================="
echo "          VirgoX Elite Gaming OS for Motorola G45 / G34 5G"
echo "                   Maintained by: Prince · VirgoYT"
echo "=============================================================================="
echo ""

echo "[*] Checking Fastboot connection..."
if ! fastboot devices | grep -q 'fastboot'; then
    echo "[ERROR] No device found in fastboot mode."
    echo "Please connect your device in bootloader mode (Power + Volume Down)."
    exit 1
fi

echo "[OK] Device detected!"

echo "[*] Flashing VBMeta (disabling dm-verity and verification)..."
[ -f vbmeta.img ] && fastboot flash vbmeta vbmeta.img --disable-verity --disable-verification
[ -f vbmeta_system.img ] && fastboot flash vbmeta_system vbmeta_system.img --disable-verity --disable-verification

echo "[*] Flashing FogOS Gaming Kernel (VirgoYT) & Core Boot Partitions..."
[ -f boot.img ] && fastboot flash boot boot.img
[ -f vendor_boot.img ] && fastboot flash vendor_boot vendor_boot.img
[ -f dtbo.img ] && fastboot flash dtbo dtbo.img

echo "[*] Flashing Radio, Modem & DSP firmware..."
[ -f modem.img ] && fastboot flash modem modem.img --slot=all
[ -f bluetooth.img ] && fastboot flash bluetooth bluetooth.img --slot=all
[ -f dsp.img ] && fastboot flash dsp dsp.img --slot=all

echo "[*] Rebooting into fastbootd mode (userspace fastboot for super/dynamic partitions)..."
fastboot reboot fastboot
sleep 15

echo "[*] Flashing System, Vendor & Product partitions into super..."
if [ -f super.img ]; then
    echo "[*] Flashing unified super.img..."
    fastboot flash super super.img
else
    echo "[*] Flashing individual dynamic partitions directly into super partition..."
    [ -f system.img ] && fastboot flash system system.img
    [ -f system_ext.img ] && fastboot flash system_ext system_ext.img
    [ -f product.img ] && fastboot flash product product.img
    [ -f vendor.img ] && fastboot flash vendor vendor.img
    [ -f odm.img ] && fastboot flash odm odm.img
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
