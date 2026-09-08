#!/usr/bin/env python3
"""
VirgoX Elite Gaming OS - Motorola Boot Logo Repacker
Maintained by: Prince · VirgoYT (VirgoYT707)
Device: Motorola Moto G45 5G / Moto G34 5G (fogos / SM6375)

Replaces all unlocked bootloader warning screens (orange1, orange2, yellow1, yellow2, red1, redeio1)
and boot splash (logo_boot, logo_carrier_retid) with a custom design while preserving all
fastboot UI icons and offline charging graphics.
"""

import sys
import os
import io
import json
import hashlib
from PIL import Image

def build_virgox_logo(splash_png_path, base_logo_dir, output_bin_path):
    if not os.path.isfile(splash_png_path):
        print(f"[-] Custom splash image not found: {splash_png_path}")
        sys.exit(1)
        
    custom_splash = Image.open(splash_png_path).convert("RGB")
    if custom_splash.size != (720, 1600):
        print(f"[*] Resizing custom splash from {custom_splash.size} to (720, 1600)...")
        custom_splash = custom_splash.resize((720, 1600), Image.Resampling.LANCZOS)
        
    data_json_path = os.path.join(base_logo_dir, "data.json")
    if not os.path.isfile(data_json_path):
        print(f"[-] Base data.json not found in {base_logo_dir}")
        sys.exit(1)
        
    with open(data_json_path, "r") as f:
        meta = json.load(f)
        
    names_to_replace = {
        "logo_boot", "orange1", "orange2", "yellow1", "yellow2",
        "red1", "redeio1", "logo_carrier_retid"
    }
    
    # Import encoder from moto_bootlogo
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from moto_bootlogo import MotoBootLogo
    
    # Temp working dir
    import tempfile
    import shutil
    with tempfile.TemporaryDirectory() as tmpdir:
        # Copy all base images
        for item in os.listdir(base_logo_dir):
            s = os.path.join(base_logo_dir, item)
            d = os.path.join(tmpdir, item)
            if os.path.isfile(s):
                shutil.copy2(s, d)
                
        # Overwrite warning and boot images
        for name in names_to_replace:
            dest_img = os.path.join(tmpdir, f"{name}.png")
            custom_splash.save(dest_img, "PNG")
            
        print(f"[+] Encapsulating {len(names_to_replace)} warning and splash frames with VirgoX Elite splash...")
        from moto_bootlogo import MotoBootLogo
        bootlogo_tool = MotoBootLogo(tmpdir, output_bin_path, None)
        
    print(f"[SUCCESS] Generated custom boot logo container: {output_bin_path} ({os.path.getsize(output_bin_path):,} bytes)")

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python3 build_logo.py <custom_splash.png> <extracted_base_dir> <output_logo.bin>")
        sys.exit(1)
    build_virgox_logo(sys.argv[1], sys.argv[2], sys.argv[3])
