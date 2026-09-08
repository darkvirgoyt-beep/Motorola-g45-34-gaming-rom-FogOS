@echo off
title VirgoX Elite Gaming OS - Custom Boot Splash Flasher (Prince · VirgoYT)
echo ==============================================================================
echo    VirgoX Elite Gaming OS - Custom Boot Splash ^& Bootloader Warning Remover
echo            For Motorola Moto G45 5G / Moto G34 5G (fogos / SM6375)
echo                    Maintained by: Prince · VirgoYT
echo ==============================================================================
echo.

echo [*] Checking Fastboot connection...
fastboot devices | findstr /i "fastboot" > nul
if %errorlevel% neq 0 (
    echo [ERROR] No device detected in Fastboot mode!
    echo Please connect your Motorola device in Bootloader mode (Power + Vol Down).
    pause
    exit /b 1
)

echo [OK] Device detected!
echo [*] Flashing VirgoX Ultra-Premium Cyberpunk Boot Splash to 'logo' partition...
if exist logo.bin (
    fastboot flash logo logo.bin
) else if exist logo.img (
    fastboot flash logo logo.img
) else (
    echo [ERROR] logo.bin or logo.img not found in the current folder!
    pause
    exit /b 1
)

if %errorlevel% neq 0 (
    echo [ERROR] Flashing to logo partition failed!
    pause
    exit /b 1
)

echo [*] Rebooting device into system...
fastboot reboot
echo.
echo ==============================================================================
echo [SUCCESS] Unlocked bootloader warning eliminated! Enjoy VirgoX Elite Gaming OS.
echo                         Powered by Prince · VirgoYT
echo ==============================================================================
pause
