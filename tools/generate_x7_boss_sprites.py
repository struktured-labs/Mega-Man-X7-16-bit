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

# Global scale for pixel art (each pixel-art pixel becomes SCALE x SCALE real pixels)
SCALE = 2


def ensure_backup_dir():
    os.makedirs(BACKUP_DIR, exist_ok=True)


def detect_background_color(img):
    """Detect whether the sprite sheet uses transparent or black background."""
    w, h = img.size
    corners = [
        img.getpixel((0, 0)),
        img.getpixel((w-1, 0)),
        img.getpixel((0, h-1)),
        img.getpixel((w-1, h-1)),
    ]
    # Check for transparent background first (RGBA with alpha = 0)
    if img.mode == 'RGBA':
        transparent_count = sum(1 for c in corners if len(c) >= 4 and c[3] < 10)
        if transparent_count >= 3:
            return "transparent"
    # Then check for black background
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


def draw_pixel_block(draw, x, y, pixels, palette, scale=None):
    """Draw a block of pixels from a 2D array of palette indices.
    pixels is list of strings, each char maps to a palette color.
    ' ' = transparent.
    """
    if scale is None:
        scale = SCALE
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
    'g': (145, 140, 130, 255),    # light gray
    'B': (90, 60, 35, 255),       # brown armor
    'b': (135, 95, 60, 255),      # light brown
    'O': (200, 140, 50, 255),     # orange accent
    'o': (240, 180, 80, 255),     # light orange
    'W': (220, 220, 210, 255),    # white highlight
    'E': (200, 30, 30, 255),      # red eye
    'D': (60, 50, 45, 255),       # dark shadow
    'H': (170, 155, 140, 255),    # highlight
}

def stonekong_idle(draw, cx, cy, frame=0):
    """Draw Stonekong idle pose centered at (cx, cy)."""
    s = SCALE
    bob = [0, 0, -1, -1, 0, 0, 1, 1][frame % 8]

    # Total size at scale=2: ~36 chars wide x 30 tall = 72x60 pixels. Good.
    art = [
        "       .BBbB.        ",
        "      .BBoBBB.       ",
        "     .BBBBBBB.       ",
        "    .GGG.GG.GGG.     ",
        "    .GgG.EE.GgG.     ",
        "    .GGG....GGG.     ",
        "     .GGGGGGGG.      ",
        "      .GGggGG.       ",
        "   .BB.BBBBBB.BB.    ",
        "  .BbBBBBBBBBBBbB.   ",
        " .BBBBBGGGGBBBBB.    ",
        "  .BBBBGGGGBBBB.     ",
        " .GG.BBGGGGBB.GG.   ",
        ".GGgG.BBBBBBB.GgGG. ",
        ".GGGGG.BBBBBB.GGGGG.",
        " .GGGG.BBbbBB.GGGG. ",
        "  .GG. .BB.BB. .GG. ",
        "       .BB.BB.       ",
        "       .Bb.bB.       ",
        "       .GG.GG.       ",
        "      .GGG.GGG.      ",
        "      .GGG.GGG.      ",
        "       ...  ...      ",
    ]

    art_h = len(art)
    art_w = max(len(row) for row in art)
    x0 = cx - (art_w * s) // 2
    y0 = cy - (art_h * s) // 2 + bob * s

    draw_pixel_block(draw, x0, y0, art, STONEKONG_PALETTE)


def stonekong_attack(draw, cx, cy, frame=0):
    """Stonekong attack - arm raised, lunging forward."""
    s = SCALE

    art = [
        "          .GGG.      ",
        "         .GGgGG.     ",
        "         .GGGGG.     ",
        "          .BB.       ",
        "    .BBbB. .BB.      ",
        "   .BBoBBB..Bb.      ",
        "  .BBBBBBB.BBb.      ",
        "  .GGG.GG.GGG.      ",
        "  .GgG.EE.GgG.      ",
        "  .GGG....GGG.      ",
        "   .GGGGGGGG.       ",
        "    .GGggGG.        ",
        "  .OBBBBBBBO.       ",
        " .BBBBBBBBBBBB.     ",
        " .BbBBGGGGBBbB.     ",
        "  .BBBGGGGBBB.      ",
        ".GG..BBBBBBB.       ",
        ".GgGG.BBBBB.        ",
        " .GGG..BB.BB.       ",
        "  ...  .BB.BB.      ",
        "       .Bb.bB.      ",
        "       .GG.GG.      ",
        "      .GGG.GGG.     ",
        "       ...  ...     ",
    ]

    art_h = len(art)
    art_w = max(len(row) for row in art)
    x0 = cx - (art_w * s) // 2
    y0 = cy - (art_h * s) // 2

    draw_pixel_block(draw, x0, y0, art, STONEKONG_PALETTE)


def stonekong_jump(draw, cx, cy, frame=0):
    """Stonekong jumping/aerial."""
    s = SCALE

    art = [
        "      .BBbB.       ",
        "     .BBoBBB.      ",
        "    .BBBBBBB.      ",
        "   .GGG.GG.GGG.   ",
        "   .GgG.EE.GgG.   ",
        "    .GG....GG.    ",
        "    .GGGGGGGG.    ",
        "  .BBBBBBBBBB.    ",
        " .BbBBBBBBBBbB.   ",
        " .BBBBBGGBBBBB.   ",
        "  .BBBBGGBBBB.    ",
        " .GG.BBBBBB.GG.  ",
        ".GGgG.BBBB.GgGG. ",
        " .GGG. .GG. .GGG.",
        "  ...  .GG.  ... ",
        "       .BB.       ",
        "        ..        ",
    ]

    art_h = len(art)
    art_w = max(len(row) for row in art)
    x0 = cx - (art_w * s) // 2
    y0 = cy - (art_h * s) // 2

    draw_pixel_block(draw, x0, y0, art, STONEKONG_PALETTE)


# ============================================================================
# TORNADO TONION - Round onion body, small limbs
# ============================================================================

TONION_PALETTE = {
    '.': (15, 30, 15, 255),
    'G': (50, 140, 50, 255),
    'g': (90, 180, 70, 255),
    'Y': (220, 200, 80, 255),
    'y': (250, 235, 130, 255),
    'W': (240, 240, 230, 255),
    'E': (30, 30, 120, 255),
    'P': (180, 100, 180, 255),
    'D': (30, 70, 30, 255),
    'C': (230, 220, 190, 255),
}

def tonion_idle(draw, cx, cy, frame=0):
    s = SCALE
    bob = [0, -1, -1, 0, 1, 1, 0, 0][frame % 8]

    art = [
        "       .gg.         ",
        "      .gGGg.        ",
        "      .GDGg.        ",
        "       .GG.         ",
        "        ..          ",
        "      ......        ",
        "    ..GGGGGGg..     ",
        "   .GGGGGGGGGGg.   ",
        "  .GGGGGGGGGGGGg.  ",
        "  .GGGG.EE.GGGGg.  ",
        "  .GGGG....GGGGGg. ",
        "  .GGGGGCCGGGGGg.  ",
        "  .GgGGGGGGGGGGg.  ",
        "  .GgGGGGGGGGGg.   ",
        "   .gGGGGGGGGg.    ",
        "    ..YYYYYY..     ",
        "      .YYYY.       ",
        "  .Y.  .YY.  .Y.  ",
        "  .YY. .... .YY.  ",
        "   ..  .YY.  ..   ",
        "       .YY.        ",
        "        ..         ",
    ]

    art_h = len(art)
    art_w = max(len(row) for row in art)
    x0 = cx - (art_w * s) // 2
    y0 = cy - (art_h * s) // 2 + bob * s

    draw_pixel_block(draw, x0, y0, art, TONION_PALETTE)


def tonion_spin(draw, cx, cy, frame=0):
    s = SCALE

    art = [
        "      ......        ",
        "    ..gGGGGGg..     ",
        "   .gGGGGGGGGGG.   ",
        "  .gGGGGGGGGGGGG.  ",
        "  .GGGGGGGGGGGGG.   ",
        "  .gGGGGGGGGGGGg.  ",
        "  .gGGGGGGGGGGGg.  ",
        "  .gGGGGGGGGGGg.   ",
        "   ..GGGGGGGG.     ",
        "     ........      ",
    ]

    art_h = len(art)
    art_w = max(len(row) for row in art)
    x0 = cx - (art_w * s) // 2
    y0 = cy - (art_h * s) // 2

    draw_pixel_block(draw, x0, y0, art, TONION_PALETTE)

    # Motion lines
    lc = TONION_PALETTE['g']
    if frame % 2 == 0:
        draw.line([(cx - 20*s, cy - 2*s), (cx - 24*s, cy - 6*s)], fill=lc, width=s)
        draw.line([(cx + 20*s, cy + 2*s), (cx + 24*s, cy + 6*s)], fill=lc, width=s)
    else:
        draw.line([(cx - 20*s, cy + 2*s), (cx - 24*s, cy + 6*s)], fill=lc, width=s)
        draw.line([(cx + 20*s, cy - 2*s), (cx + 24*s, cy - 6*s)], fill=lc, width=s)


# ============================================================================
# SPLASH WARFLY - Dragonfly shape, blue/teal
# ============================================================================

WARFLY_PALETTE = {
    '.': (10, 20, 35, 255),
    'B': (30, 100, 140, 255),
    'b': (60, 150, 180, 255),
    'T': (40, 160, 150, 255),
    't': (80, 200, 190, 255),
    'W': (200, 230, 240, 255),
    'w': (160, 200, 220, 128),    # semi-transparent wing
    'E': (220, 50, 50, 255),
    'D': (15, 40, 60, 255),
    'S': (120, 180, 200, 255),
}

def warfly_idle(draw, cx, cy, frame=0):
    s = SCALE
    bob = [0, -1, -1, 0, 1, 1][frame % 6]

    # Wings on top
    art_wings = [
        "  .www.         .www.  ",
        " .wWWWw.       .wWWWw. ",
        ".wWWWWWw.     .wWWWWWw.",
        " .wWWWw.       .wWWWw. ",
        "  .www.         .www.  ",
    ]

    # Body
    art_body = [
        "        .....         ",
        "       .BBBBB.        ",
        "      .BBE..EBB.      ",
        "      .BBBBBBBBB.     ",
        "       .bBBBBBb.      ",
        "       .TTTTTTT.      ",
        "      .TTtTTTtTT.     ",
        "      .TTTTTTTTT.     ",
        "      .TTtTTtTTT.     ",
        "       .TTTTTTT.      ",
        "        .TTTTT.       ",
        "         .TTT.        ",
        "          .T.         ",
        "           .          ",
    ]

    art_w = max(max(len(r) for r in art_wings), max(len(r) for r in art_body))
    wing_h = len(art_wings)
    body_h = len(art_body)
    total_h = wing_h + body_h

    x0 = cx - (art_w * s) // 2
    y0 = cy - (total_h * s) // 2 + bob * s

    draw_pixel_block(draw, x0, y0, art_wings, WARFLY_PALETTE)
    draw_pixel_block(draw, x0, y0 + wing_h * s, art_body, WARFLY_PALETTE)

    # Thin insect legs
    lc = WARFLY_PALETTE['B']
    leg_y = y0 + (wing_h + 5) * s
    for offset in [-3, -1, 1]:
        draw.line([(cx - 4*s, leg_y + offset*s), (cx - 8*s, leg_y + (offset+3)*s)], fill=lc, width=1)
        draw.line([(cx + 4*s, leg_y + offset*s), (cx + 8*s, leg_y + (offset+3)*s)], fill=lc, width=1)


# ============================================================================
# FLAME HYENARD - Medium hyena, red/orange, pointed ears
# ============================================================================

HYENARD_PALETTE = {
    '.': (40, 15, 10, 255),
    'R': (180, 50, 30, 255),
    'r': (220, 80, 40, 255),
    'O': (230, 150, 40, 255),
    'o': (250, 190, 70, 255),
    'Y': (250, 220, 80, 255),
    'W': (250, 250, 200, 255),
    'E': (250, 250, 50, 255),
    'D': (80, 30, 20, 255),
    'G': (120, 110, 100, 255),
    'B': (40, 35, 30, 255),
}

def hyenard_idle(draw, cx, cy, frame=0):
    s = SCALE
    bob = [0, -1, 0, 1][frame % 4]

    # Flame on head varies by frame
    if frame % 2 == 0:
        flame = [
            "        .Yo.       ",
            "       .YOY.       ",
            "        .Y.        ",
        ]
    else:
        flame = [
            "         .oY.      ",
            "        .YOY.      ",
            "         .Y.       ",
        ]

    body = [
        "     .R.     .R.    ",
        "    .RR.     .RR.   ",
        "    .Rr.     .rR.   ",
        "     .RRRRRRRR.     ",
        "    .RRR.EE.RRR.    ",
        "    .RRRRRRRRRR.    ",
        "    .RrOOOOOrRR.    ",
        "     .RRRRRRRR.     ",
        "     ..OWWWO..      ",
        "     .RRRRRRRR.     ",
        "    .RRrRRRRrRR.    ",
        "    .RRRGGGGRRR.    ",
        ".RR..RRRGGGGRR..RR. ",
        ".Rr..RRRRRRRR..rR.  ",
        ".GG. .RRRRRR. .GG.  ",
        " ..  .RRrrRR.  ..   ",
        "     .RR..RR.       ",
        "     .Rr..rR.       ",
        "     .GG..GG.       ",
        "     .GG..GG.       ",
        "      ..  ..        ",
    ]

    all_art = flame + body
    art_h = len(all_art)
    art_w = max(len(row) for row in all_art)
    x0 = cx - (art_w * s) // 2
    y0 = cy - (art_h * s) // 2 + bob * s

    draw_pixel_block(draw, x0, y0, all_art, HYENARD_PALETTE)


# ============================================================================
# RIDE BOARSKI - Stocky boar, dark red/brown, tusks, mohawk
# ============================================================================

BOARSKI_PALETTE = {
    '.': (30, 15, 15, 255),
    'R': (140, 50, 40, 255),
    'r': (180, 70, 55, 255),
    'B': (90, 55, 35, 255),
    'b': (130, 85, 55, 255),
    'W': (230, 225, 210, 255),
    'G': (100, 100, 100, 255),
    'g': (150, 150, 145, 255),
    'E': (200, 40, 40, 255),
    'D': (60, 30, 25, 255),
    'M': (110, 60, 100, 255),
    'm': (150, 80, 140, 255),
}

def boarski_idle(draw, cx, cy, frame=0):
    s = SCALE
    bob = [0, 0, -1, 0, 0, 1][frame % 6]

    art = [
        "        .mM.         ",
        "       .mMM.         ",
        "       .MMm.         ",
        "        .M.          ",
        "      .RRRRRR.       ",
        "     .RRR.EE.RR.     ",
        "     .RRRRRRRRR.     ",
        "     .RRbbRRbbRR.    ",
        "    .W.RRRRRRR..W.   ",
        "    .W..RRrRRR..W.   ",
        "     .  .RRRR.  .    ",
        "     .GGRRRRRGG.     ",
        "    .gGGRRRRRGGg.    ",
        "    .GGRRRRRRRGGG.   ",
        "    .GGRRRRRRRRGG.   ",
        " .RR..GRRRRRRRG..RR. ",
        " .Rr. .RRRRRR. .rR. ",
        " .GG.  .RRRR.  .GG. ",
        "  ..   .RR.RR.  ..  ",
        "       .RR.RR.       ",
        "       .BB.BB.       ",
        "       .GG.GG.       ",
        "        ..  ..       ",
    ]

    art_h = len(art)
    art_w = max(len(row) for row in art)
    x0 = cx - (art_w * s) // 2
    y0 = cy - (art_h * s) // 2 + bob * s

    draw_pixel_block(draw, x0, y0, art, BOARSKI_PALETTE)


# ============================================================================
# SNIPE ANTEATOR - Lanky, purple/dark, long snout, scope eye
# ============================================================================

ANTEATOR_PALETTE = {
    '.': (20, 10, 30, 255),
    'P': (80, 50, 100, 255),
    'p': (120, 80, 140, 255),
    'D': (50, 30, 60, 255),
    'G': (100, 100, 110, 255),
    'g': (150, 150, 155, 255),
    'R': (180, 40, 40, 255),
    'r': (220, 60, 60, 255),
    'W': (220, 215, 225, 255),
    'E': (160, 220, 50, 255),
    'B': (40, 30, 50, 255),
}

def anteator_idle(draw, cx, cy, frame=0):
    s = SCALE
    bob = [0, 0, -1, -1, 0, 0][frame % 6]

    art = [
        "        .rR.            ",
        "       .rRR.            ",
        "  ......PPPPPP.         ",
        " .PPPPP.PP.E.PP.        ",
        " .PPppPP.PPPPPP.        ",
        "  ......PPppPPPP.       ",
        "        .PPPPPP.        ",
        "       .PPPPPPPP.       ",
        "      .PPGGGGGGPP.      ",
        " .PP. .PPGGGGGGPP. .PP. ",
        " .Pp. .PPPPPPPPPP. .pP. ",
        " .PP.  .PPPPPPPP.  .PP. ",
        "  .G.  .PPppPPPP.  .G.  ",
        "   .    .PPPPPP.    .   ",
        "        .PP..PP.        ",
        "        .PP..PP.        ",
        "        .Pp..pP.        ",
        "        .PP..PP.        ",
        "        .PP..PP.        ",
        "        .GG..GG.        ",
        "         ..  ..         ",
    ]

    art_h = len(art)
    art_w = max(len(row) for row in art)
    x0 = cx - (art_w * s) // 2
    y0 = cy - (art_h * s) // 2 + bob * s

    draw_pixel_block(draw, x0, y0, art, ANTEATOR_PALETTE)


# ============================================================================
# WIND CROWRANG - Crow, black/purple, beak, wing-arms
# ============================================================================

CROWRANG_PALETTE = {
    '.': (10, 5, 15, 255),
    'K': (35, 25, 50, 255),
    'P': (70, 50, 90, 255),
    'p': (110, 80, 130, 255),
    'B': (40, 35, 45, 255),
    'W': (220, 215, 225, 255),
    'Y': (220, 180, 50, 255),
    'y': (250, 210, 80, 255),
    'E': (200, 50, 50, 255),
    'G': (80, 75, 90, 255),
    'F': (100, 80, 120, 255),
    'f': (140, 110, 160, 255),
}

def crowrang_idle(draw, cx, cy, frame=0):
    s = SCALE
    bob = [0, -1, -1, 0][frame % 4]

    art = [
        "        .KK.          ",
        "       .KPK.          ",
        "       .KPK.          ",
        "        .K.           ",
        "      .KKKKKK.        ",
        "     .KKKK.E.KK.      ",
        "     .KKKKKKKKKK.     ",
        "     .KKpKKKKpKK.     ",
        "    .YY.KKKKKKKK.     ",
        "    .Yy.KKKKKK.       ",
        "     ..  .....        ",
        "      .PPPPPPPP.      ",
        "     .PPpKKKPPPP.     ",
        " .fF..PPKKKKKKPP..Ff. ",
        ".fFFf.PPKKKKKKPP.fFFf.",
        ".FFFFF.PPKKKPPP.FFFFF.",
        " .fff. .PPPPPP. .fff. ",
        "  ...   .KKK.   ...  ",
        "       .KK..KK.       ",
        "       .PP..PP.       ",
        "       .GG..GG.       ",
        "      .YYY..YYY.      ",
        "       ..    ..       ",
    ]

    art_h = len(art)
    art_w = max(len(row) for row in art)
    x0 = cx - (art_w * s) // 2
    y0 = cy - (art_h * s) // 2 + bob * s

    draw_pixel_block(draw, x0, y0, art, CROWRANG_PALETTE)


def crowrang_fly(draw, cx, cy, frame=0):
    """Crowrang in flight pose with wings spread."""
    s = SCALE

    art = [
        "        .KK.          ",
        "       .KPK.          ",
        "      .KKKKKK.        ",
        "     .KKK.E.KK.       ",
        "     .KKKKKKKK.       ",
        "    .YY.KKKKKK.       ",
        "     .. .PPPP.        ",
        " .fFFf.PPKKPP.fFFf.   ",
        ".fFFFFF.PKKP.FFFFFf.  ",
        ".FFFFFFF.PP.FFFFFFFf. ",
        " .fFFFF. .. .FFFFf.   ",
        "  .fff.      .fff.    ",
        "   ...  .KK.  ...     ",
        "       .KK.KK.        ",
        "        ..  ..        ",
    ]

    art_h = len(art)
    art_w = max(len(row) for row in art)
    x0 = cx - (art_w * s) // 2
    y0 = cy - (art_h * s) // 2

    draw_pixel_block(draw, x0, y0, art, CROWRANG_PALETTE)


# ============================================================================
# VANISHING GUNGAROO - Tall kangaroo, tan/brown, boxing gloves
# ============================================================================

GUNGAROO_PALETTE = {
    '.': (30, 20, 15, 255),
    'T': (170, 140, 90, 255),
    't': (200, 175, 120, 255),
    'B': (120, 90, 55, 255),
    'b': (160, 125, 80, 255),
    'R': (180, 40, 40, 255),
    'r': (220, 70, 50, 255),
    'W': (240, 235, 220, 255),
    'E': (30, 30, 120, 255),
    'G': (100, 95, 90, 255),
    'D': (80, 60, 40, 255),
    'C': (220, 200, 160, 255),
}

def gungaroo_idle(draw, cx, cy, frame=0):
    s = SCALE
    bob = [0, -1, 0, 1][frame % 4]

    art = [
        "     .T.       .T.    ",
        "    .TT.       .TT.   ",
        "    .Tt.       .tT.   ",
        "    .TT.       .TT.   ",
        "     .TTTTTTTTTT.     ",
        "    .TTTt.EE.tTTT.    ",
        "    .TTTTTTTTTTTTT.   ",
        "    .TTtTTCCTTtTT.    ",
        "     .TTTCCCTTT.      ",
        "      .TTTTTTT.       ",
        "     .BBBBBBBBB.      ",
        "    .BBBWWWWWBBB.     ",
        " .RR.BBBWWWWWBBB.RR.  ",
        ".RRrR.BBbBBbBBB.RrRR. ",
        ".RRRR..BBBBBBB..RRRR. ",
        " .RR.  .BBbbBB.  .RR. ",
        "  ..   .BB..BB.   ..  ",
        "       .TT..TT.       ",
        "       .TT..TT.       ",
        "      .TTT..TTT.      ",
        "     .TTTT..TTTT.     ",
        "      ....  ....      ",
        "             .TT.     ",
        "            .TtT.     ",
        "           .TTT.      ",
        "          .TT.        ",
    ]

    art_h = len(art)
    art_w = max(len(row) for row in art)
    x0 = cx - (art_w * s) // 2
    y0 = cy - (art_h * s) // 2 + bob * s

    draw_pixel_block(draw, x0, y0, art, GUNGAROO_PALETTE)


# ============================================================================
# RED (Boss) - Humanoid swordsman, red armor, cape
# ============================================================================

RED_PALETTE = {
    '.': (30, 10, 10, 255),
    'R': (180, 30, 30, 255),
    'r': (220, 60, 50, 255),
    'D': (120, 20, 20, 255),
    'G': (100, 100, 110, 255),
    'g': (160, 160, 165, 255),
    'W': (240, 235, 230, 255),
    'Y': (230, 200, 60, 255),
    'B': (60, 55, 70, 255),
    'E': (250, 250, 100, 255),
    'S': (180, 190, 200, 255),
    's': (220, 225, 230, 255),
}

def red_idle(draw, cx, cy, frame=0):
    s = SCALE
    bob = [0, 0, -1, -1, 0, 0][frame % 6]

    art = [
        "       .RRRR.         ",
        "      .RRrrRR.        ",
        "      .RRrrRR.        ",
        "     .RRRRRRRR.       ",
        "     .RRRRRRRR.       ",
        "    .RRR.EE.RRR.      ",
        "    .RRRRRRRRRR.      ",
        "    .RRRggggRRR.      ",
        "     .RRRRRRRR.       ",
        "       .DDDDD..DD.   ",
        "    .YRRRRRRRRY.DDD.  ",
        "   .RRRRRRRRRRR.DDD.  ",
        "   .RRrRGGGGRrR.DDD.  ",
        "   .RRRRGGGGRRRR.DD.  ",
        ".Ss..RRRRRRRRRR..DD.  ",
        ".Ss. .RRRRrrRR. .D.   ",
        ".Ss.  .RR..RR.        ",
        " .s.  .Rr..rR.        ",
        "  ..  .RR..RR.        ",
        "      .GG..GG.        ",
        "      .GG..GG.        ",
        "       ..  ..         ",
    ]

    art_h = len(art)
    art_w = max(len(row) for row in art)
    x0 = cx - (art_w * s) // 2
    y0 = cy - (art_h * s) // 2 + bob * s

    draw_pixel_block(draw, x0, y0, art, RED_PALETTE)


# ============================================================================
# SIGMA X7 - Tall imposing figure, blue/purple, energy sword
# ============================================================================

SIGMA_PALETTE = {
    '.': (15, 10, 25, 255),
    'P': (80, 50, 120, 255),
    'p': (120, 80, 160, 255),
    'B': (40, 40, 80, 255),
    'b': (70, 70, 130, 255),
    'R': (180, 40, 40, 255),
    'W': (230, 225, 235, 255),
    'Y': (250, 230, 80, 255),
    'G': (100, 100, 110, 255),
    'g': (155, 155, 165, 255),
    'E': (200, 50, 50, 255),
    'S': (140, 180, 240, 255),
    's': (180, 210, 250, 255),
    'D': (40, 30, 50, 255),
}

def sigma_idle(draw, cx, cy, frame=0):
    s = SCALE
    bob = [0, 0, -1, 0, 0, 1][frame % 6]

    art = [
        "       ......         ",
        "      .GGGGGG.        ",
        "     .GGGgGGGG.       ",
        "     .GGGgGGGG.       ",
        "     .GG.EE.GG.       ",
        "     .GGGGGGGG.       ",
        "     .GGR..GGG.       ",
        "      .GGGGGG.        ",
        "       .GGGG.         ",
        "   .PPPPPPPPPPPP.     ",
        "  .PpPPPPPPPPPpPP.    ",
        "  .PPPPPPPPPPPPPP.    ",
        "   .PPBBBBBBPP.       ",
        "   .PPBBbBBBPP.       ",
        ".Ss..PPBBBBBBPP..PP.  ",
        ".Ss. .PPPPPPPP. .pP.  ",
        ".Ss.  .PPppPP.  .PP.  ",
        ".Ss.  .PPPPPP.   ..   ",
        " .s.  .PP..PP.        ",
        "  ..  .Pp..pP.        ",
        "      .BB..BB.        ",
        "      .BB..BB.        ",
        "      .GG..GG.        ",
        "       ..  ..         ",
    ]

    art_h = len(art)
    art_w = max(len(row) for row in art)
    x0 = cx - (art_w * s) // 2
    y0 = cy - (art_h * s) // 2 + bob * s

    draw_pixel_block(draw, x0, y0, art, SIGMA_PALETTE)


# ============================================================================
# SIGMA X7 FINAL - Giant monstrous form
# ============================================================================

SIGMA_FINAL_PALETTE = {
    '.': (20, 10, 30, 255),
    'P': (100, 40, 140, 255),
    'p': (150, 70, 180, 255),
    'R': (200, 40, 40, 255),
    'r': (240, 70, 50, 255),
    'B': (40, 40, 80, 255),
    'Y': (250, 230, 80, 255),
    'W': (240, 235, 240, 255),
    'G': (80, 80, 90, 255),
    'g': (130, 130, 140, 255),
    'E': (250, 50, 50, 255),
    'D': (50, 20, 60, 255),
    'F': (200, 100, 240, 255),
}

def sigma_final_idle(draw, cx, cy, frame=0):
    s = SCALE
    bob = [0, -1, 0, 1][frame % 4]

    art = [
        " .PP.                  .PP. ",
        " .Pp.                  .pP. ",
        "  .PP.                .PP.  ",
        "   .PP.              .PP.   ",
        "       .PPPPPPPPPP.         ",
        "      .PPpPPPPPPpPP.        ",
        "     .PPPP.EE.PPPPP.        ",
        "     .PPPPPPPPPPPPP.        ",
        "      .PPPRRRRRPPP.         ",
        "       .PPPPPPPPPP.         ",
        "     .PPPPPPPPPPPPPP.       ",
        "    .PPPPBBBBBBPPPPp.       ",
        "   .PPPPBBBBBBBBPPPp.       ",
        ".PPP.PPPBBbBBBBBPPPP..PPP.  ",
        ".PPpP.PPBBBBBBBBPP.PpPPP.   ",
        ".PPPPP.PPPPPPPPPP.PPPPP.    ",
        " .PPP. .PPPPpPPP. .PPP.    ",
        "  .GG.  .PPPPPP.  .GG.     ",
        "  .GG.  .PPP.PPP. .GG.     ",
        "   ..   .PPP.PPP.  ..      ",
        "        .PPP.PPP.           ",
        "        .BBB.BBB.           ",
        "        .GGG.GGG.           ",
        "         ...  ...           ",
    ]

    art_h = len(art)
    art_w = max(len(row) for row in art)
    x0 = cx - (art_w * s) // 2
    y0 = cy - (art_h * s) // 2 + bob * s

    draw_pixel_block(draw, x0, y0, art, SIGMA_FINAL_PALETTE)


# ============================================================================
# MAIN SPRITE SHEET GENERATION
# ============================================================================

def create_boss_spritesheet(source_png_path, boss_name, variation_funcs):
    """Create a new sprite sheet replacing source with X7 boss art."""
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

    draw_obj = ImageDraw.Draw(new_img)

    # Draw X7 boss character in each frame position
    for i, (fx, fy, fw, fh) in enumerate(frames):
        cx = fx + fw // 2
        cy = fy + fh // 2
        func_idx = i % len(variation_funcs)
        variation_funcs[func_idx](draw_obj, cx, cy, frame=i)

    # Save
    new_img.save(source_png_path)
    print(f"  Saved {len(frames)} frames to: {source_png_path}")
    return True


# ============================================================================
# BOSS DEFINITIONS
# ============================================================================

BOSS_CONFIGS = [
    {
        "name": "SoldierStonekong",
        "source": "EarthrockTrilobyte/trilobyte.png",
        "variations": [stonekong_idle, stonekong_attack, stonekong_jump],
    },
    {
        "name": "TornadoTonion",
        "source": "GravityAntonion/antonion.png",
        "variations": [tonion_idle, tonion_spin],
    },
    {
        "name": "SplashWarfly",
        "source": "GigaboltManowar/manowar.png",
        "variations": [warfly_idle],
    },
    {
        "name": "FlameHyenard",
        "source": "BurnRooster/rooster.png",
        "variations": [hyenard_idle],
    },
    {
        "name": "RideBoarski",
        "source": "DevilBear/devilbear.png",
        "variations": [boarski_idle],
    },
    {
        "name": "SnipeAnteator",
        "source": "DarkMantis/mantis.png",
        "variations": [anteator_idle],
        "note": "Uses mantis.png (SnipeAnteator sprites)",
    },
    {
        "name": "WindCrowrang",
        "source": "WindCrowrang/crowrang.png",
        "variations": [crowrang_idle, crowrang_fly],
        "create_new_spritesheet": True,
        "template_source": "DarkMantis/mantis.png",
        "note": "Uses new crowrang.png with separate .tres resource",
    },
    {
        "name": "VanishingGungaroo",
        "source": "BambooPandamonium/panda.png",
        "variations": [gungaroo_idle],
    },
    {
        "name": "Red",
        "source": "CopySigma/copysigma.png",
        "variations": [red_idle],
    },
    {
        "name": "SigmaX7",
        "source": "SatanSigma/satan_sigma.png",
        "variations": [sigma_idle],
    },
    {
        "name": "SigmaX7Final",
        "source": "Lumine/lumine_main.png",
        "variations": [sigma_final_idle],
    },
]


def create_crowrang_tres(png_path, tres_path):
    """Create a .tres SpriteFrames resource for WindCrowrang.

    Uses the same 288x144 grid as mantis.png but with a separate PNG
    and maps all 24 WindCrowrang animation names to frame sequences.
    """
    frame_w = 288
    frame_h = 144

    # Open the PNG to get dimensions
    img = Image.open(png_path)
    sheet_w, sheet_h = img.size
    cols = sheet_w // frame_w
    rows = sheet_h // frame_h
    total_frames = cols * rows

    print(f"  Creating .tres: {cols}x{rows} grid = {total_frames} frame slots")

    # WindCrowrang animation definitions
    # Map each animation name to a range of frame indices
    # We'll distribute frames across the grid, giving each animation
    # enough frames for reasonable animation
    anim_defs = [
        ("idle",                7,  True,  10.0),
        ("fly_idle",            4,  True,  8.0),
        ("land",                4,  False, 12.0),
        ("intro",               6,  False, 10.0),
        ("jump_prepare",        3,  False, 12.0),
        ("jump",                3,  True,  10.0),
        ("wall_cling",          2,  True,  8.0),
        ("wall_prepare",        2,  False, 10.0),
        ("walljump",            3,  False, 12.0),
        ("dive_prepare",        2,  False, 10.0),
        ("dive",                3,  True,  12.0),
        ("dive_land",           3,  False, 12.0),
        ("prepare_throw",       2,  False, 10.0),
        ("throw_prepare",       2,  False, 10.0),
        ("throw",               4,  False, 12.0),
        ("throw_catch",         3,  False, 10.0),
        ("dash_prepare",        3,  False, 10.0),
        ("dash",                3,  True,  12.0),
        ("slash",               4,  False, 14.0),
        ("flap_wings",          4,  True,  10.0),
        ("desperation_prepare", 4,  False, 10.0),
        ("desperation_roar",    4,  False, 8.0),
        ("exhausted",           4,  True,  6.0),
        ("death",               1,  False, 5.0),
    ]

    # Build sub_resource entries
    # Each frame in the grid gets an AtlasTexture sub_resource
    lines = []
    load_steps = total_frames + 1  # +1 for the ext_resource (the PNG texture)
    lines.append(f'[gd_resource type="SpriteFrames" load_steps={load_steps} format=2]')
    lines.append('')
    lines.append(f'[ext_resource path="res://src/Actors/Bosses/WindCrowrang/crowrang.png" type="Texture" id=1]')
    lines.append('')

    sub_id = 2
    frame_sub_ids = []  # Map grid index -> sub_resource id
    for row in range(rows):
        for col in range(cols):
            x = col * frame_w
            y = row * frame_h
            lines.append(f'[sub_resource type="AtlasTexture" id={sub_id}]')
            lines.append(f'atlas = ExtResource( 1 )')
            lines.append(f'region = Rect2( {x}, {y}, {frame_w}, {frame_h} )')
            lines.append('')
            frame_sub_ids.append(sub_id)
            sub_id += 1

    # Build animation definitions
    # Assign consecutive frame indices to each animation
    lines.append('[resource]')
    anim_parts = []
    frame_cursor = 0

    for anim_name, num_frames, loop, speed in anim_defs:
        # Clamp to available frames
        actual_frames = min(num_frames, total_frames - frame_cursor)
        if actual_frames <= 0:
            # Reuse frame 0 as fallback
            actual_frames = 1
            frame_refs = [f'SubResource( {frame_sub_ids[0]} )']
        else:
            frame_refs = []
            for i in range(actual_frames):
                idx = frame_cursor + i
                if idx < len(frame_sub_ids):
                    frame_refs.append(f'SubResource( {frame_sub_ids[idx]} )')
            frame_cursor += actual_frames

        loop_str = "true" if loop else "false"
        frames_str = ', '.join(frame_refs)
        anim_parts.append(
            '{\n'
            f'"frames": [ {frames_str} ],\n'
            f'"loop": {loop_str},\n'
            f'"name": "{anim_name}",\n'
            f'"speed": {speed}\n'
            '}'
        )

    lines.append('animations = [ ' + ', '.join(anim_parts) + ' ]')
    lines.append('')

    with open(tres_path, 'w') as f:
        f.write('\n'.join(lines))

    print(f"  Created .tres with {len(anim_defs)} animations at: {tres_path}")
    return True


def generate_single_boss(boss_config):
    """Generate sprite sheet for a single boss."""
    name = boss_config["name"]
    source_rel = boss_config["source"]
    source_path = os.path.join(BOSSES_DIR, source_rel)

    print(f"\n{'='*60}")
    print(f"Generating: {name}")
    print(f"  Source sprite sheet: {source_rel}")
    if "note" in boss_config:
        print(f"  Note: {boss_config['note']}")

    if boss_config.get("create_new_spritesheet"):
        # Create a new PNG from template dimensions + a .tres resource
        template_rel = boss_config["template_source"]
        template_path = os.path.join(BOSSES_DIR, template_rel)
        if not os.path.exists(template_path):
            print(f"  ERROR: Template not found: {template_path}")
            return False

        template_img = Image.open(template_path)
        tw, th = template_img.size
        bg_type = detect_background_color(template_img)

        # Ensure target directory exists
        target_dir = os.path.dirname(source_path)
        os.makedirs(target_dir, exist_ok=True)

        # Create new blank PNG with same dimensions
        if bg_type == "black":
            new_img = Image.new("RGBA", (tw, th), (0, 0, 0, 255))
        else:
            new_img = Image.new("RGBA", (tw, th), (0, 0, 0, 0))

        # Detect frames from template to know where to draw
        frames = detect_frames(template_img, bg_type)
        print(f"  Template: {tw}x{th}, {len(frames)} frames, background: {bg_type}")

        draw_obj = ImageDraw.Draw(new_img)
        variation_funcs = boss_config["variations"]
        for i, (fx, fy, fw, fh) in enumerate(frames):
            cx = fx + fw // 2
            cy = fy + fh // 2
            func_idx = i % len(variation_funcs)
            variation_funcs[func_idx](draw_obj, cx, cy, frame=i)

        new_img.save(source_path)
        print(f"  Saved {len(frames)} frames to: {source_path}")

        # Create .tres SpriteFrames resource
        tres_path = source_path.replace('.png', '.tres')
        create_crowrang_tres(source_path, tres_path)

        return True

    return create_boss_spritesheet(
        source_path,
        name,
        boss_config["variations"],
    )


def main():
    ensure_backup_dir()

    print("=" * 60)
    print("Mega Man X7 Boss Sprite Generator")
    print("=" * 60)

    if len(sys.argv) > 1:
        target = sys.argv[1]
        for config in BOSS_CONFIGS:
            if config["name"].lower() == target.lower():
                generate_single_boss(config)
                return
        print(f"Unknown boss: {target}")
        print(f"Available: {', '.join(c['name'] for c in BOSS_CONFIGS)}")
        return

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
