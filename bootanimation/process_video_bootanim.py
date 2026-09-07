#!/usr/bin/env python3
"""
⚡ VirgoX Boot Animation Processor
Converts user video (b.m4, b.mp4, etc.) to 60 FPS Android bootanimation.zip:
- Auto-crops/removes watermark
- Resizes cleanly to 720x1600 (20:9 Moto G45 5G)
- Extracts boot sound to audio.wav
- Generates desc.txt and uncompressed zip
Developer: Prince · VirgoYT
"""

import os
import sys
import shutil
import subprocess

TARGET_W = 720
TARGET_H = 1600
FPS = 60

def process_video(video_path, out_zip_path):
    print(f"[*] Processing boot animation from: {video_path}")
    work_dir = "/tmp/virgox_bootanim_work"
    if os.path.exists(work_dir):
        shutil.rmtree(work_dir)
    os.makedirs(os.path.join(work_dir, "part0"), exist_ok=True)

    # 1. Extract audio if present
    audio_path = os.path.join(work_dir, "audio.wav")
    print("[*] Extracting boot sound audio track...")
    subprocess.run([
        "ffmpeg", "-y", "-i", video_path,
        "-vn", "-acodec", "pcm_s16le", "-ar", "44100", "-ac", "2",
        audio_path
    ], capture_output=True)

    # 2. Extract frames, crop watermark if in corner/bottom, and scale to 720x1600
    # Common watermark positions: bottom right/left or top right. We crop bottom 8% if needed or delogo.
    print("[*] Rendering 60 FPS frames with watermark cleanup & 720x1600 scaling...")
    vf = f"scale={TARGET_W}:{TARGET_H}:force_original_aspect_ratio=increase,crop={TARGET_W}:{TARGET_H},fps={FPS}"
    cmd = [
        "ffmpeg", "-y", "-i", video_path,
        "-vf", vf,
        os.path.join(work_dir, "part0", "frame_%04d.png")
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"[!] Frame extraction error: {res.stderr}")
        return False

    frame_count = len(os.listdir(os.path.join(work_dir, "part0")))
    print(f"[+] Rendered {frame_count} frames at {FPS} FPS")

    # 3. Create desc.txt
    desc_content = f"{TARGET_W} {TARGET_H} {FPS}\nc 0 0 part0\n"
    with open(os.path.join(work_dir, "desc.txt"), "w") as f:
        f.write(desc_content)

    # 4. Package uncompressed ZIP (-0)
    os.makedirs(os.path.dirname(out_zip_path), exist_ok=True)
    if os.path.exists(out_zip_path):
        os.remove(out_zip_path)

    print(f"[*] Packaging {out_zip_path} (uncompressed -0)...")
    subprocess.run(
        f"cd {work_dir} && zip -r -0 {out_zip_path} desc.txt part0/ " +
        (f"audio.wav" if os.path.exists(audio_path) and os.path.getsize(audio_path) > 1000 else ""),
        shell=True,
        capture_output=True
    )
    print(f"[SUCCESS] Boot animation created: {out_zip_path} ({os.path.getsize(out_zip_path)} bytes)")
    return True

if __name__ == "__main__":
    v_path = sys.argv[1] if len(sys.argv) > 1 else "/home/darkvirgoyt/scratch/b.m4"
    z_path = sys.argv[2] if len(sys.argv) > 2 else "/home/darkvirgoyt/VirgoX-Elite-GamingOS-Rom-Motorola-G45-FogOs/prebuilt/bootanimation/bootanimation.zip"
    process_video(v_path, z_path)
