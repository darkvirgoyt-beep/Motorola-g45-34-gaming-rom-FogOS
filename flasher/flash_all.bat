@echo off
color 0b
title FogOS Elite Gaming Flasher - Moto G45 5G (fogos)
echo ==============================================================================
echo           FogOS Elite Gaming Edition for Motorola G45 / G34 5G
echo                   Maintained by: Prince . VirgoYT
echo ==============================================================================
echo.
echo [*] Checking Fastboot connection...
fastboot devices > devices.txt
findstr /R "." devices.txt > nul
if errorlevel 1 (
    color 0c
    echo [ERROR] No device detected in Fastboot mode!
    echo Please connect your Motorola G45 5G in bootloader mode (Power + Vol Down).
    del devices.txt
    pause
    exit /b 1
)
del devices.txt
echo [OK] Device detected!
echo.

echo [*] Flashing VBMeta with dm-verity and verification disabled...
if exist vbmeta.img (
    fastboot flash vbmeta vbmeta.img --disable-verity --disable-verification
)
if exist vbmeta_system.img (
    fastboot flash vbmeta_system vbmeta_system.img --disable-verity --disable-verification
)

echo.
echo [*] Flashing FogOS Gaming Kernel (VirgoYT) & Core Partitions...
fastboot flash boot boot.img
if exist vendor_boot.img fastboot flash vendor_boot vendor_boot.img
if exist dtbo.img fastboot flash dtbo dtbo.img

echo.
echo [*] Rebooting to fastbootd mode for dynamic partitions...
fastboot reboot fastboot
echo Waiting 5 seconds for fastbootd...
timeout /t 5 /nobreak > nul

echo.
echo [*] Flashing System and Vendor dynamic partitions...
if exist super.img (
    fastboot flash super super.img
) else (
    if exist system.img fastboot flash system system.img
    if exist system_ext.img fastboot flash system_ext system_ext.img
    if exist product.img fastboot flash product product.img
    if exist vendor.img fastboot flash vendor vendor.img
)

echo.
echo ==============================================================================
echo [*] Flashing complete!
echo.
set /p WIPE="[*] Do you want to format userdata/factory reset? (Recommended for 1st flash) [Y/N]: "
if /i "%WIPE%"=="Y" (
    echo [*] Formatting userdata...
    fastboot erase userdata
    fastboot -w
)

echo.
echo [*] Rebooting device into FogOS Gaming ROM...
fastboot reboot
echo.
echo Enjoy ultra-smooth gaming and Play Integrity support on your Moto G45!
echo Credits to Prince . VirgoYT.
pause
