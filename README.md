# 👑 FogOS Elite Gaming Edition — Motorola Moto G45 5G & G34 5G (`fogos`)

<p align="center">
  <img src="https://img.shields.io/badge/Device-Motorola%20G45%20%2F%20G34%205G-blue.svg?style=for-the-badge&logo=motorola" />
  <img src="https://img.shields.io/badge/Codename-fogos%20%2F%20SM6375-orange.svg?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Android-14%20%2F%2015%20(LineageOS%20Base)-green.svg?style=for-the-badge&logo=android" />
  <img src="https://img.shields.io/badge/Developer-Prince%20%C2%B7%20VirgoYT-red.svg?style=for-the-badge&logo=youtube" />
</p>

---

## 📖 Overview

**FogOS Elite Gaming Edition** is a custom, performance-tuned Android ROM engineered specifically for the **Motorola Moto G45 5G** and **Moto G34 5G** (`fogos` / Qualcomm Snapdragon 6s Gen 3 / SM6375 platform).

Maintained by **Prince · VirgoYT**, this ROM combines a pure, lightweight LineageOS base with deep kernel and framework interventions to deliver maximum sustained FPS with zero jitter.

---

## ⚡ Elite Gaming Architectural Enhancements

### 1. 🚀 CPU & GPU Subsystem (SM6375 / Holi)
* **Energy-Aware Scheduler (EAS) & Sched-Boost:** Prioritizes `top-app` and `foreground` cgroups with increased task utilization boost (`sched_min_task_util_for_boost = 51`) and `prefer_idle = 1`.
* **CPU-Boost & Touch Boost:** 60ms CPU boost upon user touch events (`0:1200000 6:1800000`) for instantaneous reaction times in shooter games.
* **Schedutil Transition Optimization:** 500µs ramp-up (`up_rate_limit_us`) and 20,000µs hold (`down_rate_limit_us`) to prevent 1% low frame stuttering.
* **Adreno 619 KGSL Optimization:** `msm-adreno-tz` governor with disabled idle downclocking and unthrottled GPU bus clock during gaming sessions.

### 2. 💽 High-Speed Storage & I/O Pipeline
* **I/O Scheduler:** Tuned `bfq` and `mq-deadline` for UFS storage queues.
* **Readahead:** 512KB readahead buffer on storage blocks to eliminate in-game texture streaming lag.
* **NR Requests:** Queue depth expanded to 256 requests with disabled I/O statistics overhead.

### 3. 🎯 Input Latency, Touch & Gestures
* **240Hz Touch Sampling Rate:** Eliminates touch latency buffer (`windowsmgr.max_events_per_sec=240`).
* **Zero Touch Debounce:** Direct touch event routing with reduced debounce time.
* **Double-Tap-To-Wake (DT2W):** Native support enabled at kernel and sysfs level (`/sys/android_touch/double_tap_enable`).

### 4. ❄️ Thermal Throttling Mitigation
* **Balanced Thermal Trip Thresholds:** Bypasses Motorola's stock 42°C downclock while maintaining safe hardware thermal boundaries (`persist.vendor.power.thermal_mitigation=0`).

### 5. 🧠 Memory, LMKD & zRAM Compression
* **zRAM & Swappiness:** `swappiness = 100` tuned with LZ4 fast compression for 4GB and 8GB RAM variants.
* **VFS Cache Pressure:** Set to `70` to retain active game inodes and dentries in cache.
* **Multi-Gen LRU (MGLRU):** Enabled (`/sys/kernel/mm/lru_gen/enabled 7`) for lower CPU overhead during page reclamation.
* **LMKD Optimization:** Tuned LowMemoryKiller daemon (`ro.lmk.kill_heaviest_task=true`, PSI stall threshold 700ms) to prevent game termination in the background.

### 6. 🌐 Network & Low-Ping Multiplayer
* **Google BBR TCP Congestion Control:** Enabled as default socket governor (`net.ipv4.tcp_congestion_control=bbr`).
* **Low Latency Sockets:** Optimized TCP buffer sizes (`rmem_max = 8MB`, `wmem_max = 8MB`) with `tcp_low_latency = 1` and `tcp_fastopen = 3`.

---

## 🎮 ROM & Framework-Side Interventions

### 🕹️ GameManagerService Interventions (`game_mode_config.xml`)
* **FPS Unlocker:** Enforces 90 FPS & 120 FPS targets for BGMI, PUBG Mobile, Call of Duty: Mobile, and Mobile Legends.
* **Resolution Downscaling:** Dynamic downscale intervention (0.85x scale) for graphically heavy titles (Genshin Impact / Warzone Mobile) for rock-solid 60/90 FPS.
* **Performance Mode:** Forces top-app priority when games launch.

### 🖼️ Android Frame Pacing & Vulkan Timing
* **Swappy Integration:** Android Frame Pacing enabled (`ro.vendor.display.frame_pacing=1`, `debug.sf.frame_rate_multiple_threshold=60`).
* **VK_EXT_present_timing:** Explicit frame presentation control for Vulkan 1.3 engines (`debug.vulkan.enable_present_timing=1`, `ro.sf.present_timing=1`).
* **120Hz Lock:** Hard-locked SurfaceFlinger refresh rate without dynamic drops (`use_content_detection_for_refresh_rate=false`).

### 🧹 Clean Environment (No Bloat / No Debug Overhead)
* Disabled `atrace`, `traced`, `statsd`, checkjni, and system profiling loggers to reclaim CPU cycles exclusively for the game loop.

---

## 🛠️ GitHub Actions Build Pipelines

This repository features **two active automated pipelines**:

1. **`FogOS Gaming ROM - Build`**: Fast distribution builder (LineageOS base + VirgoYT Kernel + all gaming patches + Fastboot flasher). Compiles and publishes in ~6 minutes!
2. **`Compile LineageOS from Source (fogos)`**: Full source code compilation (`repo init`, `LineageOS 21`, `breakfast fogos`, `brunch fogos`).

---

## 📲 How to Flash on Motorola G45 / G34

1. Download the release package from the [Releases](https://github.com/darkvirgoyt-beep/Motorola-g45-34-gaming-rom-FogOS/releases) page.
2. Extract the ZIP package on your PC.
3. Boot into Fastboot mode (`Power + Volume Down`).
4. **Windows:** Run `flash_all.bat`.
   **Linux / macOS:** Run `chmod +x flash_all.sh && ./flash_all.sh`.
5. Select **Y** to format userdata if first time flashing.
6. Enjoy ultimate gaming performance!

---

## 👤 Credits & Maintainer

* **Lead Developer & Maintainer:** [Prince · VirgoYT](https://github.com/darkvirgoyt-beep) (`VirgoYT707`)
* **Base Source:** LineageOS Team
* **Kernel:** [Motorola-g45-34-gaming-kernel-Fogos-new](https://github.com/darkvirgoyt-beep/Motorola-g45-34-gaming-kernel-Fogos-new)
