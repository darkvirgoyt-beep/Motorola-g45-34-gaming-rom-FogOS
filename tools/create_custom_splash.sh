#!/usr/bin/env bash
# ==============================================================================
# 🛡️ VirgoX Elite Splash Screen Customizer — Motorola Moto G45 5G / G34 5G (fogos)
# Developer : Prince · VirgoYT (VirgoYT707)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_LOGO_DIR="$SCRIPT_DIR/logo/base_logo"
BUILD_LOGO_PY="$SCRIPT_DIR/logo/build_logo.py"

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_RESET='\033[0m'
C_BOLD='\033[1m'

echo -e "${C_CYAN}==============================================================================${C_RESET}"
echo -e "${C_BOLD}     ⚡ VIRGOX ELITE SPLASH SCREEN (BOOT LOGO) CUSTOMIZER ⚡${C_RESET}"
echo -e " Target Device : Motorola Moto G45 5G / G34 5G (fogos / SM6375)"
echo -e " Resolution    : 720 × 1600 (Aspect Ratio 20:9)"
echo -e " Features      : Eliminates Unlocked Bootloader Warning Screens"
echo -e "${C_CYAN}==============================================================================${C_RESET}"

INPUT_IMAGE="$1"
OUTPUT_DIR="${2:-$SCRIPT_DIR/../out/custom_splash}"

if [ -z "$INPUT_IMAGE" ]; then
    echo -e "${C_YELLOW}[*] No input image provided. Please enter path to your custom splash image (PNG, JPG, WEBP):${C_RESET}"
    read -rp " Image path: " INPUT_IMAGE
fi

if [ ! -f "$INPUT_IMAGE" ]; then
    echo -e "${C_RED}[ERROR] Image file not found: $INPUT_IMAGE${C_RESET}"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
OUTPUT_BIN="$OUTPUT_DIR/logo.bin"
OUTPUT_IMG="$OUTPUT_DIR/logo.img"

echo -e "\n${C_GREEN}[1/3] Validating Python environment and dependencies...${C_RESET}"
python3 -c "from PIL import Image" 2>/dev/null || {
    echo -e "${C_YELLOW}[*] Installing Pillow...${C_RESET}"
    pip3 install Pillow
}

echo -e "${C_GREEN}[2/3] Building custom Motorola logo partition container...${C_RESET}"
python3 "$BUILD_LOGO_PY" "$INPUT_IMAGE" "$BASE_LOGO_DIR" "$OUTPUT_BIN"
cp "$OUTPUT_BIN" "$OUTPUT_IMG"

echo -e "\n${C_GREEN}[3/3] Creating one-click fastboot flasher scripts...${C_RESET}"

# Create Linux/Mac flasher
cat << 'FLASHER_SH' > "$OUTPUT_DIR/flash_splash.sh"
#!/usr/bin/env bash
set -e
echo "=================================================================="
echo "⚡ Flashing VirgoX Custom Splash Screen (Boot Logo)..."
echo "=================================================================="
if ! fastboot devices | grep -q 'fastboot'; then
    echo "[!] Error: No device detected in bootloader/fastboot mode."
    echo "    Connect phone with Power + Volume Down held."
    exit 1
fi
echo "[*] Flashing logo partition..."
fastboot flash logo logo.bin
echo "[✓] Splash screen flashed successfully! Rebooting..."
fastboot reboot
FLASHER_SH
chmod +x "$OUTPUT_DIR/flash_splash.sh"

# Create Windows flasher
cat << 'FLASHER_BAT' > "$OUTPUT_DIR/flash_splash.bat"
@echo off
color 0b
echo ==================================================================
echo ⚡ Flashing VirgoX Custom Splash Screen (Boot Logo)...
echo ==================================================================
fastboot devices > nul 2>&1
if errorlevel 1 (
    color 0c
    echo [!] Error: No device detected in fastboot mode.
    pause
    exit /b 1
)
fastboot flash logo logo.bin
echo [✓] Splash screen flashed successfully! Rebooting...
fastboot reboot
pause
FLASHER_BAT

echo -e "${C_CYAN}==============================================================================${C_RESET}"
echo -e "${C_GREEN}🎉 Custom Splash Screen built successfully!${C_RESET}"
echo -e " Output files in: ${C_BOLD}$OUTPUT_DIR${C_RESET}"
echo -e "  - ${C_YELLOW}logo.bin${C_RESET} (Raw Motorola logo partition)"
echo -e "  - ${C_YELLOW}logo.img${C_RESET} (Fastboot image)"
echo -e "  - ${C_YELLOW}flash_splash.sh / .bat${C_RESET} (1-click fastboot flashers)"
echo -e "\nTo flash right now via Fastboot:"
echo -e "  ${C_BOLD}cd $OUTPUT_DIR && ./flash_splash.sh${C_RESET}"
echo -e "${C_CYAN}==============================================================================${C_RESET}"
