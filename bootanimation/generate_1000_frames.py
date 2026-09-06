#!/usr/bin/env python3
"""
VirgoX Elite GamingOS - 60 FPS 960-Frame Boot Animation Generator
Target: Motorola Moto G45 5G / G34 5G (720x1600)
Parts:
  - part0: Neural Network & Energy Grid Convergence (240 frames @ 60fps = 4s)
  - part1: VX Monogram Synthesis & Shockwave (240 frames @ 60fps = 4s)
  - part2: Holi SM6375 Gaming Core Ignition & HUD (240 frames @ 60fps = 4s)
  - part3: Ultra 60FPS Pulsing Core Infinite Loop (240 frames @ 60fps = 4s loop)
Total: 960 frames (16 seconds @ 60 FPS)
"""

import os
import sys
import math
import shutil
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from multiprocessing import Pool, cpu_count

WIDTH = 720
HEIGHT = 1600
FPS = 60

BASE_DIR = "/home/darkvirgoyt/VirgoX-Elite-GamingOS-Rom-Motorola-G45-FogOs/bootanimation"
PART0_DIR = os.path.join(BASE_DIR, "part0")
PART1_DIR = os.path.join(BASE_DIR, "part1")
PART2_DIR = os.path.join(BASE_DIR, "part2")
PART3_DIR = os.path.join(BASE_DIR, "part3")

for d in [PART0_DIR, PART1_DIR, PART2_DIR, PART3_DIR]:
    if os.path.exists(d):
        shutil.rmtree(d)
    os.makedirs(d, exist_ok=True)

CX = WIDTH // 2
CY = HEIGHT // 2 - 40

# Colors
BG_COLOR = (5, 8, 15)
CYAN = (0, 243, 255)
PURPLE = (189, 0, 255)
WHITE = (255, 255, 255)
DARK_BLUE = (15, 28, 50)
NEON_GREEN = (0, 255, 136)

def get_font(size):
    try:
        return ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", size)
    except:
        return ImageFont.load_default()

def get_mono_font(size):
    try:
        return ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf", size)
    except:
        return ImageFont.load_default()

font_huge = get_font(90)
font_large = get_font(42)
font_med = get_mono_font(24)
font_small = get_mono_font(18)

def draw_hud(draw, alpha=1.0):
    """Draw futuristic sci-fi gaming HUD corners and grid lines."""
    col = (int(0 * alpha), int(243 * alpha), int(255 * alpha))
    dim_col = (int(15 * alpha), int(40 * alpha), int(70 * alpha))
    
    # Top & bottom brackets
    bracket_size = 40
    margin = 40
    # Top-left
    draw.line([(margin, margin + bracket_size), (margin, margin), (margin + bracket_size, margin)], fill=col, width=2)
    # Top-right
    draw.line([(WIDTH - margin - bracket_size, margin), (WIDTH - margin, margin), (WIDTH - margin, margin + bracket_size)], fill=col, width=2)
    # Bottom-left
    draw.line([(margin, HEIGHT - margin - bracket_size), (margin, HEIGHT - margin), (margin + bracket_size, HEIGHT - margin)], fill=col, width=2)
    # Bottom-right
    draw.line([(WIDTH - margin - bracket_size, HEIGHT - margin), (WIDTH - margin, HEIGHT - margin), (WIDTH - margin, HEIGHT - margin - bracket_size)], fill=col, width=2)
    
    # Center crosshairs
    draw.line([(CX - 15, CY), (CX + 15, CY)], fill=dim_col, width=1)
    draw.line([(CX, CY - 15), (CX, CY + 15)], fill=dim_col, width=1)

def draw_vx_logo(draw, cx, cy, scale=1.0, alpha=1.0, glow=True):
    """Draw sharp geometric VX monogram."""
    c_cyan = (int(0 * alpha), int(243 * alpha), int(255 * alpha))
    c_purp = (int(189 * alpha), int(0 * alpha), int(255 * alpha))
    c_white = (int(255 * alpha), int(255 * alpha), int(255 * alpha))

    # Glow layer
    if glow and alpha > 0.3:
        glow_cyan = (int(0 * alpha * 0.4), int(243 * alpha * 0.4), int(255 * alpha * 0.4))
        for w in [12, 8]:
            # Left 'V'
            draw.line([(cx - int(70*scale), cy - int(50*scale)), (cx - int(25*scale), cy + int(50*scale))], fill=glow_cyan, width=w)
            draw.line([(cx - int(25*scale), cy + int(50*scale)), (cx + int(10*scale), cy - int(20*scale))], fill=glow_cyan, width=w)
            # Right 'X'
            draw.line([(cx - int(5*scale), cy - int(50*scale)), (cx + int(70*scale), cy + int(50*scale))], fill=glow_cyan, width=w)
            draw.line([(cx + int(70*scale), cy - int(50*scale)), (cx - int(5*scale), cy + int(50*scale))], fill=glow_cyan, width=w)

    # Main sharp lines
    w_main = max(2, int(6 * scale))
    draw.line([(cx - int(70*scale), cy - int(50*scale)), (cx - int(25*scale), cy + int(50*scale))], fill=c_cyan, width=w_main)
    draw.line([(cx - int(25*scale), cy + int(50*scale)), (cx + int(10*scale), cy - int(20*scale))], fill=c_cyan, width=w_main)
    draw.line([(cx - int(5*scale), cy - int(50*scale)), (cx + int(70*scale), cy + int(50*scale))], fill=c_purp, width=w_main)
    draw.line([(cx + int(70*scale), cy - int(50*scale)), (cx - int(5*scale), cy + int(50*scale))], fill=c_white, width=w_main)

def render_part0_frame(i):
    """Part 0 (240 frames): Energy particle streams & Neural grid converging."""
    t = i / 240.0
    img = Image.new("RGB", (WIDTH, HEIGHT), BG_COLOR)
    draw = ImageDraw.Draw(img)
    draw_hud(draw, alpha=min(1.0, t * 2.0))
    
    # Converging particle streams
    num_particles = 80
    np.random.seed(42)
    angles = np.random.uniform(0, 2 * math.pi, num_particles)
    initial_r = np.random.uniform(400, 800, num_particles)
    colors = [CYAN if j % 2 == 0 else PURPLE for j in range(num_particles)]
    
    current_progress = t ** 1.5
    for a, r, col in zip(angles, initial_r, colors):
        cr = r * (1.0 - current_progress)
        px = CX + cr * math.cos(a + t * 4)
        py = CY + cr * math.sin(a + t * 4)
        p_alpha = min(1.0, t * 1.8)
        p_col = (int(col[0] * p_alpha), int(col[1] * p_alpha), int(col[2] * p_alpha))
        draw.ellipse([(px - 3, py - 3), (px + 3, py + 3)], fill=p_col)

    # Core pulsing beacon
    core_rad = max(2, int(80 * (t ** 2)))
    core_alpha = min(1.0, t * 1.5)
    core_col = (int(0 * core_alpha), int(243 * core_alpha), int(255 * core_alpha))
    draw.ellipse([(CX - core_rad, CY - core_rad), (CX + core_rad, CY + core_rad)], outline=core_col, width=2)
    
    # Subtitle boot text
    if t > 0.4:
        txt = "SYSTEM_INITIALIZING // VERIFYING HARDWARE..."
        draw.text((CX, CY + 180), txt, fill=(0, int(243 * (t - 0.4) * 1.6), int(255 * (t - 0.4) * 1.6)), font=font_small, anchor="mm")
        
    out_path = os.path.join(PART0_DIR, f"frame_{i:04d}.png")
    img.save(out_path, "PNG", compress_level=1)

def render_part1_frame(i):
    """Part 1 (240 frames): VX Monogram Synthesis & Shockwave."""
    t = i / 240.0
    img = Image.new("RGB", (WIDTH, HEIGHT), BG_COLOR)
    draw = ImageDraw.Draw(img)
    draw_hud(draw, alpha=1.0)
    
    # Expanding shockwave rings in the first 60 frames
    if i < 60:
        ring_r = int((i / 60.0) * 350)
        ring_alpha = 1.0 - (i / 60.0)
        ring_col = (int(0 * ring_alpha), int(243 * ring_alpha), int(255 * ring_alpha))
        draw.ellipse([(CX - ring_r, CY - ring_r), (CX + ring_r, CY + ring_r)], outline=ring_col, width=4)

    # Logo scale from 1.5 down to 1.0 with elastic settling
    if t < 0.3:
        settle_t = t / 0.3
        scale = 1.3 - 0.3 * math.sin(settle_t * math.pi / 2)
        alpha = min(1.0, settle_t)
    else:
        scale = 1.0
        alpha = 1.0
        
    draw_vx_logo(draw, CX, CY, scale=scale, alpha=alpha, glow=True)
    
    # Brand typography reveal
    if t > 0.2:
        title_alpha = min(1.0, (t - 0.2) / 0.4)
        c_title = (int(255 * title_alpha), int(255 * title_alpha), int(255 * title_alpha))
        draw.text((CX, CY + 120), "VIRGOX", fill=c_title, font=font_large, anchor="mm")
        
    if t > 0.5:
        sub_alpha = min(1.0, (t - 0.5) / 0.3)
        c_sub = (int(0 * sub_alpha), int(243 * sub_alpha), int(255 * sub_alpha))
        draw.text((CX, CY + 175), "ELITE GAMING OS", fill=c_sub, font=font_med, anchor="mm")
        
    # Hexagonal radar scan line
    angle = t * 6 * math.pi
    radar_len = 160
    rx = CX + radar_len * math.cos(angle)
    ry = CY + radar_len * math.sin(angle)
    draw.line([(CX, CY), (rx, ry)], fill=(15, 80, 120), width=1)
    
    out_path = os.path.join(PART1_DIR, f"frame_{i:04d}.png")
    img.save(out_path, "PNG", compress_level=1)

def render_part2_frame(i):
    """Part 2 (240 frames): SM6375 Adreno & Holi Gaming Core Turbo Ignition."""
    t = i / 240.0
    img = Image.new("RGB", (WIDTH, HEIGHT), BG_COLOR)
    draw = ImageDraw.Draw(img)
    draw_hud(draw, alpha=1.0)
    
    # Pulsing Logo
    pulse = 1.0 + 0.04 * math.sin(t * 8 * math.pi)
    draw_vx_logo(draw, CX, CY, scale=pulse, alpha=1.0, glow=True)
    draw.text((CX, CY + 120), "VIRGOX", fill=WHITE, font=font_large, anchor="mm")
    draw.text((CX, CY + 175), "ELITE GAMING OS", fill=CYAN, font=font_med, anchor="mm")
    
    # Turbo Gauge Progress (0 to 100%)
    gauge_w = 400
    gauge_h = 10
    gx = CX - gauge_w // 2
    gy = CY + 240
    draw.rectangle([(gx, gy), (gx + gauge_w, gy + gauge_h)], outline=DARK_BLUE, width=2)
    
    fill_w = int(gauge_w * min(1.0, t * 1.1))
    if fill_w > 2:
        draw.rectangle([(gx + 2, gy + 2), (gx + fill_w, gy + gauge_h - 2)], fill=NEON_GREEN)
    
    # Specs & telemetry readout
    specs = [
        ("PLATFORM", "QUALCOMM SM6375 // HOLI"),
        ("GPU CLOCK", f"ADRENO 619 @ {int(600 + 240 * t)} MHz"),
        ("DISPLAY", "120Hz ULTRA SYNC ACTIVE"),
        ("TOUCH", "240Hz LOW-LATENCY ENGINE")
    ]
    cur_spec_idx = min(3, int(t * 4))
    lbl, val = specs[cur_spec_idx]
    draw.text((CX, gy + 40), f"[{lbl}] {val}", fill=WHITE, font=font_small, anchor="mm")
    
    # Fast digital scan beam
    beam_y = int((i * 12) % HEIGHT)
    draw.line([(60, beam_y), (WIDTH - 60, beam_y)], fill=(0, 243, 255), width=2)
    
    out_path = os.path.join(PART2_DIR, f"frame_{i:04d}.png")
    img.save(out_path, "PNG", compress_level=1)

def render_part3_frame(i):
    """Part 3 (240 frames): Infinite 60 FPS Smooth Ultra Gaming Loop."""
    t = i / 240.0
    img = Image.new("RGB", (WIDTH, HEIGHT), BG_COLOR)
    draw = ImageDraw.Draw(img)
    draw_hud(draw, alpha=1.0)
    
    # Rotating outer cyber ring
    ring_radius = 180
    num_ticks = 24
    rot_offset = t * 2 * math.pi
    for k in range(num_ticks):
        ang = rot_offset + k * (2 * math.pi / num_ticks)
        r1 = ring_radius
        r2 = ring_radius + (12 if k % 4 == 0 else 6)
        x1 = CX + r1 * math.cos(ang)
        y1 = CY + r1 * math.sin(ang)
        x2 = CX + r2 * math.cos(ang)
        y2 = CY + r2 * math.sin(ang)
        t_col = CYAN if k % 4 == 0 else PURPLE
        draw.line([(x1, y1), (x2, y2)], fill=t_col, width=2)
    
    # Pulsing core glow logo
    pulse = 1.0 + 0.05 * math.sin(t * 4 * math.pi)
    draw_vx_logo(draw, CX, CY, scale=pulse, alpha=1.0, glow=True)
    draw.text((CX, CY + 120), "VIRGOX", fill=WHITE, font=font_large, anchor="mm")
    draw.text((CX, CY + 175), "ELITE GAMING OS", fill=CYAN, font=font_med, anchor="mm")
    
    # Status bar
    cycle_pct = int((i / 240.0) * 100)
    draw.text((CX, CY + 240), f"READY // GAMING ENGINE ENGAGED [{cycle_pct:02d}%]", fill=NEON_GREEN, font=font_small, anchor="mm")
    
    # Dynamic frequency visualizer bars below
    num_bars = 16
    bar_w = 12
    bar_gap = 8
    total_w = num_bars * bar_w + (num_bars - 1) * bar_gap
    start_bx = CX - total_w // 2
    by = CY + 300
    for b in range(num_bars):
        bx = start_bx + b * (bar_w + bar_gap)
        bar_h = int(10 + 35 * abs(math.sin(t * 8 * math.pi + b * 0.4)))
        draw.rectangle([(bx, by - bar_h), (bx + bar_w, by)], fill=CYAN)

    out_path = os.path.join(PART3_DIR, f"frame_{i:04d}.png")
    img.save(out_path, "PNG", compress_level=1)

if __name__ == "__main__":
    print(f"Generating 960 frames across part0, part1, part2, part3 @ 60 FPS...")
    cores = max(1, cpu_count())
    with Pool(cores) as p:
        print("Rendering part0 (240 frames)...")
        p.map(render_part0_frame, range(240))
        print("Rendering part1 (240 frames)...")
        p.map(render_part1_frame, range(240))
        print("Rendering part2 (240 frames)...")
        p.map(render_part2_frame, range(240))
        print("Rendering part3 (240 frames)...")
        p.map(render_part3_frame, range(240))
    print("All 960 frames rendered successfully!")
