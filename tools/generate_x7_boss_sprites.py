#!/usr/bin/env python3
"""
Generate X7 boss sprite sheets for the Mega Man X7 16-bit demake.

Each X7 boss currently uses X8 boss sprites. This script:
1. Reads the existing X8 boss sprite sheet to get exact dimensions and frame layout
2. Creates a new sprite sheet with the same dimensions
3. Draws X7 boss character pixel art in each frame position
4. Backs up the original and saves the new one in place

The .res binary SpriteFrames files reference atlas regions on the PNG,
so keeping the same PNG dimensions and frame positions preserves compatibility.
"""

import os
import sys
import shutil
from PIL import Image, ImageDraw

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BOSSES_DIR = os.path.join(BASE_DIR, "src", "Actors", "Bosses")
BACKUP_DIR = os.path.join(BASE_DIR, "tmp", "boss_sprites_backup")


def ensure_backup_dir():
    os.makedirs(BACKUP_DIR, exist_ok=True)


def detect_background_color(img):
    """Detect whether the sprite sheet uses transparent or black background."""
    w, h = img.size
    # Sample corners
    corners = [
        img.getpixel((0, 0)),
        img.getpixel((w-1, 0)),
        img.getpixel((0, h-1)),
        img.getpixel((w-1, h-1)),
    ]
    # If most corners are black (low alpha or RGB near 0)
    black_count = sum(1 for c in corners if len(c) >= 3 and c[0] < 10 and c[1] < 10 and c[2] < 10)
    if black_count >= 3:
        return "black"
    return "transparent"


def detect_frames(img, bg_type="transparent"):
    """Detect individual frame positions in a sprite sheet.
    Returns list of (x, y, w, h) bounding boxes for each frame."""
    w, h = img.size

    def is_content_pixel(x, y):
        px = img.getpixel((x, y))
        if bg_type == "black":
            return px[0] > 15 or px[1] > 15 or px[2] > 15
        else:
            return len(px) >= 4 and px[3] > 10

    # Find content rows (horizontal bands)
    row_has_content = []
    for y in range(h):
        has = False
        for x in range(0, w, 2):
            if is_content_pixel(x, y):
                has = True
                break
        row_has_content.append(has)

    # Group into bands
    bands = []
    in_band = False
    band_start = 0
    for y, has in enumerate(row_has_content):
        if has and not in_band:
            band_start = y
            in_band = True
        elif not has and in_band:
            bands.append((band_start, y))
            in_band = False
    if in_band:
        bands.append((band_start, h))

    # For each band, find frame columns
    frames = []
    for band_top, band_bot in bands:
        col_has_content = []
        for x in range(w):
            has = False
            for y in range(band_top, band_bot, 2):
                if is_content_pixel(x, y):
                    has = True
                    break
            col_has_content.append(has)

        in_frame = False
        frame_start = 0
        for x, has in enumerate(col_has_content):
            if has and not in_frame:
                frame_start = x
                in_frame = True
            elif not has and in_frame:
                frames.append((frame_start, band_top, x - frame_start, band_bot - band_top))
                in_frame = False
        if in_frame:
            frames.append((frame_start, band_top, w - frame_start, band_bot - band_top))

    return frames


def detect_grid_layout(img, bg_type="transparent"):
    """Detect a regular grid layout from the sprite sheet.
    Returns (cols, rows, cell_w, cell_h) or falls back to frame detection."""
    w, h = img.size
    frames = detect_frames(img, bg_type)
    if not frames:
        return None, None, None, None, []

    # Find the most common frame spacing
    # Group frames by row (similar y)
    rows_dict = {}
    for fx, fy, fw, fh in frames:
        # Find which row this belongs to
        found = False
        for ry in rows_dict:
            if abs(fy - ry) < 20:
                rows_dict[ry].append((fx, fy, fw, fh))
                found = True
                break
        if not found:
            rows_dict[fy] = [(fx, fy, fw, fh)]

    row_keys = sorted(rows_dict.keys())

    # Estimate cell size from row spacing
    if len(row_keys) >= 2:
        row_spacings = [row_keys[i+1] - row_keys[i] for i in range(len(row_keys)-1)]
        cell_h = max(set(row_spacings), key=row_spacings.count) if row_spacings else max(fh for _, _, _, fh in frames)
    else:
        cell_h = max(fh for _, _, _, fh in frames) if frames else h

    # Estimate column spacing from first full row
    max_row_len = max(len(v) for v in rows_dict.values())
    for ry in row_keys:
        if len(rows_dict[ry]) == max_row_len:
            row_frames = sorted(rows_dict[ry], key=lambda f: f[0])
            if len(row_frames) >= 2:
                col_spacings = [row_frames[i+1][0] - row_frames[i][0]
                                for i in range(len(row_frames)-1)]
                cell_w = max(set(col_spacings), key=col_spacings.count)
            else:
                cell_w = max(fw for _, _, fw, _ in frames)
            break
    else:
        cell_w = max(fw for _, _, fw, _ in frames) if frames else w

    n_cols = max(len(v) for v in rows_dict.values())
    n_rows = len(row_keys)

    return n_cols, n_rows, cell_w, cell_h, frames


# ============================================================================
# PIXEL ART DRAWING FUNCTIONS
# ============================================================================

def draw_pixel_block(draw, x, y, pixels, palette, scale=1):
    """Draw a block of pixels from a 2D array of palette indices.
    pixels is list of strings, each char maps to a palette color.
    ' ' = transparent, '.' = outline color (palette[0])
    """
    for row_idx, row in enumerate(pixels):
        for col_idx, ch in enumerate(row):
            if ch == ' ':
                continue
            if ch in palette:
                color = palette[ch]
                px = x + col_idx * scale
                py = y + row_idx * scale
                if scale == 1:
                    draw.point((px, py), fill=color)
                else:
                    draw.rectangle([px, py, px + scale - 1, py + scale - 1], fill=color)


# ============================================================================
# SOLDIER STONEKONG - Big rocky gorilla
# Colors: gray body, brown armor, orange accents, dark outline
# ============================================================================

STONEKONG_PALETTE = {
    '.': (20, 15, 25, 255),       # dark outline
    'G': (100, 95, 90, 255),      # gray body
    'g': (140, 135, 125, 255),    # light gray
    'B': (90, 60, 35, 255),       # brown armor
    'b': (130, 90, 55, 255),      # light brown
    'O': (200, 140, 50, 255),     # orange accent
    'o': (240, 180, 80, 255),     # light orange
    'W': (220, 220, 210, 255),    # white highlight
    'E': (200, 30, 30, 255),      # red eye
    'D': (60, 50, 45, 255),       # dark shadow
    'H': (170, 155, 140, 255),    # highlight
}

def stonekong_idle(draw, cx, cy, frame=0):
    """Draw Stonekong idle pose. cx, cy = center of frame."""
    # Breathing animation - slight y offset
    bob = [0, 0, -1, -1, 0, 0, 1, 1][frame % 8]
    y_off = cy - 28 + bob
    x_off = cx - 18

    # Head (gorilla-like, rocky crest)
    head = [
        "    ..BBB..     ",
        "   .BBbBBB.     ",
        "  .BBooBBBB.    ",
        "  .BBBBBBBB.    ",
        " .GGG.GG.GGG.  ",
        " .GgG.EE.GgG.  ",
        " .GGG....GGG.  ",
        "  .GGGGGGGG.   ",
        "   .GGggGG.    ",
    ]
    draw_pixel_block(draw, x_off + 2, y_off, head, STONEKONG_PALETTE)

    # Body (wide, muscular)
    body = [
        "  ..BBBBBB..  ",
        " .BBBBBBBBBb. ",
        " .BbBBGGBBbB. ",
        " .BBBGGGGBBb. ",
        " .BBBGGGGBBB. ",
        "  .BBGGGGBB.  ",
        "  .BBBBBBBB.  ",
        "  .BbBBBBbB.  ",
    ]
    draw_pixel_block(draw, x_off + 2, y_off + 9, body, STONEKONG_PALETTE)

    # Arms (big fists)
    left_arm = [
        " .BB.       ",
        ".BBBB.      ",
        ".BgBBB.     ",
        " .GGG.      ",
        ".GGgGG.     ",
        ".GGGGGG.    ",
        " .GGGG.     ",
        "  ....      ",
    ]
    draw_pixel_block(draw, x_off - 4, y_off + 10, left_arm, STONEKONG_PALETTE)

    right_arm = [
        "       .BB. ",
        "      .BBBB.",
        "     .BBBgB.",
        "      .GGG. ",
        "     .GGgGG.",
        "    .GGGGGG.",
        "     .GGGG. ",
        "      ....  ",
    ]
    draw_pixel_block(draw, x_off + 14, y_off + 10, right_arm, STONEKONG_PALETTE)

    # Legs
    legs = [
        "  .BB..BB.  ",
        "  .BB..BB.  ",
        "  .Bb..bB.  ",
        "  .GG..GG.  ",
        " .GGG..GGG. ",
        " .GGG..GGG. ",
        " .....  .....",
    ]
    draw_pixel_block(draw, x_off + 2, y_off + 17, legs, STONEKONG_PALETTE)


def stonekong_attack(draw, cx, cy, frame=0):
    """Stonekong in attack pose with arm raised."""
    y_off = cy - 30
    x_off = cx - 20

    # Head (leaning forward aggressively)
    head = [
        "     ..BBB..    ",
        "    .BBbBBB.    ",
        "   .BBooBBBB.   ",
        "   .BBBBBBBB.   ",
        "  .GGG.GG.GGG.  ",
        "  .GgG.EE.GgG.  ",
        "  .GGG....GGG.  ",
        "   .GGGGGGGG.   ",
        "    .GGooGG.    ",
    ]
    draw_pixel_block(draw, x_off, y_off, head, STONEKONG_PALETTE)

    # Body with raised arm
    body = [
        "  .OBBBBBBBO.      ",
        " .BBBBBBBBBBBb.    ",
        " .BbBBGGBBbB..     ",
        " .BBBGGGGBBb.      ",
        "  .BBBGGGGBB.      ",
        "  .BBGGGGBB.       ",
        "  .BBBBBBBB.       ",
    ]
    draw_pixel_block(draw, x_off + 1, y_off + 9, body, STONEKONG_PALETTE)

    # Right arm raised up with fist
    raised_arm = [
        "        .GGG. ",
        "       .GGGG. ",
        "       .GgGG. ",
        "        .BB.  ",
        "        .BB.  ",
        "       .BBb.  ",
    ]
    draw_pixel_block(draw, x_off + 14, y_off + 2, raised_arm, STONEKONG_PALETTE)

    # Left arm (forward punch)
    left_fist = [
        ".GGG.  ",
        ".GgGG. ",
        ".GGGG. ",
        " .GG.  ",
    ]
    draw_pixel_block(draw, x_off - 5, y_off + 14, left_fist, STONEKONG_PALETTE)

    # Legs (wider stance)
    legs = [
        "  .BB..BB.    ",
        " .BBB..BBB.   ",
        " .GGG..GGG.   ",
        " .GGG..GGG.   ",
        " ....   ....  ",
    ]
    draw_pixel_block(draw, x_off + 2, y_off + 20, legs, STONEKONG_PALETTE)


def stonekong_jump(draw, cx, cy, frame=0):
    """Stonekong jumping."""
    y_off = cy - 26
    x_off = cx - 16

    head = [
        "    ..BBB..   ",
        "   .BBbBBB.   ",
        "  .BBooBBBB.  ",
        "  .GGG.GG.GG. ",
        "  .GgG.EE.GG. ",
        "   .GG....GG. ",
        "   .GGGGGGGG. ",
    ]
    draw_pixel_block(draw, x_off, y_off, head, STONEKONG_PALETTE)

    body = [
        "  .BBBBBB.  ",
        " .BBBBBBB.  ",
        " .BBbGGbBB. ",
        " .BBBGGBBB. ",
        "  .BBBBBB.  ",
    ]
    draw_pixel_block(draw, x_off + 2, y_off + 7, body, STONEKONG_PALETTE)

    # Legs tucked
    legs = [
        " .GG. .GG. ",
        " .GG. .GG. ",
        " .BB. .BB. ",
        "  ..   ..  ",
    ]
    draw_pixel_block(draw, x_off + 3, y_off + 12, legs, STONEKONG_PALETTE)


# ============================================================================
# TORNADO TONION - Round onion body, small limbs
# Colors: green body, yellow/cream highlights, dark outline
# ============================================================================

TONION_PALETTE = {
    '.': (15, 30, 15, 255),       # dark outline
    'G': (50, 140, 50, 255),      # green body
    'g': (90, 180, 70, 255),      # light green
    'Y': (220, 200, 80, 255),     # yellow
    'y': (250, 235, 130, 255),    # light yellow
    'W': (240, 240, 230, 255),    # white
    'E': (30, 30, 120, 255),      # blue eyes
    'P': (180, 100, 180, 255),    # purple accent
    'D': (30, 70, 30, 255),       # dark green
    'C': (230, 220, 190, 255),    # cream
}

def tonion_idle(draw, cx, cy, frame=0):
    bob = [0, -1, -1, 0, 1, 1, 0, 0][frame % 8]
    y_off = cy - 20 + bob
    x_off = cx - 14

    # Top leaves/sprout
    sprout = [
        "    .gg.     ",
        "   .gGGg.    ",
        "   .GDGg.    ",
        "    .GG.     ",
        "     ..      ",
    ]
    draw_pixel_block(draw, x_off + 3, y_off, sprout, TONION_PALETTE)

    # Round body
    body = [
        "    ......    ",
        "  ..GGGGgg..  ",
        " .GGGGGGGGGg. ",
        " .GGG.EE.GGg. ",
        " .GGG....GGGg.",
        " .GGGGCCGGGg. ",
        " .GgGGGGGGGg. ",
        " .GgGGGGGGg.  ",
        "  .gGGGGGg.   ",
        "   ..YYYY..   ",
        "    .YYYY.    ",
    ]
    draw_pixel_block(draw, x_off, y_off + 5, body, TONION_PALETTE)

    # Small arms
    arms = [
        ".Y.          .Y.",
        ".YY.        .YY.",
        " ..          ..  ",
    ]
    draw_pixel_block(draw, x_off - 3, y_off + 11, arms, TONION_PALETTE)

    # Small feet
    feet = [
        "   .YY..YY.   ",
        "   .YY..YY.   ",
        "    ..  ..    ",
    ]
    draw_pixel_block(draw, x_off + 1, y_off + 16, feet, TONION_PALETTE)


def tonion_spin(draw, cx, cy, frame=0):
    """Tonion spinning attack."""
    rot = frame % 4
    y_off = cy - 18
    x_off = cx - 14

    body = [
        "    ......    ",
        "  ..gGGGGg..  ",
        " .gGGGGGGGGG. ",
        " .GGGGGGGGGGG.",
        " .gGGGGGGGGg. ",
        " .gGGGGGGGGg. ",
        " .gGGGGGGGg.  ",
        "  ..GGGGGg.   ",
        "   ........   ",
    ]
    draw_pixel_block(draw, x_off, y_off + 2, body, TONION_PALETTE)

    # Motion lines around body based on frame
    if rot % 2 == 0:
        draw.line([(cx - 18, cy - 2), (cx - 22, cy - 6)], fill=TONION_PALETTE['g'], width=1)
        draw.line([(cx + 18, cy + 2), (cx + 22, cy + 6)], fill=TONION_PALETTE['g'], width=1)
    else:
        draw.line([(cx - 18, cy + 2), (cx - 22, cy + 6)], fill=TONION_PALETTE['g'], width=1)
        draw.line([(cx + 18, cy - 2), (cx + 22, cy - 6)], fill=TONION_PALETTE['g'], width=1)


# ============================================================================
# SPLASH WARFLY - Dragonfly shape, sleek, blue/teal
# ============================================================================

WARFLY_PALETTE = {
    '.': (10, 20, 35, 255),       # dark outline
    'B': (30, 100, 140, 255),     # blue body
    'b': (60, 150, 180, 255),     # light blue
    'T': (40, 160, 150, 255),     # teal
    't': (80, 200, 190, 255),     # light teal
    'W': (200, 230, 240, 255),    # white/wing
    'w': (160, 200, 220, 255),    # translucent wing
    'E': (220, 50, 50, 255),      # red eye
    'D': (15, 40, 60, 255),       # dark shadow
    'S': (120, 180, 200, 255),    # silver
}

def warfly_idle(draw, cx, cy, frame=0):
    bob = [0, -1, -1, 0, 1, 1][frame % 6]
    y_off = cy - 14 + bob
    x_off = cx - 20

    # Wings (translucent feel)
    wings = [
        "  .www.    .www.  ",
        " .wWWWw.  .wWWWw. ",
        " .wWWWw.  .wWWWw. ",
        "  .www.    .www.  ",
    ]
    draw_pixel_block(draw, x_off, y_off - 4, wings, WARFLY_PALETTE)

    # Head
    head = [
        "      ....      ",
        "     .BBBB.     ",
        "    .BE..EB.    ",
        "    .BBBBBB.    ",
        "     .bBBb.     ",
    ]
    draw_pixel_block(draw, x_off + 4, y_off, head, WARFLY_PALETTE)

    # Long body
    body = [
        "     .TTTT.     ",
        "    .TTtTTT.    ",
        "    .TTTTTT.    ",
        "    .TtTTtT.    ",
        "     .TTTT.     ",
        "      .TT.      ",
        "      .TT.      ",
        "       ..       ",
    ]
    draw_pixel_block(draw, x_off + 4, y_off + 5, body, WARFLY_PALETTE)

    # Legs (insect-like thin lines)
    draw.line([(cx - 6, cy + 2), (cx - 10, cy + 8)], fill=WARFLY_PALETTE['B'], width=1)
    draw.line([(cx + 6, cy + 2), (cx + 10, cy + 8)], fill=WARFLY_PALETTE['B'], width=1)
    draw.line([(cx - 4, cy + 4), (cx - 8, cy + 10)], fill=WARFLY_PALETTE['B'], width=1)
    draw.line([(cx + 4, cy + 4), (cx + 8, cy + 10)], fill=WARFLY_PALETTE['B'], width=1)


# ============================================================================
# FLAME HYENARD - Medium hyena, red/orange, pointed ears
# ============================================================================

HYENARD_PALETTE = {
    '.': (40, 15, 10, 255),       # dark outline
    'R': (180, 50, 30, 255),      # red body
    'r': (220, 80, 40, 255),      # light red
    'O': (230, 150, 40, 255),     # orange
    'o': (250, 190, 70, 255),     # light orange
    'Y': (250, 220, 80, 255),     # yellow flame
    'W': (250, 250, 200, 255),    # white hot
    'E': (250, 250, 50, 255),     # yellow eyes
    'D': (80, 30, 20, 255),       # dark shadow
    'G': (120, 110, 100, 255),    # gray metal
    'B': (40, 35, 30, 255),       # black
}

def hyenard_idle(draw, cx, cy, frame=0):
    bob = [0, -1, 0, 1][frame % 4]
    y_off = cy - 24 + bob
    x_off = cx - 16

    # Pointed ears
    ears = [
        "  .R.    .R.  ",
        " .RR.    .RR. ",
        " .Rr.    .rR. ",
    ]
    draw_pixel_block(draw, x_off + 2, y_off, ears, HYENARD_PALETTE)

    # Head (hyena snout)
    head = [
        "   .RRRRRR.    ",
        "  .RRR.EE.RR.  ",
        "  .RRRRRRRR.   ",
        "  .RrOOOOrR.   ",
        "   .RRRRRR.    ",
        "   ..OWWO..    ",
    ]
    draw_pixel_block(draw, x_off + 1, y_off + 3, head, HYENARD_PALETTE)

    # Body
    body = [
        "   .RRRRRR.   ",
        "  .RRrRRRrR.  ",
        "  .RRGGGGGRR. ",
        "  .RRGGGGRR.  ",
        "   .RRRRRR.   ",
        "   .RRrRrR.   ",
    ]
    draw_pixel_block(draw, x_off + 1, y_off + 9, body, HYENARD_PALETTE)

    # Arms
    draw_pixel_block(draw, x_off - 2, y_off + 11, [
        ".RR.",
        ".Rr.",
        ".GG.",
        " .. ",
    ], HYENARD_PALETTE)
    draw_pixel_block(draw, x_off + 17, y_off + 11, [
        ".RR.",
        ".rR.",
        ".GG.",
        " .. ",
    ], HYENARD_PALETTE)

    # Legs
    legs = [
        "   .RR..RR.   ",
        "   .Rr..rR.   ",
        "   .GG..GG.   ",
        "   .GG..GG.   ",
        "    ..  ..    ",
    ]
    draw_pixel_block(draw, x_off + 2, y_off + 15, legs, HYENARD_PALETTE)

    # Flame hair (animated)
    if frame % 2 == 0:
        flames = [
            " .Yo.  ",
            ".YOY.  ",
            " .Y.   ",
        ]
        draw_pixel_block(draw, x_off + 8, y_off - 3, flames, HYENARD_PALETTE)
    else:
        flames = [
            "  .oY. ",
            "  .YOY.",
            "   .Y. ",
        ]
        draw_pixel_block(draw, x_off + 8, y_off - 3, flames, HYENARD_PALETTE)


# ============================================================================
# RIDE BOARSKI - Stocky boar, dark red/brown, tusks
# ============================================================================

BOARSKI_PALETTE = {
    '.': (30, 15, 15, 255),       # dark outline
    'R': (140, 50, 40, 255),      # dark red body
    'r': (180, 70, 55, 255),      # lighter red
    'B': (90, 55, 35, 255),       # brown
    'b': (130, 85, 55, 255),      # light brown
    'W': (230, 225, 210, 255),    # white tusks
    'G': (100, 100, 100, 255),    # gray metal
    'g': (150, 150, 145, 255),    # light gray
    'E': (200, 40, 40, 255),      # red eyes
    'D': (60, 30, 25, 255),       # dark shadow
    'M': (110, 60, 100, 255),     # mohawk purple
    'm': (150, 80, 140, 255),     # light mohawk
}

def boarski_idle(draw, cx, cy, frame=0):
    bob = [0, 0, -1, 0, 0, 1][frame % 6]
    y_off = cy - 26 + bob
    x_off = cx - 18

    # Mohawk
    mohawk = [
        "    .mM.   ",
        "   .mMM.   ",
        "   .MMm.   ",
        "    .M.    ",
    ]
    draw_pixel_block(draw, x_off + 5, y_off, mohawk, BOARSKI_PALETTE)

    # Head with tusks and snout
    head = [
        "   .RRRRRR.    ",
        "  .RRR.EE.RR.  ",
        "  .RRRRRrRRR.  ",
        "  .RRbbRRbbR.  ",
        " .W.RRRRRR..W. ",
        " .W..RRrRR..W. ",
        "  .  .RRRR. .  ",
    ]
    draw_pixel_block(draw, x_off + 1, y_off + 4, head, BOARSKI_PALETTE)

    # Stocky body (with wheel shoulders)
    body = [
        "  .GGRRRRGG.  ",
        " .gGGRRRRGGg. ",
        " .GGRRRRRRGGG.",
        " .GGRRRRRRGG. ",
        "  .GRRRRRRG.  ",
        "  .GRRRRRG.   ",
    ]
    draw_pixel_block(draw, x_off + 1, y_off + 11, body, BOARSKI_PALETTE)

    # Legs (stocky)
    legs = [
        "  .RR. .RR.   ",
        "  .RR. .RR.   ",
        "  .BB. .BB.   ",
        "  .GG. .GG.   ",
        "  ...   ...   ",
    ]
    draw_pixel_block(draw, x_off + 2, y_off + 17, legs, BOARSKI_PALETTE)


# ============================================================================
# SNIPE ANTEATOR - Lanky, purple/dark, long snout, scope eye
# ============================================================================

ANTEATOR_PALETTE = {
    '.': (20, 10, 30, 255),       # dark outline
    'P': (80, 50, 100, 255),      # purple body
    'p': (120, 80, 140, 255),     # light purple
    'D': (50, 30, 60, 255),       # dark purple
    'G': (100, 100, 110, 255),    # gray metal
    'g': (150, 150, 155, 255),    # light gray
    'R': (180, 40, 40, 255),      # red scope
    'r': (220, 60, 60, 255),      # light red scope
    'W': (220, 215, 225, 255),    # white
    'E': (160, 220, 50, 255),     # green eye
    'B': (40, 30, 50, 255),       # black
}

def anteator_idle(draw, cx, cy, frame=0):
    bob = [0, 0, -1, -1, 0, 0][frame % 6]
    y_off = cy - 28 + bob
    x_off = cx - 16

    # Long snout extending left
    snout = [
        " ......          ",
        ".PPPPP.          ",
        ".PPppPP.         ",
        " ......          ",
    ]
    draw_pixel_block(draw, x_off - 8, y_off + 5, snout, ANTEATOR_PALETTE)

    # Head with scope
    head = [
        "    .rR.        ",
        "   .rRR.        ",
        "   .PPPPPP.     ",
        "   .PP.E.PP.    ",
        "   .PPPPPPPP.   ",
        "   .PPppPPPP.   ",
        "    .PPPPPP.    ",
    ]
    draw_pixel_block(draw, x_off + 2, y_off, head, ANTEATOR_PALETTE)

    # Thin body
    body = [
        "    .PPPPPP.   ",
        "   .PPGGGGPP.  ",
        "   .PPGGGGPP.  ",
        "    .PPPPPP.   ",
        "    .PPppPP.   ",
        "    .PPPPPP.   ",
    ]
    draw_pixel_block(draw, x_off + 1, y_off + 7, body, ANTEATOR_PALETTE)

    # Thin arms
    draw_pixel_block(draw, x_off - 2, y_off + 9, [
        ".PP.",
        ".Pp.",
        ".PP.",
        " .G.",
        "  ..",
    ], ANTEATOR_PALETTE)
    draw_pixel_block(draw, x_off + 17, y_off + 9, [
        ".PP.",
        ".pP.",
        ".PP.",
        ".G. ",
        "..  ",
    ], ANTEATOR_PALETTE)

    # Long thin legs
    legs = [
        "    .PP..PP.   ",
        "    .PP..PP.   ",
        "    .Pp..pP.   ",
        "    .PP..PP.   ",
        "    .GG..GG.   ",
        "     ..  ..    ",
    ]
    draw_pixel_block(draw, x_off + 1, y_off + 13, legs, ANTEATOR_PALETTE)


# ============================================================================
# WIND CROWRANG - Crow, black/purple, beak, wing-arms
# ============================================================================

CROWRANG_PALETTE = {
    '.': (10, 5, 15, 255),        # dark outline
    'K': (35, 25, 50, 255),       # black/dark purple body
    'P': (70, 50, 90, 255),       # purple
    'p': (110, 80, 130, 255),     # light purple
    'B': (40, 35, 45, 255),       # near-black
    'W': (220, 215, 225, 255),    # white
    'Y': (220, 180, 50, 255),     # yellow beak
    'y': (250, 210, 80, 255),     # light yellow
    'E': (200, 50, 50, 255),      # red eyes
    'G': (80, 75, 90, 255),       # gray
    'F': (100, 80, 120, 255),     # feather
    'f': (140, 110, 160, 255),    # light feather
}

def crowrang_idle(draw, cx, cy, frame=0):
    bob = [0, -1, -1, 0][frame % 4]
    y_off = cy - 26 + bob
    x_off = cx - 18

    # Feathered head crest
    crest = [
        "    .KK.     ",
        "   .KPK.     ",
        "   .KPK.     ",
        "    .K.      ",
    ]
    draw_pixel_block(draw, x_off + 5, y_off, crest, CROWRANG_PALETTE)

    # Head with beak
    head = [
        "   .KKKKKK.    ",
        "  .KKKK.E.KK.  ",
        "  .KKKKKKKKK.  ",
        "  .KKpKKKpKK.  ",
        " .YY.KKKKKK.   ",
        " .Yy.KKKK.     ",
        "  ..  ....     ",
    ]
    draw_pixel_block(draw, x_off + 1, y_off + 4, head, CROWRANG_PALETTE)

    # Body
    body = [
        "   .PPPPPP.    ",
        "  .PPpKKPPP.   ",
        "  .PPKKKKPP.   ",
        "  .PPKKKPP.    ",
        "   .PPPPPP.    ",
    ]
    draw_pixel_block(draw, x_off + 2, y_off + 11, body, CROWRANG_PALETTE)

    # Wing-arms (folded)
    draw_pixel_block(draw, x_off - 3, y_off + 12, [
        " .fF.",
        ".fFFf.",
        ".FFFFF.",
        " .fff.",
        "  ... ",
    ], CROWRANG_PALETTE)
    draw_pixel_block(draw, x_off + 17, y_off + 12, [
        " .Ff. ",
        ".fFFf.",
        ".FFFFF.",
        " .fff. ",
        "  ...  ",
    ], CROWRANG_PALETTE)

    # Legs
    legs = [
        "   .KK..KK.   ",
        "   .PP..PP.   ",
        "   .GG..GG.   ",
        "  .YYY..YYY.  ",
        "   ..    ..   ",
    ]
    draw_pixel_block(draw, x_off + 2, y_off + 16, legs, CROWRANG_PALETTE)


# ============================================================================
# VANISHING GUNGAROO - Tall kangaroo, tan/brown, boxing gloves
# ============================================================================

GUNGAROO_PALETTE = {
    '.': (30, 20, 15, 255),       # dark outline
    'T': (170, 140, 90, 255),     # tan body
    't': (200, 175, 120, 255),    # light tan
    'B': (120, 90, 55, 255),      # brown
    'b': (160, 125, 80, 255),     # light brown
    'R': (180, 40, 40, 255),      # red boxing gloves
    'r': (220, 70, 50, 255),      # light red
    'W': (240, 235, 220, 255),    # white belly
    'E': (30, 30, 120, 255),      # blue eyes
    'G': (100, 95, 90, 255),      # gray metal
    'D': (80, 60, 40, 255),       # dark shadow
    'C': (220, 200, 160, 255),    # cream belly
}

def gungaroo_idle(draw, cx, cy, frame=0):
    bob = [0, -1, 0, 1][frame % 4]
    y_off = cy - 32 + bob
    x_off = cx - 14

    # Tall ears
    ears = [
        "  .T.    .T.  ",
        " .TT.    .TT. ",
        " .Tt.    .tT. ",
        " .TT.    .TT. ",
    ]
    draw_pixel_block(draw, x_off, y_off, ears, GUNGAROO_PALETTE)

    # Head
    head = [
        "  .TTTTTT.  ",
        " .TTT.E.TT. ",
        " .TTTTTTTT. ",
        " .TTtCCtTT. ",
        "  .TTCCTT.  ",
        "   .TTTT.   ",
    ]
    draw_pixel_block(draw, x_off + 1, y_off + 4, head, GUNGAROO_PALETTE)

    # Body (slim with white belly)
    body = [
        "   .BBBBBB.   ",
        "  .BBWWWWBB.  ",
        "  .BBWWWWBB.  ",
        "  .BBbBBbBB.  ",
        "   .BBBBBB.   ",
        "   .BBbbBB.   ",
    ]
    draw_pixel_block(draw, x_off, y_off + 10, body, GUNGAROO_PALETTE)

    # Boxing glove arms
    draw_pixel_block(draw, x_off - 5, y_off + 11, [
        " .RR. ",
        ".RRrR.",
        ".RRRR.",
        " .RR. ",
        "  .B. ",
    ], GUNGAROO_PALETTE)
    draw_pixel_block(draw, x_off + 16, y_off + 11, [
        " .RR. ",
        ".RrRR.",
        ".RRRR.",
        " .RR. ",
        "  .B. ",
    ], GUNGAROO_PALETTE)

    # Legs (long kangaroo legs)
    legs = [
        "   .BB..BB.   ",
        "   .TT..TT.   ",
        "   .TT..TT.   ",
        "  .TTT..TTT.  ",
        " .TTTT..TTTT. ",
        "  ....  ....  ",
    ]
    draw_pixel_block(draw, x_off, y_off + 16, legs, GUNGAROO_PALETTE)

    # Tail
    tail = [
        "          .TT.",
        "         .TtT.",
        "        .TTT. ",
        "       .TT.   ",
    ]
    draw_pixel_block(draw, x_off + 4, y_off + 18, tail, GUNGAROO_PALETTE)


# ============================================================================
# RED (Boss) - Humanoid swordsman, red armor, cape
# ============================================================================

RED_PALETTE = {
    '.': (30, 10, 10, 255),       # dark outline
    'R': (180, 30, 30, 255),      # red armor
    'r': (220, 60, 50, 255),      # light red
    'D': (120, 20, 20, 255),      # dark red
    'G': (100, 100, 110, 255),    # gray
    'g': (160, 160, 165, 255),    # light gray
    'W': (240, 235, 230, 255),    # white
    'Y': (230, 200, 60, 255),     # gold
    'B': (60, 55, 70, 255),       # dark blue/black
    'E': (250, 250, 100, 255),    # yellow eyes
    'S': (180, 190, 200, 255),    # silver sword
    's': (220, 225, 230, 255),    # light silver
}

def red_idle(draw, cx, cy, frame=0):
    bob = [0, 0, -1, -1, 0, 0][frame % 6]
    y_off = cy - 30 + bob
    x_off = cx - 16

    # Hair/helmet
    hair = [
        "    .RRRR.   ",
        "   .RRrrRR.  ",
        "   .RRrrRR.  ",
        "  .RRRRRRRR. ",
    ]
    draw_pixel_block(draw, x_off + 1, y_off, hair, RED_PALETTE)

    # Head
    head = [
        "  .RRRRRR.  ",
        " .RR.EE.RR. ",
        " .RRRRRRRR. ",
        " .RRggggRR. ",
        "  .RRRRRR.  ",
    ]
    draw_pixel_block(draw, x_off + 2, y_off + 4, head, RED_PALETTE)

    # Cape flowing behind
    cape = [
        "         .DD.",
        "        .DDD.",
        "       .DDDD.",
        "       .DDDDD.",
        "       .DDDD.",
        "        .DDD.",
    ]
    draw_pixel_block(draw, x_off + 10, y_off + 8, cape, RED_PALETTE)

    # Body with armor
    body = [
        "   .YRRRRRY.  ",
        "  .RRRRRRRR.  ",
        "  .RRrGGrRR.  ",
        "  .RRRGGRRR.  ",
        "   .RRRRRR.   ",
        "   .RRrrRR.   ",
    ]
    draw_pixel_block(draw, x_off + 1, y_off + 9, body, RED_PALETTE)

    # Arms (one holds sword)
    draw_pixel_block(draw, x_off - 3, y_off + 10, [
        ".RR.",
        ".Rg.",
        ".RR.",
        ".Ss.",
        ".Ss.",
        ".Ss.",
        " .s.",
        "  ..",
    ], RED_PALETTE)
    draw_pixel_block(draw, x_off + 17, y_off + 10, [
        ".RR.",
        ".gR.",
        ".RR.",
        " .. ",
    ], RED_PALETTE)

    # Legs
    legs = [
        "   .RR..RR.   ",
        "   .Rr..rR.   ",
        "   .RR..RR.   ",
        "   .GG..GG.   ",
        "   .GG..GG.   ",
        "    ..  ..    ",
    ]
    draw_pixel_block(draw, x_off + 2, y_off + 15, legs, RED_PALETTE)


# ============================================================================
# SIGMA X7 - Tall imposing figure, blue/purple, energy sword
# ============================================================================

SIGMA_PALETTE = {
    '.': (15, 10, 25, 255),       # dark outline
    'P': (80, 50, 120, 255),      # purple body
    'p': (120, 80, 160, 255),     # light purple
    'B': (40, 40, 80, 255),       # dark blue
    'b': (70, 70, 130, 255),      # blue
    'R': (180, 40, 40, 255),      # red gem
    'W': (230, 225, 235, 255),    # white
    'Y': (250, 230, 80, 255),     # yellow energy
    'G': (100, 100, 110, 255),    # gray
    'g': (150, 150, 160, 255),    # light gray
    'E': (200, 50, 50, 255),      # red eyes
    'S': (140, 180, 240, 255),    # energy sword blue
    's': (180, 210, 250, 255),    # light energy
    'D': (40, 30, 50, 255),       # dark shadow
}

def sigma_idle(draw, cx, cy, frame=0):
    bob = [0, 0, -1, 0, 0, 1][frame % 6]
    y_off = cy - 34 + bob
    x_off = cx - 16

    # Bald head with scar
    head = [
        "    ......    ",
        "   .GGGGGG.   ",
        "  .GGGgGGGG.  ",
        "  .GG.EE.GG.  ",
        "  .GGGGGGGG.  ",
        "  .GGR..GGG.  ",
        "   .GGGGGG.   ",
        "    .GGGG.    ",
    ]
    draw_pixel_block(draw, x_off, y_off, head, SIGMA_PALETTE)

    # Shoulder cape/armor
    shoulders = [
        " .PPPPPPPPPP. ",
        ".PpPPPPPPPPpP.",
        ".PPPPPPPPPPP. ",
    ]
    draw_pixel_block(draw, x_off - 1, y_off + 8, shoulders, SIGMA_PALETTE)

    # Body
    body = [
        "  .PPBBBBPP.  ",
        "  .PPBbBBPP.  ",
        "  .PPBBBBPP.  ",
        "   .PPPPPP.   ",
        "   .PPppPP.   ",
        "   .PPPPPP.   ",
    ]
    draw_pixel_block(draw, x_off + 1, y_off + 11, body, SIGMA_PALETTE)

    # Arms
    draw_pixel_block(draw, x_off - 4, y_off + 11, [
        ".PP. ",
        ".Pp. ",
        ".PP. ",
        ".Ss. ",
        ".Ss. ",
        ".Ss. ",
        ".Ss. ",
        " .s. ",
        "  .. ",
    ], SIGMA_PALETTE)
    draw_pixel_block(draw, x_off + 17, y_off + 11, [
        " .PP.",
        " .pP.",
        " .PP.",
        "  .. ",
    ], SIGMA_PALETTE)

    # Legs
    legs = [
        "   .PP..PP.   ",
        "   .Pp..pP.   ",
        "   .BB..BB.   ",
        "   .BB..BB.   ",
        "   .GG..GG.   ",
        "    ..  ..    ",
    ]
    draw_pixel_block(draw, x_off + 1, y_off + 17, legs, SIGMA_PALETTE)


# ============================================================================
# SIGMA X7 FINAL - Giant monstrous form
# ============================================================================

SIGMA_FINAL_PALETTE = {
    '.': (20, 10, 30, 255),       # dark outline
    'P': (100, 40, 140, 255),     # purple
    'p': (150, 70, 180, 255),     # light purple
    'R': (200, 40, 40, 255),      # red
    'r': (240, 70, 50, 255),      # light red
    'B': (40, 40, 80, 255),       # dark blue
    'Y': (250, 230, 80, 255),     # yellow energy
    'W': (240, 235, 240, 255),    # white
    'G': (80, 80, 90, 255),       # gray
    'g': (130, 130, 140, 255),    # light gray
    'E': (250, 50, 50, 255),      # red eye
    'D': (50, 20, 60, 255),       # dark shadow
    'F': (200, 100, 240, 255),    # energy purple
}

def sigma_final_idle(draw, cx, cy, frame=0):
    bob = [0, -1, 0, 1][frame % 4]
    y_off = cy - 40 + bob
    x_off = cx - 24

    # Giant head with horns
    horns = [
        " .PP.              .PP. ",
        " .Pp.              .pP. ",
        "  .PP.            .PP.  ",
        "   .PP.          .PP.   ",
    ]
    draw_pixel_block(draw, x_off - 2, y_off, horns, SIGMA_FINAL_PALETTE)

    head = [
        "      .PPPPPPPPPP.      ",
        "     .PPpPPPPPPpPP.     ",
        "    .PPPP.EE.PPPP.      ",
        "    .PPPPPPPPPPPP.      ",
        "     .PPPRRRRPPP.       ",
        "      .PPPPPPPP.        ",
    ]
    draw_pixel_block(draw, x_off, y_off + 4, head, SIGMA_FINAL_PALETTE)

    # Massive body
    body = [
        "    .PPPPPPPPPPPP.    ",
        "   .PPPPBBBBPPPPp.   ",
        "  .PPPPBBBBBBPPPp.   ",
        "  .PPPPBBbBBBPPPP.   ",
        "  .PPPPBBBBBBPPPP.   ",
        "   .PPPPPPPPPPPP.    ",
        "   .PPPPPPPpPPPP.    ",
        "    .PPPPPPPPPP.     ",
    ]
    draw_pixel_block(draw, x_off + 2, y_off + 10, body, SIGMA_FINAL_PALETTE)

    # Giant arms
    draw_pixel_block(draw, x_off - 8, y_off + 12, [
        "  .PPP. ",
        " .PPpP. ",
        ".PPPPP. ",
        ".PPPpP. ",
        ".PPPPP. ",
        " .PPP.  ",
        "  .GG.  ",
        "  .GG.  ",
        "   ..   ",
    ], SIGMA_FINAL_PALETTE)
    draw_pixel_block(draw, x_off + 28, y_off + 12, [
        " .PPP.  ",
        " .PpPP. ",
        " .PPPPP.",
        " .PpPPP.",
        " .PPPPP.",
        "  .PPP. ",
        "  .GG.  ",
        "  .GG.  ",
        "   ..   ",
    ], SIGMA_FINAL_PALETTE)

    # Legs
    legs = [
        "    .PPP..PPP.    ",
        "    .PPP..PPP.    ",
        "    .PPP..PPP.    ",
        "    .BBB..BBB.    ",
        "    .GGG..GGG.    ",
        "     ...  ...     ",
    ]
    draw_pixel_block(draw, x_off + 5, y_off + 18, legs, SIGMA_FINAL_PALETTE)


# ============================================================================
# MAIN SPRITE SHEET GENERATION
# ============================================================================

def create_boss_spritesheet(source_png_path, draw_func, palette, boss_name, variation_funcs=None):
    """Create a new sprite sheet replacing source with X7 boss art.

    source_png_path: path to the X8 PNG sprite sheet
    draw_func: function(draw, cx, cy, frame) to draw the boss
    palette: the color palette dict
    boss_name: name for logging
    variation_funcs: optional dict of {func_name: func} for different poses
    """
    if not os.path.exists(source_png_path):
        print(f"  ERROR: Source not found: {source_png_path}")
        return False

    img = Image.open(source_png_path)
    w, h = img.size
    bg_type = detect_background_color(img)
    print(f"  Source: {w}x{h}, background: {bg_type}")

    # Detect frame positions
    frames = detect_frames(img, bg_type)
    print(f"  Detected {len(frames)} frames")

    if not frames:
        print(f"  WARNING: No frames detected, skipping")
        return False

    # Backup original
    backup_path = os.path.join(BACKUP_DIR, boss_name + "_original.png")
    if not os.path.exists(backup_path):
        shutil.copy2(source_png_path, backup_path)
        print(f"  Backed up to: {backup_path}")

    # Create new image with same dimensions
    if bg_type == "black":
        new_img = Image.new("RGBA", (w, h), (0, 0, 0, 255))
    else:
        new_img = Image.new("RGBA", (w, h), (0, 0, 0, 0))

    draw = ImageDraw.Draw(new_img)

    # Draw X7 boss character in each frame position
    if variation_funcs is None:
        variation_funcs = [draw_func]
    else:
        variation_funcs = list(variation_funcs)

    for i, (fx, fy, fw, fh) in enumerate(frames):
        # Center of this frame
        cx = fx + fw // 2
        cy = fy + fh // 2

        # Choose which drawing function to use based on position
        # Use different poses for different rows
        func_idx = i % len(variation_funcs)
        variation_funcs[func_idx](draw, cx, cy, frame=i)

    # Save
    new_img.save(source_png_path)
    print(f"  Saved {len(frames)} frames to: {source_png_path}")
    return True


# ============================================================================
# BOSS DEFINITIONS AND MAPPING
# ============================================================================

BOSS_CONFIGS = [
    {
        "name": "SoldierStonekong",
        "source": "EarthrockTrilobyte/trilobyte.png",
        "draw_func": stonekong_idle,
        "variations": [stonekong_idle, stonekong_attack, stonekong_jump],
    },
    {
        "name": "TornadoTonion",
        "source": "GravityAntonion/antonion.png",
        "draw_func": tonion_idle,
        "variations": [tonion_idle, tonion_spin],
    },
    {
        "name": "SplashWarfly",
        "source": "GigaboltManowar/manowar.png",
        "draw_func": warfly_idle,
        "variations": [warfly_idle],
    },
    {
        "name": "FlameHyenard",
        "source": "BurnRooster/rooster.png",
        "draw_func": hyenard_idle,
        "variations": [hyenard_idle],
    },
    {
        "name": "RideBoarski",
        "source": "DevilBear/devilbear.png",
        "draw_func": boarski_idle,
        "variations": [boarski_idle],
    },
    {
        "name": "SnipeAnteator",
        "source": "DarkMantis/mantis.png",
        "draw_func": anteator_idle,
        "variations": [anteator_idle],
    },
    {
        "name": "WindCrowrang",
        "source": "DarkMantis/mantis.png",  # Both Crowrang and Anteator use mantis
        "draw_func": crowrang_idle,
        "variations": [crowrang_idle],
        "skip_if_already_done": True,  # Don't overwrite if Anteator already wrote
    },
    {
        "name": "VanishingGungaroo",
        "source": "BambooPandamonium/panda.png",
        "draw_func": gungaroo_idle,
        "variations": [gungaroo_idle],
    },
    {
        "name": "Red",
        "source": "CopySigma/copysigma.png",
        "draw_func": red_idle,
        "variations": [red_idle],
    },
    {
        "name": "SigmaX7",
        "source": "SatanSigma/satan_sigma.png",
        "draw_func": sigma_idle,
        "variations": [sigma_idle],
    },
]


def generate_single_boss(boss_config):
    """Generate sprite sheet for a single boss."""
    name = boss_config["name"]
    source_rel = boss_config["source"]
    source_path = os.path.join(BOSSES_DIR, source_rel)

    print(f"\n{'='*60}")
    print(f"Generating: {name}")
    print(f"  Source sprite sheet: {source_rel}")

    # Handle shared sprite sheets (Crowrang + Anteator both use mantis)
    if boss_config.get("skip_if_already_done"):
        backup = os.path.join(BACKUP_DIR, name + "_original.png")
        if os.path.exists(backup):
            print(f"  SKIPPING: {name} - shared sprite already modified")
            print(f"  NOTE: {name} and SnipeAnteator share mantis.png")
            print(f"         Both will use SnipeAnteator's sprites for now")
            return True

    success = create_boss_spritesheet(
        source_path,
        boss_config["draw_func"],
        None,
        name,
        boss_config.get("variations"),
    )
    return success


def main():
    ensure_backup_dir()

    print("=" * 60)
    print("Mega Man X7 Boss Sprite Generator")
    print("=" * 60)

    # If specific boss name given, only do that one
    if len(sys.argv) > 1:
        target = sys.argv[1]
        for config in BOSS_CONFIGS:
            if config["name"].lower() == target.lower():
                generate_single_boss(config)
                return
        print(f"Unknown boss: {target}")
        print(f"Available: {', '.join(c['name'] for c in BOSS_CONFIGS)}")
        return

    # Generate all
    results = []
    for config in BOSS_CONFIGS:
        success = generate_single_boss(config)
        results.append((config["name"], success))

    print(f"\n{'='*60}")
    print("RESULTS:")
    for name, success in results:
        status = "OK" if success else "FAILED"
        print(f"  {name}: {status}")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()
