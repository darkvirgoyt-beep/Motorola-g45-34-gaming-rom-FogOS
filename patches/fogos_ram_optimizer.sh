#!/system/bin/sh
# ==============================================================================
# FogOS Elite Gaming ROM - Dynamic 4GB / 8GB RAM Optimizer
# Target: Motorola Moto G45 5G / G34 5G (fogos - SM6375 / Snapdragon 6s Gen 3)
# Developer: Prince · VirgoYT (VirgoYT707)
# ==============================================================================

LOG_TAG="VirgoX-RAM-Optimizer"

log_info() {
    log -p i -t "$LOG_TAG" "$1"
    echo "[$LOG_TAG] $1"
}

# 1. Read Total System RAM (in kB) from /proc/meminfo
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))

log_info "Detected Total System RAM: ${TOTAL_RAM_MB} MB (${TOTAL_RAM_KB} kB)"

# 2. Check if device is 4GB variant (< 5000 MB) or 8GB variant (>= 5000 MB)
if [ "$TOTAL_RAM_MB" -lt 5000 ]; then
    log_info "========================================================"
    log_info " Activating VirgoX 4GB RAM Elite Gaming Profile"
    log_info " Target: Snapdragon 6s Gen 3 + 4GB LPDDR4X"
    log_info "========================================================"

    setprop persist.virgox.ram_variant "4GB"
    setprop persist.virgox.ram_status "optimized"

    # Virtual Memory & Swappiness for 4GB (Aggressive zRAM usage to prevent OOM)
    echo 160 > /proc/sys/vm/swappiness 2>/dev/null || true
    echo 100 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null || true
    echo 0 > /proc/sys/vm/page-cluster 2>/dev/null || true
    echo 20 > /proc/sys/vm/dirty_ratio 2>/dev/null || true
    echo 5 > /proc/sys/vm/dirty_background_ratio 2>/dev/null || true
    echo 200 > /proc/sys/vm/watermark_scale_factor 2>/dev/null || true
    echo 1 > /proc/sys/vm/compact_unevictable_allowed 2>/dev/null || true

    # zRAM Configuration for 4GB: 3.5 GB (3670016000 bytes) with LZ4
    if [ -b /dev/block/zram0 ]; then
        swapoff /dev/block/zram0 2>/dev/null || true
        echo 1 > /sys/block/zram0/reset 2>/dev/null || true
        echo lz4 > /sys/block/zram0/comp_algorithm 2>/dev/null || true
        echo 3670016000 > /sys/block/zram0/disksize 2>/dev/null || true
        mkswap /dev/block/zram0 2>/dev/null || true
        swapon /dev/block/zram0 -p 32767 2>/dev/null || true
        log_info "zRAM initialized: 3.5GB with LZ4 compression"
    fi

    # Dalvik ART Heap Limits and LMKD properties have been removed from here.
    # REASON: dalvik.vm.* properties are read once during Zygote boot and have no effect here.
    # ro.lmk.* properties are read-only after init and will be rejected.
    # These values have been moved to virgox_dalvik_props_4gb.prop to be baked into build.prop.

else
    log_info "========================================================"
    log_info " Activating VirgoX 8GB RAM Ultra Gaming Profile"
    log_info " Target: Snapdragon 6s Gen 3 + 8GB LPDDR4X"
    log_info "========================================================"

    setprop persist.virgox.ram_variant "8GB"
    setprop persist.virgox.ram_status "optimized"

    # Virtual Memory for 8GB (Maximum RAM caching for instant game load times)
    echo 60 > /proc/sys/vm/swappiness 2>/dev/null || true
    echo 50 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null || true
    echo 0 > /proc/sys/vm/page-cluster 2>/dev/null || true
    echo 25 > /proc/sys/vm/dirty_ratio 2>/dev/null || true
    echo 10 > /proc/sys/vm/dirty_background_ratio 2>/dev/null || true
    echo 100 > /proc/sys/vm/watermark_scale_factor 2>/dev/null || true

    # zRAM Configuration for 8GB: 4.0 GB (4194304000 bytes) with zstd/lz4
    if [ -b /dev/block/zram0 ]; then
        swapoff /dev/block/zram0 2>/dev/null || true
        echo 1 > /sys/block/zram0/reset 2>/dev/null || true
        if grep -q zstd /sys/block/zram0/comp_algorithm 2>/dev/null; then
            echo zstd > /sys/block/zram0/comp_algorithm 2>/dev/null || true
        else
            echo lz4 > /sys/block/zram0/comp_algorithm 2>/dev/null || true
        fi
        echo 4194304000 > /sys/block/zram0/disksize 2>/dev/null || true
        mkswap /dev/block/zram0 2>/dev/null || true
        swapon /dev/block/zram0 -p 32767 2>/dev/null || true
        log_info "zRAM initialized: 4.0GB with ultra throughput"
    fi

    # Dalvik ART Heap Limits and LMKD properties have been removed from here.
    # REASON: dalvik.vm.* properties are read once during Zygote boot and have no effect here.
    # ro.lmk.* properties are read-only after init and will be rejected.
    # These values have been moved to virgox_dalvik_props_8gb.prop to be baked into build.prop.
fi

# Multi-Gen LRU (MGLRU) enablement across both models
if [ -d /sys/kernel/mm/lru_gen ]; then
    echo 7 > /sys/kernel/mm/lru_gen/enabled 2>/dev/null || true
    echo 1000 > /sys/kernel/mm/lru_gen/min_ttl_ms 2>/dev/null || true
fi

log_info "RAM optimization applied successfully for Moto G45 / G34 ($TOTAL_RAM_MB MB)."
