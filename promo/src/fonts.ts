import { continueRender, delayRender, staticFile } from 'remotion';

const RANGES: Record<string, string> = {
  latin: 'U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD',
  'latin-ext': 'U+0100-02BA, U+02BD-02C5, U+02C7-02CC, U+02CE-02D7, U+02DD-02FF, U+0304, U+0308, U+0329, U+1D00-1DBF, U+1E00-1E9F, U+1EF2-1EFF, U+2020, U+20A0-20AB, U+20AD-20C0, U+2113, U+2C60-2C7F, U+A720-A7FF',
};

const FACES: [string, string, string, string][] = [
  ['Instrument Serif', '400', 'italic', 'InstrumentSerif-400-italic-latin-ext.woff2'],
  ['Instrument Serif', '400', 'italic', 'InstrumentSerif-400-italic-latin.woff2'],
  ['Inter', '400', 'normal', 'Inter-400-normal-latin-ext.woff2'],
  ['Inter', '400', 'normal', 'Inter-400-normal-latin.woff2'],
  ['Inter', '500', 'normal', 'Inter-500-normal-latin-ext.woff2'],
  ['Inter', '500', 'normal', 'Inter-500-normal-latin.woff2'],
  ['Inter', '600', 'normal', 'Inter-600-normal-latin-ext.woff2'],
  ['Inter', '600', 'normal', 'Inter-600-normal-latin.woff2'],
  ['Inter', '700', 'normal', 'Inter-700-normal-latin-ext.woff2'],
  ['Inter', '700', 'normal', 'Inter-700-normal-latin.woff2'],
  ['Inter', '800', 'normal', 'Inter-800-normal-latin-ext.woff2'],
  ['Inter', '800', 'normal', 'Inter-800-normal-latin.woff2'],
  ['JetBrains Mono', '400', 'normal', 'JetBrainsMono-400-normal-latin-ext.woff2'],
  ['JetBrains Mono', '400', 'normal', 'JetBrainsMono-400-normal-latin.woff2'],
  ['JetBrains Mono', '500', 'normal', 'JetBrainsMono-500-normal-latin-ext.woff2'],
  ['JetBrains Mono', '500', 'normal', 'JetBrainsMono-500-normal-latin.woff2'],
];

const handle = delayRender('Loading fonts');
Promise.all(
  FACES.map(([family, weight, style, file]) => {
    const face = new FontFace(family, `url(${staticFile(`fonts/${file}`)}) format('woff2')`, {
      weight,
      style,
      unicodeRange: RANGES[file.includes('latin-ext') ? 'latin-ext' : 'latin'],
    });
    document.fonts.add(face);
    return face.load();
  }),
).then(() => continueRender(handle));
