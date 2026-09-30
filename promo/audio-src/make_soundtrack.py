"""Builds the promo soundtrack: a 20 s, 120 BPM ElevenLabs music track plus
ElevenLabs sound effects placed on the scene timings of src/Promo.tsx.

The generated sources live in audio-src/elevenlabs/. `--generate` fetches them
again from the ElevenLabs API (needs ELEVENLABS_API_KEY); without it the script
only mixes the files already there. Usage:

    pip install numpy scipy
    python audio-src/make_soundtrack.py [--generate] out/soundtrack.wav

Decoding the MP3s needs ffmpeg; set FFMPEG to its path if it is not on PATH.
"""

import json
import os
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path

import numpy as np
from scipy.io import wavfile

SR = 44100
BPM = 120
BEAT = 60 / BPM  # 0.5 s, one beat = 15 video frames at 30 fps
LENGTH = 20.0
FPS = 30
SRC = Path(__file__).parent / 'elevenlabs'
FFMPEG = os.environ.get('FFMPEG', 'ffmpeg')

# ElevenLabs music sections must be at least 3 s long, so the track is
# generated 0.5 s longer at both ends and trimmed: the intro then ends on the
# logo (2.5 s) and the calm outro starts on the CTA (17.5 s).
PREROLL = 0.5
MUSIC_PLAN = {
    'positive_global_styles': ['calm minimal electronic', '120 bpm', 'A minor', 'soft warm synth pads',
                               'clean modern tech product promo', 'polished mix', 'instrumental'],
    'negative_global_styles': ['vocals', 'aggressive drums', 'dubstep', 'distortion', 'cinematic orchestra', 'busy'],
    'sections': [
        {'section_name': 'Soft intro', 'duration_ms': 3000, 'lines': [],
         'positive_local_styles': ['soft fade-in', 'filtered pads', 'sparse ticking hi-hats',
                                   'gentle riser building toward a hit'],
         'negative_local_styles': ['kick drum', 'bass']},
        {'section_name': 'Logo accent and groove', 'duration_ms': 15000, 'lines': [],
         'positive_local_styles': ['starts with a soft bright impact accent on the downbeat', 'warm sub bass',
                                   'light four-on-the-floor kick', 'plucked synth arpeggio', 'gentle sidechain',
                                   'steady calm momentum'],
         'negative_local_styles': ['drop', 'loud', 'vocals']},
        {'section_name': 'Calm outro', 'duration_ms': 3000, 'lines': [],
         'positive_local_styles': ['drums stop', 'sustained soft chord', 'airy resolution', 'gentle fade out'],
         'negative_local_styles': ['drums', 'new melody']},
    ],
}
SFX_PROMPTS = {
    'whoosh': ('Soft airy UI transition whoosh, short swoosh of air, clean, modern app interface, no music', 0.6),
    'click': ('Single soft subtle UI click, crisp minimal interface tap, very short, clean', 0.5),
    'chime': ('Gentle pleasant confirmation chime, soft two-note bell ding for success, modern app UI, clean', 1.5),
    'impact': ('Soft deep logo reveal hit with airy shimmer tail, modern tech brand sting, clean, not aggressive', 2.0),
}


def elevenlabs(path, body):
    req = urllib.request.Request(
        'https://api.elevenlabs.io' + path,
        data=json.dumps(body).encode(),
        headers={'xi-api-key': os.environ['ELEVENLABS_API_KEY'], 'Content-Type': 'application/json'},
    )
    with urllib.request.urlopen(req, timeout=300) as r:
        return r.read()


def generate():
    SRC.mkdir(exist_ok=True)
    for name, (text, dur) in SFX_PROMPTS.items():
        audio = elevenlabs('/v1/sound-generation',
                           {'text': text, 'duration_seconds': dur, 'prompt_influence': 0.6})
        (SRC / f'{name}.mp3').write_bytes(audio)
    audio = elevenlabs('/v1/music?output_format=mp3_44100_192',
                       {'composition_plan': MUSIC_PLAN, 'model_id': 'music_v1'})
    (SRC / 'music.mp3').write_bytes(audio)


def load(name):
    with tempfile.TemporaryDirectory() as tmp:
        wav = Path(tmp) / f'{name}.wav'
        subprocess.run([FFMPEG, '-v', 'error', '-i', str(SRC / f'{name}.mp3'), '-ar', str(SR), '-ac', '2', str(wav)],
                       check=True)
        return wavfile.read(wav)[1].astype(float) / 32768


def fades(x, fade_in=0.004, fade_out=0.03):
    x = x.copy()
    a, b = int(fade_in * SR), int(fade_out * SR)
    x[:a] *= np.linspace(0, 1, a)[:, None]
    x[-b:] *= np.linspace(1, 0, b)[:, None]
    return x


N = int(SR * LENGTH)
sfx = np.zeros((N, 2))


def add(start, sig, gain=1.0, pan=0.0):
    i = int(start * SR)
    if i >= N:
        return
    sig = sig[: N - i]
    left = np.cos((pan + 1) * np.pi / 4) * 1.414
    right = np.sin((pan + 1) * np.pi / 4) * 1.414
    sfx[i : i + len(sig), 0] += sig[:, 0] * gain * left
    sfx[i : i + len(sig), 1] += sig[:, 1] * gain * right


def t_of(frame):
    return frame / FPS


if '--generate' in sys.argv:
    generate()

# ---------- music ----------

music = load('music')[int(PREROLL * SR) :][:N]
music = np.pad(music, ((0, N - len(music)), (0, 0)))

# ---------- sound effects ----------

whoosh = fades(load('whoosh'))
click = fades(load('click')[: int(0.12 * SR)], 0.001, 0.04)
chime = fades(load('chime'), 0.002, 0.2)
impact = fades(load('impact'), 0.003, 0.3)

# Scene starts (seconds), matching SCENES in src/Promo.tsx.
LOGO, WORK, REV, PAY, PROOF, CTA = (t_of(f) for f in (75, 120, 240, 360, 450, 525))

# Logo accent.
add(LOGO, impact, 0.30)

for cut in (LOGO, WORK, REV, PAY, PROOF, CTA):
    add(cut - 0.3, whoosh, 0.10)

# Work: counters (frames 18–58 of the scene) and rows appearing.
for k in range(7):
    add(WORK + t_of(18) + k * (t_of(40) / 7), click, 0.10, pan=0.4)
for i in range(4):
    add(WORK + t_of(30 + i * 7), click, 0.18, pan=0.3)

# Revisions: versions, status changes, approval, feedback tags.
for i in range(3):
    add(REV + t_of(12 + i * 8), click, 0.18)
add(REV + t_of(42), click, 0.22)
add(REV + t_of(58), chime, 0.22, pan=-0.2)
add(REV + t_of(64), click, 0.16, pan=0.4)
add(REV + t_of(78), click, 0.18, pan=0.4)

# Payments: chips, count-down, period closed.
for i in range(2):
    add(PAY + t_of(8 + i * 12), click, 0.20)
for k in range(8):
    add(PAY + t_of(16) + k * (t_of(34) / 8), click, 0.09, pan=-0.3)
add(PAY + t_of(54), chime, 0.30)

# Proof cards landing.
for i in range(4):
    add(PROOF + t_of(10 + i * 4), click, 0.16, pan=-0.45 + i * 0.3)

# CTA button.
add(CTA + t_of(14), click, 0.22)
add(CTA + t_of(36), chime, 0.20)

# ---------- mix ----------

mix = music * 0.8 + sfx
fade = int(1.2 * SR)
mix[-fade:] *= np.linspace(1, 0, fade)[:, None] ** 1.5
mix[: int(0.05 * SR)] *= np.linspace(0, 1, int(0.05 * SR))[:, None]
mix = np.tanh(mix * 1.1) / np.tanh(1.1)  # gentle limiter
mix *= 0.89 / np.max(np.abs(mix))  # about -1 dBFS peak

out = sys.argv[-1] if len(sys.argv) > 1 and sys.argv[-1] != '--generate' else 'soundtrack.wav'
wavfile.write(out, SR, (mix * 32767).astype(np.int16))
print(f'wrote {out}: {LENGTH:.1f} s, peak -1 dBFS')
