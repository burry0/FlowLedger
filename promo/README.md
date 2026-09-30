# FlowLedger promo

A 20-second promo video (1920×1080, 30 fps) made with [Remotion](https://www.remotion.dev). English and Turkish versions come from the same composition; the texts are in `src/copy.ts`.

```sh
npm install
npm run studio      # preview in the browser
npm run render:en   # out/FlowLedger-promo-en.mp4
npm run render:tr   # out/FlowLedger-promo-tr.mp4
```

Scene cuts sit on a 120 BPM grid (one beat = 15 frames, see `SCENES` in `src/Promo.tsx`).

The soundtrack (`public/audio/soundtrack.m4a`) is a 20 s, 120 BPM music track generated with the [ElevenLabs](https://elevenlabs.io) Music API, plus ElevenLabs sound effects (whoosh, click, confirmation chime, logo hit) that `audio-src/make_soundtrack.py` places on the scene timings. The generated sources are in `audio-src/elevenlabs/`; the prompts and the music's section plan are in the script. To rebuild it:

```sh
pip install numpy scipy
python audio-src/make_soundtrack.py out/soundtrack.wav             # mix the files in audio-src/elevenlabs/
python audio-src/make_soundtrack.py --generate out/soundtrack.wav  # fetch new ones first (needs ELEVENLABS_API_KEY)
ffmpeg -i out/soundtrack.wav -af loudnorm=I=-14:TP=-1.5 -c:a aac -b:a 192k public/audio/soundtrack.m4a
```

Use of the generated audio falls under the ElevenLabs terms of the account that generated it.

The UI in the video is redrawn in code with made-up data. Fonts: Inter, Instrument Serif and JetBrains Mono (SIL Open Font License), in `public/fonts`.
