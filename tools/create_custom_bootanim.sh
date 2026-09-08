#!/usr/bin/env bash
# ==============================================================================
# 🎬 VirgoX Boot Animation Creator — Motorola Moto G45 5G / G34 5G (fogos)
# Developer : Prince · VirgoYT (VirgoYT707)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_W=720
TARGET_H=1600

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_RESET='\033[0m'
C_BOLD='\033[1m'

echo -e "${C_CYAN}==============================================================================${C_RESET}"
echo -e "${C_BOLD}        ⚡ VIRGOX ELITE CUSTOM BOOT ANIMATION CREATOR ⚡${C_RESET}"
echo -e " Target Device : Motorola Moto G45 5G / G34 5G (fogos)"
echo -e " Target Spec   : 720 × 1600 (20:9 Aspect Ratio) · 60 FPS / 120 FPS"
echo -e "${C_CYAN}==============================================================================${C_RESET}"

INPUT_FILE="$1"
FPS="${2:-120}"
OUTPUT_ZIP="${3:-$SCRIPT_DIR/../out/custom_bootanimation/bootanimation.zip}"

if [ -z "$INPUT_FILE" ]; then
    echo -e "${C_YELLOW}[*] Please enter path to source video (mp4, mkv, webm) or frames directory:${C_RESET}"
    read -rp " Source path: " INPUT_FILE
    echo -e "${C_YELLOW}[*] Select frame rate [60 or 120]:${C_RESET}"
    read -rp " FPS [default 120]: " USER_FPS
    [ -n "$USER_FPS" ] && FPS="$USER_FPS"
fi

if [ ! -e "$INPUT_FILE" ]; then
    echo -e "${C_RED}[ERROR] Source not found: $INPUT_FILE${C_RESET}"
    exit 1
fi

WORK_DIR="/tmp/virgox_bootanim_build"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR/part0"

mkdir -p "$(dirname "$OUTPUT_ZIP")"

if [ -f "$INPUT_FILE" ]; then
    echo -e "\n${C_GREEN}[1/4] Extracting boot sound audio track (if available)...${C_RESET}"
    ffmpeg -y -i "$INPUT_FILE" -vn -acodec pcm_s16le -ar 44100 -ac 2 "$WORK_DIR/audio.wav" 2>/dev/null || true

    echo -e "${C_GREEN}[2/4] Rendering frames at ${FPS} FPS scaled to 720×1600...${C_RESET}"
    VF="scale=${TARGET_W}:${TARGET_H}:force_original_aspect_ratio=increase,crop=${TARGET_W}:${TARGET_H},fps=${FPS}"
    ffmpeg -y -i "$INPUT_FILE" -vf "$VF" "$WORK_DIR/part0/frame_%05d.png"

elif [ -d "$INPUT_FILE" ]; then
    echo -e "\n${C_GREEN}[1/4] Copying and sizing frames from directory...${C_RESET}"
    cp -r "$INPUT_FILE"/* "$WORK_DIR/part0/"
fi

FRAME_COUNT=$(find "$WORK_DIR/part0" -name "*.png" | wc -l)
echo -e "${C_GREEN}[✓] Total frames generated: ${FRAME_COUNT} frames${C_RESET}"

echo -e "${C_GREEN}[3/4] Generating Android desc.txt config...${C_RESET}"
cat << DESC > "$WORK_DIR/desc.txt"
${TARGET_W} ${TARGET_H} ${FPS}
c 0 0 part0
DESC

echo -e "${C_GREEN}[4/4] Assembling uncompressed STORE-mode bootanimation.zip...${C_RESET}"
(
    cd "$WORK_DIR"
    if [ -f audio.wav ] && [ $(stat -c%s audio.wav) -gt 1000 ]; then
        zip -r -0 "$OUTPUT_ZIP" desc.txt part0/ audio.wav
    else
        zip -r -0 "$OUTPUT_ZIP" desc.txt part0/
    fi
)

# Generate push flasher script
cat << PUSH_SH > "$(dirname "$OUTPUT_ZIP")/install_to_phone.sh"
#!/usr/bin/env bash
set -e
echo "=================================================================="
echo "⚡ Installing Custom Boot Animation to Connected Phone..."
echo "=================================================================="
if ! adb devices | grep -q 'device$'; then
    echo "[!] Error: No authorized ADB device connected."
    echo "    Make sure USB Debugging is ON in Developer Options."
    exit 1
fi

echo "[*] Pushing bootanimation.zip to device /data/local/bootanimation.zip..."
adb push bootanimation.zip /data/local/bootanimation.zip
adb shell chmod 644 /data/local/bootanimation.zip
adb shell chown root:root /data/local/bootanimation.zip

echo "[✓] Successfully installed custom boot animation!"
echo "[*] Reboot phone to test: 'adb reboot'"
PUSH_SH
chmod +x "$(dirname "$OUTPUT_ZIP")/install_to_phone.sh"

echo -e "\n${C_CYAN}==============================================================================${C_RESET}"
echo -e "${C_GREEN}🎉 Boot Animation created successfully!${C_RESET}"
echo -e " Output ZIP  : ${C_BOLD}$OUTPUT_ZIP${C_RESET} ($(du -h "$OUTPUT_ZIP" | cut -f1))"
echo -e " Installer   : ${C_BOLD}$(dirname "$OUTPUT_ZIP")/install_to_phone.sh${C_RESET}"
echo -e "\nTo test or install directly to phone via ADB:"
echo -e "  ${C_BOLD}cd $(dirname "$OUTPUT_ZIP") && ./install_to_phone.sh${C_RESET}"
echo -e "${C_CYAN}==============================================================================${C_RESET}"
