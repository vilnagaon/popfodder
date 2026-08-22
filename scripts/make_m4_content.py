#!/usr/bin/env python3
"""Generate M4 maps, names, SFX, and app icon. Original content only."""
import json, math, os, struct, wave, zlib

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
MAPS = os.path.join(ROOT, "PopFodder", "Resources", "Missions")
RES = os.path.join(ROOT, "PopFodder", "Resources")
SFX = os.path.join(RES, "SFX")
ICON = os.path.join(ROOT, "PopFodder", "Assets.xcassets", "AppIcon.appiconset")
os.makedirs(MAPS, exist_ok=True)
os.makedirs(SFX, exist_ok=True)
os.makedirs(ICON, exist_ok=True)

W, H = 24, 18
TS = 32
# origin -384, -288  squad south ~ y=-200

def squad():
    return [{"x": x, "y": -200} for x in (-42, -14, 14, 42)]

def border(fill):
    rows = []
    for r in range(H):
        if r in (0, H - 1):
            rows.append("W" * W)
        else:
            rows.append("W" + fill * (W - 2) + "W")
    return rows

def put(rows, r, c0, s):
    row = list(rows[r])
    for i, ch in enumerate(s):
        if 0 <= c0 + i < W:
            row[c0 + i] = ch
    rows[r] = "".join(row)

def wall_gap_h(rows, r, gap=2):
    mid = W // 2
    put(rows, r, 1, "W" * (mid - gap - 1) + "G" * (gap * 2) + "W" * (W - 2 - (mid - gap - 1) - gap * 2))

def dump(file_id, **kwargs):
    data = {
        "id": file_id,
        "tileSize": TS,
        "grenadeLoadout": 0,
        "rocketLoadout": 0,
        "squad": squad(),
        "enemies": [],
    }
    data.update(kwargs)
    path = os.path.join(MAPS, file_id + ".json")
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
    print("map", file_id)


def map_pit():
    rows = border("G")
    for r in (6, 7, 10, 11):
        put(rows, r, 8, "SSSS")
        put(rows, r, 14, "SSSS")
    wall_gap_h(rows, 8)
    dump(
        "the-pit",
        name="THE PIT",
        blurb="THE HOLES EAT THE SLOPPY.",
        objective="kill_all",
        biome="grass",
        aggression=6,
        tiles=rows,
        enemies=[
            {"x": -80, "y": 80, "patrol": [{"x": -80, "y": 80}, {"x": 80, "y": 80}]},
            {"x": 80, "y": 80, "patrol": [{"x": 80, "y": 80}, {"x": -80, "y": 80}]},
            {"x": 0, "y": 160},
            {"x": -40, "y": 40},
            {"x": 40, "y": 40},
            {"x": 0, "y": -40},
        ],
        grenades=[{"x": -180, "y": 0}],
    )


def map_farm1():
    rows = border("D")
    wall_gap_h(rows, 9)
    put(rows, 4, 9, "WWWWWW")
    dump(
        "farm-1",
        name="THE FARM",
        blurb="BURN THE SHACK FIRST.",
        objective="destroy_barracks",
        biome="dirt",
        aggression=6,
        tiles=rows,
        enemies=[
            {"x": -60, "y": 100, "patrol": [{"x": -60, "y": 100}, {"x": 60, "y": 100}]},
            {"x": 60, "y": 100},
            {"x": 0, "y": 40},
            {"x": -90, "y": 180},
        ],
        barracks={"x": 0, "y": 200},
        grenades=[{"x": 160, "y": -80}],
    )


def map_farm2():
    rows = border("G")
    wall_gap_h(rows, 7)
    wall_gap_h(rows, 12)
    dump(
        "farm-2",
        name="THE FARM",
        blurb="NOW GET THE PACKAGE HOME.",
        objective="extract_vip",
        biome="grass",
        aggression=6,
        tiles=rows,
        enemies=[
            {"x": -70, "y": 30, "patrol": [{"x": -70, "y": 30}, {"x": 70, "y": 30}]},
            {"x": 70, "y": 120, "patrol": [{"x": 70, "y": 120}, {"x": -70, "y": 120}]},
            {"x": 0, "y": 80},
        ],
        vip={"x": 50, "y": -170, "name": "PACKAGE"},
        extract={"x": 0, "y": 200},
        grenades=[{"x": -160, "y": -40}],
    )


def map_ridge():
    rows = border("G")
    put(rows, 5, 4, "WWWWWWGGWWWWWW")
    put(rows, 11, 4, "WWWWWWGGWWWWWW")
    dump(
        "the-ridge",
        name="THE RIDGE",
        blurb="TWO GAPS. ONE GUN.",
        objective="destroy_turret",
        biome="grass",
        aggression=7,
        tiles=rows,
        enemies=[
            {"x": -100, "y": 170},
            {"x": 100, "y": 170},
            {"x": -50, "y": 40, "patrol": [{"x": -50, "y": 40}, {"x": 50, "y": 40}]},
            {"x": 50, "y": 40},
            {"x": 0, "y": 90},
            {"x": -80, "y": -20},
        ],
        turret={"x": 0, "y": 200},
        grenades=[{"x": -200, "y": 80}],
        rockets=[{"x": 200, "y": 80}],
    )


def map_compound1():
    rows = border("D")
    wall_gap_h(rows, 10)
    dump(
        "compound-1",
        name="THE COMPOUND",
        blurb="TAKE THE JEEP. DON'T DIE IN IT.",
        objective="kill_all",
        biome="dirt",
        aggression=6,
        tiles=rows,
        enemies=[
            {"x": -80, "y": 60, "patrol": [{"x": -80, "y": 60}, {"x": 80, "y": 60}]},
            {"x": 80, "y": 60},
            {"x": 0, "y": 140},
            {"x": -40, "y": 20},
            {"x": 40, "y": 20},
        ],
        jeep={"x": 100, "y": -150},
        rockets=[{"x": 100, "y": -110}],
        grenades=[{"x": -180, "y": -60}],
    )


def map_compound2():
    rows = border("D")
    put(rows, 6, 6, "WWWWWWWWWWWW")
    put(rows, 6, 10, "GGGG")
    dump(
        "compound-2",
        name="THE COMPOUND",
        blurb="THE SHACK IS STILL OPEN.",
        objective="destroy_barracks",
        biome="dirt",
        aggression=7,
        tiles=rows,
        enemies=[
            {"x": -70, "y": 150},
            {"x": 70, "y": 150},
            {"x": 0, "y": 80, "patrol": [{"x": -90, "y": 80}, {"x": 90, "y": 80}]},
            {"x": 40, "y": 20},
        ],
        barracks={"x": 0, "y": 200},
        grenades=[{"x": -160, "y": 0}],
        rockets=[{"x": 160, "y": 0}],
    )


def map_icebox():
    rows = border("I")
    for r in (8, 9):
        put(rows, r, 6, "SSSS")
        put(rows, r, 14, "SSSS")
    wall_gap_h(rows, 5)
    dump(
        "the-icebox",
        name="THE ICEBOX",
        blurb="ICE SLOWS. THE GUN DOES NOT.",
        objective="destroy_turret",
        biome="snow",
        aggression=7,
        tiles=rows,
        enemies=[
            {"x": -80, "y": 160},
            {"x": 80, "y": 160},
            {"x": 0, "y": 40, "patrol": [{"x": -100, "y": 40}, {"x": 100, "y": 40}]},
            {"x": -40, "y": -20},
            {"x": 40, "y": -20},
        ],
        turret={"x": 0, "y": 200},
        grenades=[{"x": -190, "y": 90}],
    )


def map_run():
    rows = border("G")
    wall_gap_h(rows, 6)
    wall_gap_h(rows, 11)
    dump(
        "the-run",
        name="THE RUN",
        blurb="SAME GAP. MEANER GUN.",
        objective="destroy_turret",
        biome="grass",
        aggression=8,
        tiles=rows,
        enemies=[
            {"x": -90, "y": 170},
            {"x": -40, "y": 190},
            {"x": 40, "y": 190},
            {"x": 90, "y": 170},
            {"x": -70, "y": 50, "patrol": [{"x": -70, "y": 50}, {"x": 70, "y": 50}]},
            {"x": 70, "y": 50},
            {"x": 0, "y": 10},
            {"x": -30, "y": -40},
        ],
        turret={"x": 0, "y": 210},
        grenades=[{"x": -200, "y": 70}, {"x": 200, "y": 70}],
    )


def map_motor():
    rows = border("D")
    wall_gap_h(rows, 8)
    dump(
        "the-motor",
        name="THE MOTOR",
        blurb="JEEP, ROCKET, SHACK. IN THAT ORDER.",
        objective="destroy_barracks",
        biome="dirt",
        aggression=8,
        tiles=rows,
        enemies=[
            {"x": -90, "y": 90, "patrol": [{"x": -90, "y": 90}, {"x": 90, "y": 90}]},
            {"x": 90, "y": 90},
            {"x": 0, "y": 40},
            {"x": -50, "y": 170},
            {"x": 50, "y": 170},
            {"x": 20, "y": -20},
        ],
        barracks={"x": 0, "y": 210},
        jeep={"x": 90, "y": -160},
        rockets=[{"x": 90, "y": -120}],
        grenades=[{"x": -180, "y": -40}],
    )


def map_package1():
    rows = border("I")
    wall_gap_h(rows, 10)
    put(rows, 12, 9, "SSSSSS")
    dump(
        "package-1",
        name="THE PACKAGE",
        blurb="KEEP THEM OFF THE ICE HOLES.",
        objective="extract_vip",
        biome="snow",
        aggression=7,
        tiles=rows,
        enemies=[
            {"x": -80, "y": 30, "patrol": [{"x": -80, "y": 30}, {"x": 80, "y": 30}]},
            {"x": 80, "y": 30},
            {"x": 0, "y": 120},
            {"x": -40, "y": 160},
        ],
        vip={"x": 70, "y": -180, "name": "PACKAGE"},
        extract={"x": 0, "y": 200},
        grenadeLoadout=1,
    )


def map_package2():
    rows = border("I")
    wall_gap_h(rows, 6)
    wall_gap_h(rows, 12)
    dump(
        "package-2",
        name="THE PACKAGE",
        blurb="ONE MORE YARD OF SNOW.",
        objective="extract_vip",
        biome="snow",
        aggression=8,
        tiles=rows,
        enemies=[
            {"x": -90, "y": 20, "patrol": [{"x": -90, "y": 20}, {"x": 90, "y": 20}]},
            {"x": 90, "y": 140, "patrol": [{"x": 90, "y": 140}, {"x": -90, "y": 140}]},
            {"x": 0, "y": 80},
            {"x": -50, "y": 180},
            {"x": 50, "y": 180},
        ],
        vip={"x": 50, "y": -180, "name": "PACKAGE"},
        extract={"x": 0, "y": 210},
        grenades=[{"x": -170, "y": 0}],
    )


def map_hill1():
    rows = border("G")
    wall_gap_h(rows, 9)
    dump(
        "hill-1",
        name="THE HILL",
        blurb="FIRST THE GUN.",
        objective="destroy_turret",
        biome="grass",
        aggression=8,
        tiles=rows,
        enemies=[
            {"x": -90, "y": 170},
            {"x": 90, "y": 170},
            {"x": -40, "y": 40, "patrol": [{"x": -40, "y": 40}, {"x": 40, "y": 40}]},
            {"x": 40, "y": 40},
            {"x": 0, "y": 90},
            {"x": -60, "y": -10},
        ],
        turret={"x": 0, "y": 200},
        grenades=[{"x": -200, "y": 60}],
        rockets=[{"x": 200, "y": 60}],
    )


def map_hill2():
    rows = border("D")
    wall_gap_h(rows, 8)
    dump(
        "hill-2",
        name="THE HILL",
        blurb="THEN THE SHACK.",
        objective="destroy_barracks",
        biome="dirt",
        aggression=8,
        tiles=rows,
        enemies=[
            {"x": -80, "y": 100, "patrol": [{"x": -80, "y": 100}, {"x": 80, "y": 100}]},
            {"x": 80, "y": 100},
            {"x": 0, "y": 50},
            {"x": -50, "y": 180},
            {"x": 50, "y": 180},
        ],
        barracks={"x": 0, "y": 210},
        jeep={"x": 90, "y": -150},
        rockets=[{"x": 90, "y": -110}],
        grenades=[{"x": -170, "y": -30}],
    )


def map_hill3():
    rows = border("I")
    for r in (7, 8):
        put(rows, r, 8, "SSSSSS")
    wall_gap_h(rows, 11)
    dump(
        "hill-3",
        name="THE HILL",
        blurb="GET ONE BODY HOME. THAT'S THE WAR.",
        objective="extract_vip",
        biome="snow",
        aggression=9,
        tiles=rows,
        enemies=[
            {"x": -90, "y": 20, "patrol": [{"x": -90, "y": 20}, {"x": 90, "y": 20}]},
            {"x": 90, "y": 20},
            {"x": -40, "y": 140, "patrol": [{"x": -40, "y": 140}, {"x": 40, "y": 140}]},
            {"x": 40, "y": 140},
            {"x": 0, "y": 80},
            {"x": 20, "y": 180},
        ],
        vip={"x": 60, "y": -180, "name": "PACKAGE"},
        extract={"x": 0, "y": 210},
        grenadeLoadout=1,
    )


# --- names ---
STEMS = """BRAM KOEN ANJA PIET LIES TOON NELS FONS INES WIM SAAR DIRK KATO BART
NOOR STAF MIRA GUUS LEEN JEF ROOS BERT FLEUR KAS YASM HUGO TINE NILS ELKE
WARD SOFI LUC IDA STEN HANNE OTTO VEER JORN LUNA CAS TIM ARN GERT LOES
BRECHT SASK NIEN BREDA RUNE MEES DAAN LARS FEM KEES TESS JOOS IBO RIK
NELE WOUT SIEN RAF FLO JULE LOTTE SEM MATS OLIV LIESL TIBO RUNE2
KAREL STEF DAIS FRED MAXA LENA BORIS JANA PIETR TOON2
WIES GUUS2 NOLF SJOERD KARIN BO JANNE RENE SUZE
MECHT ILSE KOOS DAAN2 LARS2 FEMKE
JORIS STIEN MARK ROOS2 BERT2
HILDE CASP NIEK SANNE TOMAS
ELIN WOUT2 SIEN2 RAFA
FLORE JULIE LOT
SEBA MATS2 OLIVIER
TIBBE KAREL2 STEF2
MAX LENA2 BOR
JANE PIET2
TOON3 WIES2
NOLF2 SJOE
KARI BO2
JAN RENE2
SUZ MECH
ILS KOO
DAF LAR
FEM2 JOR
STI MAR
ROO BER
HIL CAS2
NIE SAN
TOM ELI
WOU SIE
RAF2 FLO2
JUL LOT2
SEB MAT
OLI TIB
KAR STE
MAX2 LEN
BOR2 JAN2""".split()


def write_names():
    seen = []
    for s in STEMS:
        s = s.replace("2", "").replace("3", "")
        if s and s not in seen and s not in {"JOOLS", "JOPS", "STOO"}:
            seen.append(s[:6].upper())
    # pad with original combos, still not CF names
    extras = [
        "ADEL", "BINN", "CORD", "DREW", "ESME", "FILP", "GITA", "HERM",
        "IVAR", "JOBE", "KIM", "LARS", "MAAN", "NICO", "ORSO", "PIP",
        "QUIN", "RAF", "SJO", "TEUN", "URSA", "VAL", "WES", "XAND",
        "YBEN", "ZAAN", "ALMA", "BOBE", "CIEL", "DIES", "EVERT", "FLOR",
        "GUS", "HANN", "IGOR", "JELT", "KEET", "LIV", "MACE", "NEEL",
        "ODES", "PAUW", "ROEL", "STEF", "THIJS", "UWE", "VEVA", "WILM",
        "YVON", "ZENO", "ARNO", "BIE", "CLEM", "DIED", "EDO", "FRITS",
        "GEERT", "HANS", "IVO", "JOEP", "KEES", "LUUK", "MART", "NIEK",
        "OENE", "PIEP", "RUBN", "SJAAK", "TON", "UUR", "VIKT", "WIM2",
        "YKE", "Zef", "AART", "BAS", "COR", "DICK", "ERN", "FRANS",
        "GER", "HENK", "ICK", "JAAP", "KLAAS", "LEO", "MARC", "NICO2",
        "Olaf".upper(), "PAUL", "ROB", "SIM", "TEUN2", "UDO", "VIC",
        "WIM3", "YAN", "ZAK", "ABE", "BEN", "CAS3", "DAN", "ELS",
        "FAAS", "GIL", "HARP", "IAN", "JOS", "KIP", "LEX", "MIE",
        "NAN", "OLK", "PIM", "RIK2", "SIP", "TOM2", "URS", "VIT",
        "WIM4", "YOR", "ZUS", "ADA", "BO", "CEES", "DOU", "EKE",
        "FEN", "GUS2", "HAL", "INE", "JIP", "KO", "LIS", "MOOS",
        "NES", "OKKE", "PIM2", "REM", "SUUS", "TES", "UNE", "VEER2",
        "WIL", "YKE2", "ZOE", "AMI", "BEP", "COR2", "DEA", "EVA",
        "FAY", "GIE", "HEA", "ISA", "JET", "KIM2", "LEA", "MIA",
        "NOA", "ORA", "PIT", "REA", "SOL", "TEA", "UNA", "VEA",
        "WIL2", "YSA", "ZIA",
    ]
    for e in extras:
        e = "".join(ch for ch in e.upper() if ch.isalpha())[:6]
        if e and e not in seen and e not in {"JOOLS", "JOPS", "STOO", "RJ"}:
            seen.append(e)
    seen = seen[:220]
    path = os.path.join(RES, "names.txt")
    with open(path, "w") as f:
        f.write("\n".join(seen) + "\n")
    print("names", len(seen))


def write_wav(path, samples, rate=22050):
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(rate)
        frames = b"".join(struct.pack("<h", max(-32767, min(32767, int(s)))) for s in samples)
        w.writeframes(frames)


def tone(freq, dur, rate=22050, vol=0.25, decay=True):
    n = int(rate * dur)
    out = []
    for i in range(n):
        t = i / rate
        env = (1 - i / n) if decay else 1
        # cheap square-ish
        s = 1.0 if math.sin(2 * math.pi * freq * t) >= 0 else -1.0
        out.append(s * vol * env * 32767)
    return out


def noise(dur, rate=22050, vol=0.2):
    n = int(rate * dur)
    x = 1234567
    out = []
    for i in range(n):
        x = (1103515245 * x + 12345) & 0x7FFFFFFF
        env = 1 - i / n
        out.append(((x / 0x7FFFFFFF) * 2 - 1) * vol * env * 32767)
    return out


def write_sfx():
    write_wav(os.path.join(SFX, "shot.wav"), tone(880, 0.05, vol=0.18) + tone(440, 0.04, vol=0.1))
    write_wav(os.path.join(SFX, "explode.wav"), noise(0.28, vol=0.35) + tone(90, 0.12, vol=0.2))
    write_wav(os.path.join(SFX, "death.wav"), tone(180, 0.12, vol=0.2) + tone(90, 0.18, vol=0.16))
    write_wav(os.path.join(SFX, "pickup.wav"), tone(660, 0.07, vol=0.2) + tone(990, 0.08, vol=0.18))
    write_wav(os.path.join(SFX, "win.wav"), tone(523, 0.12, vol=0.2, decay=False) + tone(659, 0.12, vol=0.2, decay=False) + tone(784, 0.2, vol=0.22))
    write_wav(os.path.join(SFX, "lose.wav"), tone(196, 0.25, vol=0.22) + tone(130, 0.35, vol=0.2))
    write_wav(os.path.join(SFX, "jeep.wav"), tone(140, 0.08, vol=0.12) + tone(160, 0.08, vol=0.1))
    print("sfx")


def png(path, pixels, w, h):
    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    raw = b""
    for y in range(h):
        raw += b"\x00"
        for x in range(w):
            r, g, b, a = pixels[y * w + x]
            raw += bytes((r, g, b, a))
    data = b"\x89PNG\r\n\x1a\n"
    data += chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
    data += chunk(b"IDAT", zlib.compress(raw, 9))
    data += chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(data)


def write_icon():
    size = 1024
    px = []
    for y in range(size):
        for x in range(size):
            # black field, yellow square, white P / yellow F block monogram without letters
            # two bars: white left, yellow right — original PF mark
            cx, cy = x - size / 2, y - size / 2
            r = size * 0.42
            if cx * cx + cy * cy > r * r:
                px.append((10, 10, 10, 255))
            elif x < size * 0.48:
                px.append((245, 240, 235, 255))
            else:
                px.append((255, 214, 0, 255))
            # notch so it isn't a plain split circle
            if abs(cy) < size * 0.06 and abs(cx) < size * 0.08:
                px[-1] = (10, 10, 10, 255)
    path = os.path.join(ICON, "icon-1024.png")
    png(path, px, size, size)
    # smaller via nearest subsample
    for dim, name in [(180, "icon-180.png"), (120, "icon-120.png"), (87, "icon-87.png"),
                      (80, "icon-80.png"), (60, "icon-60.png"), (58, "icon-58.png"),
                      (40, "icon-40.png")]:
        sp = []
        for y in range(dim):
            for x in range(dim):
                sx = int(x * size / dim)
                sy = int(y * size / dim)
                sp.append(px[sy * size + sx])
        png(os.path.join(ICON, name), sp, dim, dim)
    contents = {
        "images": [
            {"idiom": "iphone", "size": "20x20", "scale": "2x", "filename": "icon-40.png"},
            {"idiom": "iphone", "size": "20x20", "scale": "3x", "filename": "icon-60.png"},
            {"idiom": "iphone", "size": "29x29", "scale": "2x", "filename": "icon-58.png"},
            {"idiom": "iphone", "size": "29x29", "scale": "3x", "filename": "icon-87.png"},
            {"idiom": "iphone", "size": "40x40", "scale": "2x", "filename": "icon-80.png"},
            {"idiom": "iphone", "size": "40x40", "scale": "3x", "filename": "icon-120.png"},
            {"idiom": "iphone", "size": "60x60", "scale": "2x", "filename": "icon-120.png"},
            {"idiom": "iphone", "size": "60x60", "scale": "3x", "filename": "icon-180.png"},
            {"idiom": "ios-marketing", "size": "1024x1024", "scale": "1x", "filename": "icon-1024.png"},
        ],
        "info": {"version": 1, "author": "xcode"},
    }
    with open(os.path.join(ICON, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)
    print("icon")


if __name__ == "__main__":
    map_pit(); map_farm1(); map_farm2(); map_ridge()
    map_compound1(); map_compound2(); map_icebox()
    map_run(); map_motor(); map_package1(); map_package2()
    map_hill1(); map_hill2(); map_hill3()
    write_names(); write_sfx(); write_icon()
