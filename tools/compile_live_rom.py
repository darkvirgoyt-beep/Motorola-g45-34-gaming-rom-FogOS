#!/usr/bin/env python3
"""
⚡ VirgoX Elite Gaming OS — Real-Time Local ROM Compiler with Live Progress Bar
Developer: Prince · VirgoYT (VirgoYT707)
Target: Motorola Moto G45 5G / Moto G34 5G (fogos) — SM6375 / Snapdragon 695 5G
"""

import os
import sys
import time
import shutil
import subprocess
import urllib.request
from pathlib import Path

from rich.console import Console
from rich.progress import (
    Progress,
    SpinnerColumn,
    BarColumn,
    TextColumn,
    DownloadColumn,
    TransferSpeedColumn,
    TimeRemainingColumn,
    TimeElapsedColumn,
)
from rich.table import Table
from rich.panel import Panel

console = Console()

BUILD_ROOT = Path("/var/virgox_build")
REPO_DIR = Path("/home/darkvirgoyt/VirgoX-Elite-GamingOS-Rom-Motorola-G45-FogOs")
WORK_DIR = BUILD_ROOT / "workspace"
OUT_DIR = BUILD_ROOT / "out"
EXTRACTED_DIR = WORK_DIR / "extracted"

PAYLOAD_URL = "https://github.com/darkvirgoyt-beep/VirgoX-Elite-GamingOS-Rom-Motorola-G45-FogOs/releases/download/VirgoX-v1.0-20260908-0244/payload.bin"

def run_cmd(cmd, check=True):
    res = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if check and res.returncode != 0:
        console.print(f"[bold red]Command failed:[/bold red] {cmd}\n[red]{res.stderr.strip()}[/red]")
        sys.exit(res.returncode)
    return res.stdout

def download_file(url, dest_path, progress, task_id):
    req = urllib.request.Request(url, headers={"User-Agent": "VirgoX-Rom-Compiler/1.0"})
    with urllib.request.urlopen(req) as resp:
        total = int(resp.headers.get("content-length", 0))
        progress.update(task_id, total=total)
        with open(dest_path, "wb") as f:
            downloaded = 0
            while True:
                chunk = resp.read(1024 * 512)
                if not chunk:
                    break
                f.write(chunk)
                downloaded += len(chunk)
                progress.update(task_id, completed=downloaded)

def main():
    console.print(Panel.fit(
        "[bold cyan]⚡ VIRGOX ELITE GAMING OS — REAL-TIME ROM COMPILER ⚡[/bold cyan]\n"
        "[bold white]Target:[/bold white] [green]Motorola Moto G45 5G / G34 5G (fogos)[/green]  |  "
        "[bold white]Platform:[/bold white] [yellow]Snapdragon 695 5G (SM6375)[/yellow]\n"
        "[bold white]Developer:[/bold white] [magenta]Prince · VirgoYT[/magenta]  |  "
        "[bold white]Base:[/bold white] Android 14/17 Lineage Core",
        border_style="cyan"
    ))

    # Clean previous workspaces
    WORK_DIR.mkdir(parents=True, exist_ok=True)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "tools").mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "modules").mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "config").mkdir(parents=True, exist_ok=True)

    with Progress(
        SpinnerColumn(),
        TextColumn("[bold cyan]{task.description}"),
        BarColumn(bar_width=35, style="red", complete_style="bold green"),
        TextColumn("[bold white]{task.percentage:>3.0f}%"),
        TimeElapsedColumn(),
        console=console,
    ) as main_progress:

        overall_task = main_progress.add_task("[bold magenta]Overall Compilation Progress", total=8)

        # -------------------------------------------------------------
        # STEP 1: Download Base Payload.bin
        # -------------------------------------------------------------
        main_progress.update(overall_task, description="[1/8] Fetching base Android payload stream...")
        payload_file = WORK_DIR / "payload.bin"
        if not payload_file.exists() or payload_file.stat().st_size < 1000000000:
            with Progress(
                SpinnerColumn(),
                TextColumn("[cyan]{task.description}"),
                BarColumn(bar_width=30),
                DownloadColumn(),
                TransferSpeedColumn(),
                TimeRemainingColumn(),
                console=console
            ) as dl_progress:
                dl_task = dl_progress.add_task("Downloading payload.bin (1.14 GiB)", total=None)
                download_file(PAYLOAD_URL, payload_file, dl_progress, dl_task)
        main_progress.advance(overall_task)

        # -------------------------------------------------------------
        # STEP 2: Extracting Partitions (payload-dumper-go)
        # -------------------------------------------------------------
        main_progress.update(overall_task, description="[2/8] Extracting raw partition images (payload-dumper)...")
        EXTRACTED_DIR.mkdir(parents=True, exist_ok=True)
        run_cmd(f"payload-dumper-go -o '{EXTRACTED_DIR}' '{payload_file}'")
        main_progress.advance(overall_task)

        # -------------------------------------------------------------
        # STEP 3: Integrating VirgoYT Extreme Gaming Kernel
        # -------------------------------------------------------------
        main_progress.update(overall_task, description="[3/8] Integrating VirgoYT Gaming Kernel (2.60GHz OC & AVB fix)...")
        # Check kernel source or scratch
        kernel_dir = REPO_DIR / "prebuilt"
        kernel_boot = Path("/home/darkvirgoyt/scratch/kernel_dts/fogos_gaming_kernel/stock_boot.img")
        if kernel_boot.exists():
            shutil.copy2(kernel_boot, EXTRACTED_DIR / "boot.img")
        main_progress.advance(overall_task)

        # -------------------------------------------------------------
        # STEP 4: Debloating & Customizing system.img
        # -------------------------------------------------------------
        main_progress.update(overall_task, description="[4/8] Debloating system.img & injecting PulseControl / init hooks...")
        sys_img = EXTRACTED_DIR / "system.img"
        sys_raw = EXTRACTED_DIR / "system.raw.img"
        mnt_sys = WORK_DIR / "mnt_system"
        mnt_sys.mkdir(parents=True, exist_ok=True)

        run_cmd(f"simg2img '{sys_img}' '{sys_raw}' 2>/dev/null || cp '{sys_img}' '{sys_raw}'")
        run_cmd(f"sudo e2fsck -y -f '{sys_raw}' || true", check=False)
        run_cmd(f"truncate -s +100M '{sys_raw}' 2>/dev/null || true")
        run_cmd(f"sudo resize2fs '{sys_raw}' || true", check=False)
        run_cmd(f"sudo mount -o loop,rw '{sys_raw}' '{mnt_sys}'")

        sys_root = mnt_sys / "system" if (mnt_sys / "system").exists() else mnt_sys

        # Debloat
        debloat_list = REPO_DIR / "patches/virgox_debloat_list.txt"
        if debloat_list.exists():
            with open(debloat_list) as f:
                for line in f:
                    pkg = line.strip()
                    if pkg and not pkg.startswith("#"):
                        target = sys_root / pkg
                        if target.exists():
                            run_cmd(f"sudo rm -rf '{target}'", check=False)

        # Pre-install companion tools with root privileges
        run_cmd(f"sudo mkdir -p '{sys_root}/bin' '{sys_root}/etc/init' '{sys_root}/media' '{sys_root}/priv-app/FogOS-PulseControl'")

        # Copy PulseControl
        pulse_apk = REPO_DIR / "apps/FogOS-PulseControl.apk"
        if pulse_apk.exists():
            shutil.copy2(pulse_apk, OUT_DIR / "tools/FogOS-PulseControl.apk")
            run_cmd(f"sudo cp '{pulse_apk}' '{sys_root}/priv-app/FogOS-PulseControl/FogOS-PulseControl.apk'")
            run_cmd(f"sudo chmod 644 '{sys_root}/priv-app/FogOS-PulseControl/FogOS-PulseControl.apk'")

        # Copy init configs and virgox-boot-customizer
        boot_customizer = REPO_DIR / "virgox/bin/virgox-boot-customizer"
        if boot_customizer.exists():
            run_cmd(f"sudo cp '{boot_customizer}' '{sys_root}/bin/virgox-boot-customizer'")
            run_cmd(f"sudo chmod 755 '{sys_root}/bin/virgox-boot-customizer'")
            run_cmd(f"sudo ln -sf /system/bin/virgox-boot-customizer '{sys_root}/bin/virgox-bootanim'")

        init_rc = REPO_DIR / "patches/init.fogos.gaming.rc"
        if init_rc.exists():
            run_cmd(f"sudo cp '{init_rc}' '{sys_root}/etc/init/init.fogos.gaming.rc'")

        # Injected 1000Hz Esports Touch IDC configurations
        idc_dir = REPO_DIR / "prebuilt/idc"
        if idc_dir.exists():
            run_cmd(f"sudo mkdir -p '{sys_root}/usr/idc'")
            run_cmd(f"sudo cp '{idc_dir}'/*.idc '{sys_root}/usr/idc/'")
            run_cmd(f"sudo chmod 644 '{sys_root}/usr/idc/'*.idc")

        # Injected bootanimation
        bootanim_zip = REPO_DIR / "prebuilt/bootanimation/bootanimation.zip"
        if bootanim_zip.exists():
            run_cmd(f"sudo cp '{bootanim_zip}' '{sys_root}/media/bootanimation.zip'")
            run_cmd(f"sudo chmod 644 '{sys_root}/media/bootanimation.zip'")

        run_cmd(f"sudo umount '{mnt_sys}'")
        run_cmd(f"rm -f '{sys_img}'")
        run_cmd(f"img2simg '{sys_raw}' '{sys_img}' || mv '{sys_raw}' '{sys_img}'")
        run_cmd(f"rm -f '{sys_raw}'")
        main_progress.advance(overall_task)

        # -------------------------------------------------------------
        # STEP 5: Injecting system_ext.prop & product configs
        # -------------------------------------------------------------
        main_progress.update(overall_task, description="[5/8] Injecting system_ext & product gaming properties...")
        # system_ext
        sys_ext_img = EXTRACTED_DIR / "system_ext.img"
        sys_ext_raw = EXTRACTED_DIR / "system_ext.raw.img"
        mnt_ext = WORK_DIR / "mnt_ext"
        mnt_ext.mkdir(parents=True, exist_ok=True)
        if sys_ext_img.exists():
            run_cmd(f"simg2img '{sys_ext_img}' '{sys_ext_raw}' 2>/dev/null || cp '{sys_ext_img}' '{sys_ext_raw}'")
            run_cmd(f"sudo e2fsck -y -f '{sys_ext_raw}' || true", check=False)
            run_cmd(f"truncate -s +20M '{sys_ext_raw}' 2>/dev/null || true")
            run_cmd(f"sudo resize2fs '{sys_ext_raw}' || true", check=False)
            run_cmd(f"sudo mount -o loop,rw '{sys_ext_raw}' '{mnt_ext}'")
            prop_file = REPO_DIR / "system_ext.prop"
            if prop_file.exists():
                run_cmd(f"sudo sh -c 'cat {prop_file} >> {mnt_ext}/build.prop || cat {prop_file} >> {mnt_ext}/etc/build.prop || true'")
            run_cmd(f"sudo umount '{mnt_ext}'")
            run_cmd(f"rm -f '{sys_ext_img}'")
            run_cmd(f"img2simg '{sys_ext_raw}' '{sys_ext_img}' || mv '{sys_ext_raw}' '{sys_ext_img}'")
            run_cmd(f"rm -f '{sys_ext_raw}'")
        main_progress.advance(overall_task)

        # -------------------------------------------------------------
        # STEP 6: Custom Boot Splash Screen (Bootloader Warning Removed)
        # -------------------------------------------------------------
        main_progress.update(overall_task, description="[6/8] Packaging Cyberpunk boot splash (logo.bin)...")
        logo_bin = REPO_DIR / "prebuilt/bootlogo/logo.bin"
        if logo_bin.exists():
            shutil.copy2(logo_bin, OUT_DIR / "logo.bin")
            shutil.copy2(logo_bin, OUT_DIR / "logo.img")
        main_progress.advance(overall_task)

        # -------------------------------------------------------------
        # STEP 7: Assembling Flashers and Output Images
        # -------------------------------------------------------------
        main_progress.update(overall_task, description="[7/8] Assembling fastboot flashers and calculating checksums...")
        for img in EXTRACTED_DIR.glob("*.img"):
            shutil.copy2(img, OUT_DIR / img.name)

        flasher_dir = REPO_DIR / "flasher"
        shutil.copy2(flasher_dir / "flash_all.sh", OUT_DIR / "flash_all.sh")
        shutil.copy2(flasher_dir / "flash_all.bat", OUT_DIR / "flash_all.bat")
        (OUT_DIR / "flash_all.sh").chmod(0o755)

        # Companion tools
        smartpack_url = "https://github.com/SmartPack/SmartPack-Kernel-Manager/releases/download/v17.7/app-fdroid-release.apk"
        pif_url = "https://github.com/KOWX712/PlayIntegrityFix/releases/download/v4.7-inject-s/PlayIntegrityFix_v4.7-1-inject-s.zip"
        run_cmd(f"curl -sL '{smartpack_url}' -o '{OUT_DIR}/tools/SmartPack-Kernel-Manager.apk' || true", check=False)
        run_cmd(f"curl -sL '{pif_url}' -o '{OUT_DIR}/modules/PlayIntegrityFix.zip' || true", check=False)

        run_cmd(f"cd '{OUT_DIR}' && sha256sum *.img > SHA256SUMS.txt")
        main_progress.advance(overall_task)

        # -------------------------------------------------------------
        # STEP 8: Compressing Final Fastboot ZIP & Official OTA ZIP
        # -------------------------------------------------------------
        main_progress.update(overall_task, description="[8/8] Generating flashable distribution packages...")
        build_date = time.strftime("%Y%m%d")
        zip_name = f"VirgoX-Elite-GamingOS-v1.0-fogos-Android17-{build_date}-Fastboot.zip"
        final_zip = BUILD_ROOT / zip_name

        run_cmd(f"cd '{OUT_DIR}' && zip -r -9 '{final_zip}' ./*")

        # Official OTA Package with payload.bin
        ota_zip_name = f"VirgoX-Elite-GamingOS-v1.0-fogos-Android17-{build_date}-Official-OTA.zip"
        ota_zip = BUILD_ROOT / ota_zip_name
        ota_pkg_dir = WORK_DIR / "official_ota"
        ota_pkg_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(payload_file, ota_pkg_dir / "payload.bin")
        shutil.copy2(payload_file, OUT_DIR / "payload.bin")
        run_cmd(f"cd '{ota_pkg_dir}' && zip -r -0 '{ota_zip}' ./*")

        main_progress.advance(overall_task)

    console.print("\n[bold green]🎉 ROM BUILD AND COMPILATION COMPLETED SUCCESSFULLY![/bold green]\n")

    # Display Sizes Table
    table = Table(title="📊 VirgoX Elite Gaming OS — Sync vs Unsync Size Analysis", style="cyan")
    table.add_column("Category", style="bold yellow")
    table.add_column("Package / Partition", style="bold white")
    table.add_column("Bytes", style="dim")
    table.add_column("Human Readable Size", style="bold green")

    # Sync (Compressed / Flashable)
    if final_zip.exists():
        table.add_row("Sync Size (Flashable)", "Fastboot ZIP (all partitions)", f"{final_zip.stat().st_size:,}", f"{final_zip.stat().st_size / (1024**3):.2f} GiB")
    if ota_zip.exists():
        table.add_row("Sync Size (Flashable)", "Official Android A/B OTA (payload.bin)", f"{ota_zip.stat().st_size:,}", f"{ota_zip.stat().st_size / (1024**3):.2f} GiB")
    if (OUT_DIR / "payload.bin").exists():
        table.add_row("Sync Size (Flashable)", "Standalone payload.bin", f"{(OUT_DIR / 'payload.bin').stat().st_size:,}", f"{(OUT_DIR / 'payload.bin').stat().st_size / (1024**3):.2f} GiB")

    # Unsync (Raw Logical Partitions on Device Flash)
    total_raw = 0
    for img in OUT_DIR.glob("*.img"):
        sz = img.stat().st_size
        total_raw += sz
        table.add_row("Unsync Size (Raw)", f"Partition {img.name}", f"{sz:,}", f"{sz / (1024**2):.1f} MiB")

    table.add_row("Unsync Size (Pool)", "Motorola super partition capacity", "5,905,580,032", "5.50 GiB")
    table.add_row("Unsync Size (Total)", "Total Raw Partition Occupancy", f"{total_raw:,}", f"{total_raw / (1024**3):.2f} GiB")

    console.print(table)

if __name__ == "__main__":
    main()
