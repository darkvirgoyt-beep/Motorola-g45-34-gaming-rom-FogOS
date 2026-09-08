# 🎬 VirgoX Elite — Custom Boot Animation & Splash Screen Guide

Comprehensive guide for customizing the **Boot Splash Screen (`logo.bin`)** and **Boot Animation (`bootanimation.zip`)** on Motorola Moto G45 5G & Moto G34 5G (`fogos` / SM6375).

---

## 🛡️ 1. Custom Splash Screen (Boot Logo & Warning Remover)

The splash screen is the very first image shown when turning on your phone (before Android boots). Stock Motorola devices show an ugly *"Device bootloader is unlocked and cannot be trusted"* warning. 

VirgoX completely replaces this with your custom artwork.

### 🔨 Generate a Custom Splash Screen (PC / Terminal):
You can convert any image (`.png`, `.jpg`, `.webp`) into a flashable Motorola partition container:

```bash
# Run the VirgoX Splash Screen Creator
./tools/create_custom_splash.sh <path_to_your_image.png> [output_directory]
```

**What this does:**
1. Automatically scales and optimizes the image to **720 × 1600** (20:9 native aspect ratio).
2. Encapsulates all 8 Motorola bootloader warning and boot states (`orange1`, `orange2`, `yellow1`, `yellow2`, `red1`, `redeio1`, `logo_boot`, `logo_carrier_retid`).
3. Generates `logo.bin` and `logo.img`.
4. Creates 1-click Fastboot flashers (`flash_splash.sh` and `flash_splash.bat`).

### ⚡ Flashing the Splash Screen:
* **Via Fastboot (Zero risk):**
  ```bash
  fastboot flash logo logo.bin
  fastboot reboot
  ```
* **Directly on Phone (via Termux / Root Shell):**
  ```bash
  su -c "virgox-boot-customizer flash-splash /sdcard/logo.bin"
  ```

---

## 🎬 2. Custom Boot Animation (`bootanimation.zip`)

VirgoX supports high-refresh-rate **60 FPS and 120 FPS uncompressed STORE-mode** boot animations.

### 🎥 Convert Any Video to a 120 FPS Boot Animation:
You can convert any `.mp4`, `.mkv`, or `.webm` clip into an Android boot animation:

```bash
# Run the Boot Animation Creator
./tools/create_custom_bootanim.sh <path_to_video.mp4> 120
```

**Features:**
* Renders uncompressed frames at 720 × 1600.
* Automatically extracts and preserves audio tracks into `audio.wav`.
* Creates uncompressed STORE (`-0`) `bootanimation.zip`.
* Generates an instant ADB installation script (`install_to_phone.sh`).

---

## 📱 3. On-Device Management (`virgox-boot-customizer`)

VirgoX Elite Gaming OS has a built-in terminal utility installed directly at `/system/bin/virgox-boot-customizer` (and symlinked to `virgox-bootanim`).

Run it from **Termux**, **PulseControl Terminal**, or **ADB Shell**:

| Command | Description |
| :--- | :--- |
| `virgox-boot-customizer status` | Check whether custom animation or system default 120FPS is active. |
| `virgox-boot-customizer install-anim <file.zip>` | Installs a custom animation to `/data/local/bootanimation.zip` with correct permissions and SELinux label. |
| `virgox-boot-customizer reset-anim` | Reverts back to official VirgoX 120FPS animation. |
| `virgox-boot-customizer preview` | Tests and previews the boot animation live on your screen for 5 seconds without rebooting. |
| `virgox-boot-customizer flash-splash <logo.bin>` | Flashes a new splash screen directly to the `logo` partition (requires root). |

---

## 🎨 4. Default Design Specifications
* **Screen Resolution:** 720 × 1600
* **Aspect Ratio:** 20:9
* **Frame Rate:** 120 FPS (Smooth high-refresh animation) or 60 FPS
* **Compression:** ZIP STORE (`-0`) — No Deflate compression (required by SurfaceFlinger)
