"""Synthesises the promo soundtrack: a 20 s, 120 BPM track plus UI sound
effects placed on the scene timings of src/Promo.tsx.

Everything is generated here (no samples), so the audio carries no third-party
licence. Usage:

    pip install numpy scipy
    python audio-src/make_soundtrack.py out/soundtrack.wav
"""

import sys

import numpy as np
from scipy.io import wavfile
from scipy.signal import butter, sosfilt

SR = 44100
BPM = 120
BEAT = 60 / BPM  # 0.5 s, one beat = 15 video frames at 30 fps
LENGTH = 20.0
FPS = 30
rng = np.random.default_rng(7)

N = int(SR * LENGTH)
music = np.zeros((N, 2))
sfx = np.zeros((N, 2))


def t_of(frame):
    return frame / FPS


def env(n, attack, release):
    """Linear attack, exponential release."""
    e = np.ones(n)
    a = max(1, int(attack * SR))
    e[:a] = np.linspace(0, 1, a)
    e *= np.exp(-np.arange(n) / (release * SR))
    return e


def lowpass(x, hz, order=2):
    return sosfilt(butter(order, hz, 'low', fs=SR, output='sos'), x)


def highpass(x, hz, order=2):
    return sosfilt(butter(order, hz, 'high', fs=SR, output='sos'), x)


def bandpass(x, lo, hi, order=2):
    return sosfilt(butter(order, [lo, hi], 'band', fs=SR, output='sos'), x)


def add(buf, start, sig, gain=1.0, pan=0.0):
    i = int(start * SR)
    if i >= N:
        return
    sig = sig[: N - i]
    left = np.cos((pan + 1) * np.pi / 4)
    right = np.sin((pan + 1) * np.pi / 4)
    buf[i : i + len(sig), 0] += sig * gain * left * 1.414
    buf[i : i + len(sig), 1] += sig * gain * right * 1.414


def hz(midi):
    return 440.0 * 2 ** ((midi - 69) / 12)


# ---------- instruments ----------

def kick():
    n = int(0.45 * SR)
    t = np.arange(n) / SR
    f = 45 + 75 * np.exp(-t * 28)
    phase = 2 * np.pi * np.cumsum(f) / SR
    return np.sin(phase) * np.exp(-t * 9)


def hat(open_=False):
    n = int((0.18 if open_ else 0.05) * SR)
    x = highpass(rng.standard_normal(n), 7000)
    return x * np.exp(-np.arange(n) / ((0.06 if open_ else 0.012) * SR))


def pad(freqs, dur):
    n = int(dur * SR)
    t = np.arange(n) / SR
    x = np.zeros(n)
    for f in freqs:
        for detune in (-0.12, 0.0, 0.11):
            ff = f * 2 ** (detune / 12)
            # soft saw from a few harmonics
            for h in range(1, 6):
                x += np.sin(2 * np.pi * ff * h * t + rng.uniform(0, 6.28)) / (h * 1.4)
    x /= len(freqs) * 3 * 2.2
    a = int(0.6 * SR)
    e = np.ones(n)
    e[:a] = np.linspace(0, 1, a) ** 2
    e[-a:] *= np.linspace(1, 0, a) ** 2
    return lowpass(x * e, 1400)


def pluck(f, dur=0.45):
    n = int(dur * SR)
    t = np.arange(n) / SR
    x = np.sin(2 * np.pi * f * t) + 0.35 * np.sin(2 * np.pi * 2 * f * t) + 0.12 * np.sin(2 * np.pi * 3 * f * t)
    return lowpass(x * env(n, 0.003, 0.16), 3200)


def bass(f, dur):
    n = int(dur * SR)
    t = np.arange(n) / SR
    x = np.tanh(1.6 * np.sin(2 * np.pi * f * t)) * 0.8
    return lowpass(x * env(n, 0.01, dur * 0.8), 500)


def chime(f, dur=1.6):
    n = int(dur * SR)
    t = np.arange(n) / SR
    x = np.zeros(n)
    for ratio, amp, decay in ((1, 1, 0.9), (2.01, 0.45, 0.5), (3.98, 0.2, 0.3), (5.43, 0.1, 0.2)):
        x += amp * np.sin(2 * np.pi * f * ratio * t) * np.exp(-t / decay)
    x[: int(0.004 * SR)] *= np.linspace(0, 1, int(0.004 * SR))
    return x / 1.8


def tick(f=2600):
    n = int(0.025 * SR)
    t = np.arange(n) / SR
    return np.sin(2 * np.pi * f * t) * np.exp(-t * 260)


def whoosh(dur=0.45, up=True):
    n = int(dur * SR)
    x = rng.standard_normal(n)
    out = np.zeros(n)
    steps = 12
    for k in range(steps):
        s, e = k * n // steps, (k + 1) * n // steps
        c = 600 + (k / steps if up else 1 - k / steps) * 4000
        out[s:e] = bandpass(x, c * 0.7, c * 1.3)[s:e]
    shape = np.sin(np.linspace(0, np.pi, n)) ** 2
    return out * shape


def impact():
    n = int(1.2 * SR)
    t = np.arange(n) / SR
    boom = np.sin(2 * np.pi * (38 + 40 * np.exp(-t * 10)) * t) * np.exp(-t * 3.2)
    air = lowpass(rng.standard_normal(n), 900) * np.exp(-t * 6) * 0.4
    return boom + air


def riser(dur):
    n = int(dur * SR)
    x = rng.standard_normal(n)
    out = np.zeros(n)
    steps = 20
    for k in range(steps):
        s, e = k * n // steps, (k + 1) * n // steps
        c = 300 + (k / steps) ** 2 * 6000
        out[s:e] = bandpass(x, c * 0.6, c * 1.4)[s:e]
    return out * np.linspace(0, 1, n) ** 2


# ---------- arrangement ----------

# A minor, calm: Am9 – Fmaj7 – Cmaj7 – G6, two beats... one chord per bar (2 s).
CHORDS = [
    (57, [57, 60, 64, 67, 71]),  # Am9
    (53, [53, 57, 60, 64]),  # Fmaj7
    (48, [52, 55, 59, 60]),  # Cmaj7
    (55, [55, 59, 62, 64]),  # G6
]
BAR = 4 * BEAT

# Scene starts (seconds), matching SCENES in src/Promo.tsx.
LOGO, WORK, REV, PAY, PROOF, CTA = (t_of(f) for f in (75, 120, 240, 360, 450, 525))

# Pads through the whole piece; darker (filtered) during the chaos intro.
for bar in range(10):
    start = bar * BAR
    root, notes = CHORDS[bar % 4]
    p = pad([hz(m) for m in notes], BAR + 0.6)
    if start < LOGO:
        p = lowpass(p, 700) * 1.6
    gain = 0.20 if start >= CTA - 0.1 else 0.17
    add(music, start, p, gain)

# Intro: ticking closed hats that speed up, and a riser into the logo.
for i in range(10):
    add(music, i * BEAT / 2, hat(), 0.08 + i * 0.01, pan=0.3 if i % 2 else -0.3)
add(music, LOGO - 1.6, riser(1.6), 0.10)

# Logo hit.
add(music, LOGO, impact(), 0.38)
add(music, LOGO, chime(hz(81), 2.2), 0.12, pan=0.1)

# Groove from the Work scene until the CTA.
t = WORK
beat = 0
while t < CTA - 0.01:
    add(music, t, kick(), 0.34)
    add(music, t + BEAT / 2, hat(open_=(beat % 4 == 3)), 0.09, pan=0.25)
    if beat % 2 == 1:
        add(music, t, hat(), 0.05, pan=-0.3)
    t += BEAT
    beat += 1

# Bass and plucked arpeggio on the groove.
for bar in range(2, 9):
    start = bar * BAR
    if start >= CTA:
        break
    root, notes = CHORDS[bar % 4]
    for b in range(4):
        tt = start + b * BEAT
        if WORK <= tt < CTA:
            add(music, tt, bass(hz(root - 12), BEAT * 0.9), 0.18)
    arp = notes + [notes[1] + 12]
    for k in range(8):
        tt = start + k * BEAT / 2
        if WORK <= tt < CTA:
            add(music, tt, pluck(hz(arp[k % len(arp)] + 12)), 0.13 if tt < PROOF else 0.16,
                pan=-0.35 if k % 2 else 0.35)

# CTA: groove stops, one last soft chord and a chime.
add(music, CTA, impact() * 0.5, 0.35)
add(music, CTA, pad([hz(m) for m in (57, 60, 64, 67, 71, 76)], LENGTH - CTA + 0.2), 0.12)

# Sidechain: duck everything but the kick slightly on each beat of the groove.
duck = np.ones(N)
t = WORK
while t < CTA:
    i = int(t * SR)
    n = int(0.3 * SR)
    curve = 1 - 0.25 * np.exp(-np.arange(n) / (0.08 * SR))
    duck[i : i + n] = np.minimum(duck[i : i + n], curve[: len(duck[i : i + n])])
    t += BEAT
music *= duck[:, None]

# ---------- sound effects ----------

for cut in (LOGO, WORK, REV, PAY, PROOF, CTA):
    add(sfx, cut - 0.32, whoosh(0.45), 0.06)

# Work: counters (frames 18–58 of the scene) and rows appearing.
for k in range(14):
    add(sfx, WORK + t_of(18) + k * (t_of(40) / 14), tick(2400 + k * 40), 0.035, pan=0.4)
for i in range(4):
    add(sfx, WORK + t_of(30 + i * 7), tick(1800), 0.05, pan=0.3)

# Revisions: versions, status changes, approval, feedback tags.
for i in range(3):
    add(sfx, REV + t_of(12 + i * 8), tick(1600), 0.05)
add(sfx, REV + t_of(42), tick(2200), 0.07)
add(sfx, REV + t_of(58), chime(hz(88), 1.2), 0.10, pan=-0.2)
add(sfx, REV + t_of(64), tick(2000), 0.05, pan=0.4)
add(sfx, REV + t_of(78), tick(1500), 0.06, pan=0.4)

# Payments: chips, count-down, period closed.
for i in range(2):
    add(sfx, PAY + t_of(8 + i * 12), tick(1900), 0.06)
for k in range(16):
    add(sfx, PAY + t_of(16) + k * (t_of(34) / 16), tick(3000 - k * 60), 0.03, pan=-0.3)
add(sfx, PAY + t_of(54), chime(hz(84), 1.6), 0.13)
add(sfx, PAY + t_of(54) + 0.09, chime(hz(91), 1.4), 0.08)

# Proof cards landing.
for i in range(4):
    add(sfx, PROOF + t_of(10 + i * 4), tick(1400 + i * 150), 0.05, pan=-0.45 + i * 0.3)

# CTA button.
add(sfx, CTA + t_of(14), tick(2100), 0.06)
add(sfx, CTA + t_of(36), chime(hz(93), 1.8), 0.08)

# ---------- mix ----------

mix = music + sfx
fade = int(1.2 * SR)
mix[-fade:] *= np.linspace(1, 0, fade)[:, None] ** 1.5
mix[: int(0.05 * SR)] *= np.linspace(0, 1, int(0.05 * SR))[:, None]
mix = np.tanh(mix * 1.1) / np.tanh(1.1)  # gentle limiter
mix *= 0.89 / np.max(np.abs(mix))  # about -1 dBFS peak

out = sys.argv[1] if len(sys.argv) > 1 else 'soundtrack.wav'
wavfile.write(out, SR, (mix * 32767).astype(np.int16))
print(f'wrote {out}: {LENGTH:.1f} s, peak -1 dBFS')
