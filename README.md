# 👑 FogOS Gaming Edition — Motorola Moto G45 5G & G34 5G (`fogos`)

<p align="center">
  <img src="https://img.shields.io/badge/Device-Motorola%20G45%20%2F%20G34%205G-blue.svg?style=for-the-badge&logo=motorola" />
  <img src="https://img.shields.io/badge/Codename-fogos%20%2F%20SM6375-orange.svg?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Android-14%20(LineageOS%20Base)-green.svg?style=for-the-badge&logo=android" />
  <img src="https://img.shields.io/badge/Developer-Prince%20%C2%B7%20VirgoYT-red.svg?style=for-the-badge&logo=youtube" />
</p>

---

## 📖 Overview

**FogOS Gaming Edition** is a custom, performance-tuned Android 14 ROM engineered specifically for the **Motorola Moto G45 5G** and **Moto G34 5G** (`fogos` / Qualcomm Snapdragon 6s Gen 3 / SM6375 platform).

Maintained by **Prince · VirgoYT**, this ROM combines a lightweight, debloated operating system base with the custom **VirgoYT Gaming Kernel**, unlocked thermal limits, ROG Phone game spoofing, and 120Hz display locking.

---

## ⚡ Key Gaming Features

* 🚀 **Embedded VirgoYT Gaming Kernel:** Pre-integrated with optimized CPU schedulers, touchboost, and Adreno 619 GPU pipeline tweaks.
* 🎮 **90 FPS / 120 FPS Game Spoofing:** Spoofs device fingerprint as ASUS ROG Phone 8 Pro / Sony Xperia to unlock maximum frame rate options in:
  * BGMI (Battlegrounds Mobile India)
  * PUBG Mobile
  * Call of Duty: Mobile (120 FPS Ultra)
  * Mobile Legends: Bang Bang
  * Genshin Impact & Honkai: Star Rail
* 🖥️ **Locked 120Hz Refresh Rate:** Prevents SurfaceFlinger from dropping refresh rate to 60Hz during intensive gaming sessions.
* ⚡ **240Hz Touch Response:** Reduced input latency buffer for faster touch response in competitive shooters.
* ❄️ **Aggressive Thermal Throttle Override:** Bypasses Motorola's stock thermal governor that downclocks at 42°C.
* 📱 **Preloaded FogOS PulseControl App:** Instant on-the-fly monitoring and gaming profile switching.
* 💾 **Optimized zRAM & Memory Management:** LZ4 compression tuned specifically for both 4GB and 8GB RAM variants of the Moto G45.

---

## 🛠️ How to Build via GitHub Actions (100% Free & Cloud-Hosted)

No high-spec PC or local storage needed! You can compile and release this ROM directly using GitHub Actions:

1. Navigate to the **Actions** tab in this repository.
2. Under All workflows, select **`FogOS Gaming ROM — Build & Release`**.
3. Click **Run workflow** -> Select branch `main` -> Click **Run workflow**.
4. GitHub Actions will:
   * Download the latest base ROM for `fogos`.
   * Extract partitions using `payload-dumper-go`.
   * Pull and embed your latest **VirgoYT Gaming Kernel**.
   * Inject all gaming properties and configs.
   * Package a Fastboot-ready installer with `flash_all.bat` and `flash_all.sh`.
   * Automatically publish a downloadable release in your **Releases** tab in ~5–8 minutes!

---

## 📲 How to Flash on Motorola G45 / G34

### Prerequisites
* Unlocked Bootloader on your Motorola device.
* USB Drivers & ADB/Fastboot installed on your PC.
* At least 50% battery.

### Flashing Steps:
1. Download the latest `FogOS-v1.0-Gaming-fogos-VirgoYT-*.zip` from the [Releases](https://github.com/darkvirgoyt-beep/Motorola-g45-34-gaming-rom-FogOS/releases) page.
2. Extract the ZIP file into a folder on your computer.
3. Power off your phone and hold **Volume Down + Power** to enter Bootloader (Fastboot) mode.
4. Connect your phone to your PC via USB.
5. **Windows:** Double-click `flash_all.bat`.
   **Linux / macOS:** Open terminal in the extracted folder and run:
   ```bash
   chmod +x flash_all.sh
   ./flash_all.sh
   ```
6. When prompted to wipe/format userdata, select **Y** (required when coming from stock ROM).
7. Once finished, your phone will reboot directly into **FogOS Gaming Edition**!

---

## 👤 Credits & Maintainer

* **Lead Developer & Maintainer:** [Prince · VirgoYT](https://github.com/darkvirgoyt-beep) (`VirgoYT707`)
* **Base Source:** LineageOS Team (`fogos` maintainers)
* **Kernel:** [Motorola-g45-34-gaming-kernel-Fogos-new](https://github.com/darkvirgoyt-beep/Motorola-g45-34-gaming-kernel-Fogos-new)
* **Community:** Motorola SM6375 Development Community
