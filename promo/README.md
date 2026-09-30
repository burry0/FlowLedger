# FlowLedger promo

A 20-second promo video (1920×1080, 30 fps) made with [Remotion](https://www.remotion.dev). English and Turkish versions come from the same composition; the texts are in `src/copy.ts`.

```sh
npm install
npm run studio      # preview in the browser
npm run render:en   # out/FlowLedger-promo-en.mp4
npm run render:tr   # out/FlowLedger-promo-tr.mp4
```

Scene cuts sit on a 120 BPM grid (one beat = 15 frames, see `SCENES` in `src/Promo.tsx`).

The soundtrack (`public/audio/soundtrack.m4a`) is synthesised from code, with no samples, by `audio-src/make_soundtrack.py`; the sound effects follow the scene timings. To regenerate it:

```sh
pip install numpy scipy
python audio-src/make_soundtrack.py out/soundtrack.wav
ffmpeg -i out/soundtrack.wav -af loudnorm=I=-14:TP=-1.5 -c:a aac -b:a 192k public/audio/soundtrack.m4a
```

The UI in the video is redrawn in code with made-up data. Fonts: Inter, Instrument Serif and JetBrains Mono (SIL Open Font License), in `public/fonts`.
