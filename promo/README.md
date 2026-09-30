# FlowLedger promo

A 20-second promo video (1920×1080, 30 fps) made with [Remotion](https://www.remotion.dev). English and Turkish versions come from the same composition; the texts are in `src/copy.ts`.

```sh
npm install
npm run studio      # preview in the browser
npm run render:en   # out/FlowLedger-promo-en.mp4
npm run render:tr   # out/FlowLedger-promo-tr.mp4
```

Scene cuts sit on a 120 BPM grid (one beat = 15 frames, see `SCENES` in `src/Promo.tsx`), so music at that tempo lines up without re-timing.

The UI in the video is redrawn in code with made-up data. Fonts: Inter, Instrument Serif and JetBrains Mono (SIL Open Font License), in `public/fonts`.
