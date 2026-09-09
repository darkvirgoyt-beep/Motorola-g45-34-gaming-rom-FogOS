<h1 align="center">🎮 VirgoX Elite GamingOS</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Android-17-green.svg" alt="Android 17">
  <img src="https://img.shields.io/badge/Platform-SM6375-blue.svg" alt="SM6375">
  <img src="https://img.shields.io/badge/Devices-Moto_G45_|_G34-orange.svg" alt="Moto G45/G34">
  <img src="https://img.shields.io/badge/Version-v1.0-purple.svg" alt="v1.0">
</p>

<p align="center">
  <em>Built for responsive Android gaming on Moto G45 5G and Moto G34 5G.</em>
</p>

<p align="center">
  <strong>Developer:</strong> Prince · VirgoYT
</p>

---

## 🌟 Features

### 1. ⚡ Performance Engine
- **Display:** 120Hz locked display, SurfaceFlinger optimizations
- **CPU:** Input boost (1.2GHz little / 1.8GHz big)
- **GPU:** Adreno 619 GPU clock optimization
- **Network:** TCP BBR2 congestion control
- **Storage:** BFQ I/O scheduler

### 2. 🎮 Gaming Optimizations & Locked Stable FPS (Zero Drop Engine)
- **Profiles:** 3 gaming profiles: Balanced / Performance / Turbo with locked frequency floors
- **Zero Frame Drops:** Big cores locked at 1.80GHz - 2.60GHz, GPU floor locked at 600MHz - 1050MHz
- **Thermal Ceiling:** Elevated gaming thermal limits (54°C - 63°C) preventing combat throttling cliffs
- **SurfaceFlinger Stability:** Triple buffering, 0ms touch timer, disabled GL backpressure, content detection disabled
- **Per-Game Configs:** BGMI, PUBG, CODM, Warzone Mobile, Free Fire MAX, Genshin Impact, Mobile Legends
- **Device Spoofing:** ROG Phone 8 Pro / Xperia 1 III spoofing for 90 FPS & 120 FPS unlock
- **GameManagerService:** Native integration with background throttling suppression
- **Network QoS:** iptables TOS Low Delay & TCP BBR2 on game packets

### 3. 📱 Touch & iOS-Grade Gyroscope (1000Hz Polling Engine)
- **Touch Rate:** 1000Hz touch sampling / polling rate with 16MHz SPI bus throughput
- **Zero Input Latency:** `debug.input.latency=0`, `persist.sys.touch.debounce_ms=0`, 0ms touch delay
- **Esports Crosshair Precision:** Raw Level-0 filter bypass (`touch.filter.level=0`), `slop_scale=0.25`, sensitivity=2
- **iOS-Grade Gyroscope:** Direct Channel hardware shared memory (`persist.vendor.sensors.direct_channel=true`), real-time RT task thread (`enable.rt_task=true`)
- **Ultra-Fast 1000Hz IMU Polling:** `ro.sensor.rate.fastest=1000` (1ms hardware polling delay)
- **Zero Gyro Delay & Drift:** Artificial low-pass filter disabled (`imu_filter=0`), raw 1:1 tracking (`gyro_smoothing=0.0`)
- **Event Pipeline Throughput:** `max_events_per_sec=1000`, `ro.input.max_events=2000`, `ro.input.event_per_port=128`
- **Features:** Double-tap-to-wake (Goodix GT917S, Chipone TDDI, Ilitek)

### 4. 💾 Smart RAM Management
- **Auto-Detection:** Detects 4GB vs 8GB variant
- **4GB Variant:** 3.5GB LZ4 zRAM, aggressive swappiness
- **8GB Variant:** 4.0GB zstd zRAM, game asset caching
- **Memory Handling:** Multi-Gen LRU (MGLRU) enabled
- **ART Tuning:** Static Dalvik ART heap tuning per variant

### 5. 🔊 Audio & Connectivity
- **Audio:** Dolby Atmos & Spatial Audio
- **Calling:** VoLTE / VoWiFi enabled
- **Wireless:** WiFi 6E support
- **Camera:** Camera2 API HAL3

### 6. 🎨 VirgoX Branding
- Custom boot animation
- 3 exclusive VirgoX wallpapers
- VirgoX version info in About Phone
- Custom power whitelist for games

---

## 📱 Supported Devices

| Device | SoC | RAM | Codename |
|---|---|---|---|
| Moto G45 5G | Snapdragon 6s Gen 3 | 4GB / 8GB | fogos |
| Moto G34 5G | Snapdragon 695 5G | 4GB / 8GB | fogos |

---

## 🛠️ Installation Guide

### Prerequisites
- Unlocked Bootloader
- USB Debugging enabled in Developer Options
- Android platform-tools (adb and fastboot) installed

### Method 1: Fastboot (Recommended)
1. Reboot your device to bootloader/fastboot mode:
   ```bash
   adb reboot bootloader
   ```
2. Connect your phone to your PC via USB.
3. Run the flash script:
   ```bash
   bash flash_all.sh
   ```

### Method 2: Recovery Sideload
1. Flash the custom recovery from bootloader:
   ```bash
   fastboot flash recovery recovery.img
   ```
2. Boot into recovery and format data/factory reset.
3. Enter ADB Sideload mode on your phone.
4. Run the sideload script:
   ```bash
   bash recovery_sideload.sh
   ```

### Post-Install Steps
- Reboot system.
- Complete the setup wizard.
- Game on!

---

## 🏎️ Gaming Profiles

| Profile | CPU Freq (Little/Big) | GPU Max | Thermal Limit | Description |
|---|---|---|---|---|
| **Balanced** | Default | Default | Standard | Daily use, battery saving |
| **Performance**| Boosted | Optimal | Relaxed | Great for competitive gaming |
| **Turbo** | Max | Max | Aggressive | Max FPS, device may get warm |

---

## 🏗️ Building Section

### Strategy A: Binary Repackaging (Quick, works on any PC)
Use this if you just want to modify existing payload and vendor contents.
**Prerequisites:** Linux environment, payload-dumper-go, python3.
```bash
./scripts/extract_payload.sh /path/to/stock.zip
./scripts/patch_images.sh
./scripts/repack_payload.sh
```

### Strategy B: Full Source Compilation (Needs build server)
Build directly from source for complete customization.
**Prerequisites:** Ubuntu 22.04+, 32GB RAM, 500GB Storage.
```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-22.1
# Sync manifests and device trees...
repo sync -c -j8 --force-sync --no-clone-bundle --no-tags
source build/envsetup.sh
lunch lineage_fogos-userdebug
m bacon
```

---

## 📂 Repository Structure

```text
VirgoX-Elite-GamingOS-Rom-Motorola-G45-FogOs/
├── Android.bp                  # Root build configuration
├── Makefile                    # Make configurations
├── README.md                   # You are here
├── build/                      # Build scripts and configurations
├── configs/                    # Device configurations
├── device/                     # Device tree for fogos
├── kernel/                     # Kernel configurations and scripts
├── overlays/                   # RRO overlays for branding & features
├── prebuilt/                   # Prebuilt binaries, apps, bootanimation
├── scripts/                    # Scripts for repackaging and flashing
├── sepolicy/                   # SELinux policies
└── vendor/                     # Vendor blobs
```

---

## 🏆 Credits

- **Lead Developer:** Prince · VirgoYT (@darkvirgoyt-beep)
- **Base ROMs:** LineageOS, Evolution X
- **Kernel:** android_kernel_motorola_fogos
- **Platform:** Qualcomm SM6375 / Holi

---

## ⚠️ Safety & Disclaimer

```text
#include <std_disclaimer.h>
/*
 * Your warranty is now void.
 *
 * I am not responsible for bricked devices, dead SD cards,
 * thermonuclear war, or you getting fired because the alarm app failed. Please
 * do some research if you have any concerns about features included in this ROM
 * before flashing it! YOU are choosing to make these modifications, and if
 * you point the finger at me for messing up your device, I will laugh at you.
 */
```

## 📜 License
Upstream licenses apply for LineageOS, Evolution X, and Linux Kernel sources.
