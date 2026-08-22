#!/usr/bin/env python3
"""Original 8-bit combat SFX for PopFodder. Not from Cannon Fodder / OpenFodder."""
import math
import os
import random
import struct
import wave

RATE = 22050
OUT = os.path.join(os.path.dirname(__file__), "..", "PopFodder", "Resources", "SFX")


def clamp(x, lo=-1.0, hi=1.0):
    return lo if x < lo else hi if x > hi else x


def noise(rng):
    return rng.uniform(-1.0, 1.0)


def square(phase, duty=0.5):
    return 1.0 if (phase % 1.0) < duty else -1.0


def saw(phase):
    return 2.0 * (phase % 1.0) - 1.0


def env(i, n, attack=0.02, decay=0.98):
    if i < 0 or n <= 0 or i >= n:
        return 0.0
    a = max(1, int(n * attack))
    if i < a:
        return i / a
    t = min(1.0, (i - a) / max(1, n - a))
    return (1.0 - t) ** (1.0 / max(0.05, decay))


def render(seconds, fn):
    n = int(RATE * seconds)
    return [clamp(fn(i, n)) for i in range(n)]


def mix(*parts):
    n = max(len(p) for p in parts)
    out = [0.0] * n
    for p in parts:
        for i, v in enumerate(p):
            out[i] += v
    peak = max(1e-6, max(abs(x) for x in out))
    g = 0.88 / peak
    return [clamp(x * g) for x in out]


def write_wav(name, samples):
    path = os.path.join(OUT, name + ".wav")
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(clamp(s) * 32767)) for s in samples))
    print(name, f"{len(samples)/RATE:.3f}s")


def shot():
    rng = random.Random(7)
    def fn(i, n):
        t = i / RATE
        freq = 920 * (1.0 - 0.55 * (i / n))
        ph = freq * t
        click = square(ph, 0.18) * env(i, n, 0.01, 0.35)
        grit = noise(rng) * env(i, n, 0.0, 0.15) * 0.55
        return click * 0.7 + grit
    return render(0.09, fn)


def explode():
    rng = random.Random(11)
    def fn(i, n):
        t = i / RATE
        e = env(i, n, 0.01, 0.55)
        boom = square(55 * t * (1.0 - 0.7 * i / n), 0.4) * e * 0.45
        rumble = noise(rng) * e
        # crack at the front
        crack = noise(rng) * env(i, max(1, int(n * 0.12)), 0.0, 0.4) * 0.8
        return boom + rumble * 0.7 + crack * 0.5
    return render(0.42, fn)


def death():
    def fn(i, n):
        t = i / RATE
        freq = 340 * (0.22 ** (i / n))
        body = square(freq * t, 0.3) * env(i, n, 0.02, 0.7)
        over = saw(freq * 2.01 * t) * env(i, n, 0.0, 0.4) * 0.25
        return body * 0.85 + over
    return render(0.32, fn)


def jeep():
    rng = random.Random(3)
    def fn(i, n):
        t = i / RATE
        pulse = square(38 * t, 0.28)
        chug = square(76 * t + 0.1 * math.sin(22 * t), 0.45)
        grit = noise(rng) * 0.12
        e = env(i, n, 0.08, 0.85)
        return (pulse * 0.55 + chug * 0.35 + grit) * e
    return render(0.22, fn)


def pickup():
    def fn(i, n):
        t = i / RATE
        freq = 520 + 980 * (i / n)
        return square(freq * t, 0.25) * env(i, n, 0.02, 0.5)
    return render(0.12, fn)


def win():
    notes = [523.25, 659.25, 783.99, 1046.5]
    out = []
    for f in notes:
        def tone(i, n, freq=f):
            t = i / RATE
            return square(freq * t, 0.4) * env(i, n, 0.04, 0.65)
        out.append(render(0.11, tone))
    # concatenate with tiny overlap
    acc = []
    for part in out:
        if not acc:
            acc = part
        else:
            overlap = 200
            acc = acc[:-overlap] + [a + b * 0.4 for a, b in zip(acc[-overlap:], part[:overlap])] + part[overlap:]
    peak = max(1e-6, max(abs(x) for x in acc))
    return [clamp(x * 0.88 / peak) for x in acc]


def lose():
    def fn(i, n):
        t = i / RATE
        freq = 220 * (0.35 ** (i / n))
        return square(freq * t, 0.5) * env(i, n, 0.03, 0.8)
    return render(0.45, fn)


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    write_wav("shot", shot())
    write_wav("explode", explode())
    write_wav("death", death())
    write_wav("jeep", jeep())
    write_wav("pickup", pickup())
    write_wav("win", win())
    write_wav("lose", lose())
