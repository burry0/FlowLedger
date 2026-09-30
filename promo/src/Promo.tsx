import React from 'react';
import {
  AbsoluteFill,
  Audio,
  Easing,
  Sequence,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import { Copy, Locale, copy } from './copy';

// 120 BPM at 30 fps: one beat = 15 frames. Every scene starts on a beat.
export const BEAT = 15;
export const SCENES = {
  chaos: [0, 5 * BEAT],
  logo: [5 * BEAT, 3 * BEAT],
  work: [8 * BEAT, 8 * BEAT],
  revisions: [16 * BEAT, 8 * BEAT],
  payments: [24 * BEAT, 6 * BEAT],
  proof: [30 * BEAT, 5 * BEAT],
  cta: [35 * BEAT, 5 * BEAT],
} as const;
export const TOTAL = 40 * BEAT;

const C = {
  bg: '#0C0E13',
  surface: '#111419',
  high: '#1A1F28',
  ov: '#1F242E',
  ol: '#2A303C',
  text: '#E8ECF3',
  muted: '#8C95A6',
  accent: '#7FC8D8',
  accentC: '#16303A',
  sec: '#9AA8F0',
  secC: '#1E2338',
  ok: '#7FBF95',
  okC: '#1D3326',
  warn: '#E0A458',
  warnC: '#3A2A14',
};
const SANS = 'Inter, sans-serif';
const SERIF = '"Instrument Serif", serif';
const MONO = '"JetBrains Mono", monospace';
const EASE = Easing.bezier(0.22, 1, 0.36, 1);

const clamp = { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' } as const;
const ramp = (f: number, start: number, dur = 12) =>
  interpolate(f, [start, start + dur], [0, 1], { ...clamp, easing: EASE });
const pop = (f: number, start: number, fps: number) =>
  spring({ frame: f - start, fps, config: { damping: 14, stiffness: 160, mass: 0.7 } });

const money = (value: number, sep: string) =>
  '₺' + Math.round(value).toString().replace(/\B(?=(\d{3})+(?!\d))/g, sep);

// ---------- shared pieces ----------

const Accent: React.FC<{ children: React.ReactNode; size: number }> = ({ children, size }) => (
  <span style={{ fontFamily: SERIF, fontStyle: 'italic', fontWeight: 400, color: C.accent, fontSize: size }}>
    {children}
  </span>
);

const Bolt: React.FC<{ size: number; frame?: boolean }> = ({ size, frame = true }) => (
  <svg width={size} height={size} viewBox="0 0 512 512">
    {frame && <rect x="16" y="16" width="480" height="480" rx="112" fill={C.surface} stroke={C.ol} strokeWidth="8" />}
    <path
      d="M204 104 L412 104 L380 164 L274 164 L254 212 L344 212 L168 420 L218 270 L152 270 Z"
      fill={C.accent}
      stroke={C.accent}
      strokeWidth="10"
      strokeLinejoin="round"
    />
  </svg>
);

const Tag: React.FC<{ bg: string; fg: string; children: React.ReactNode; style?: React.CSSProperties }> = ({
  bg,
  fg,
  children,
  style,
}) => (
  <span style={{ padding: '5px 12px', borderRadius: 99, fontSize: 15, fontWeight: 700, background: bg, color: fg, whiteSpace: 'nowrap', ...style }}>
    {children}
  </span>
);

const Label: React.FC<{ children: React.ReactNode; style?: React.CSSProperties }> = ({ children, style }) => (
  <div style={{ fontSize: 15, color: C.muted, fontWeight: 600, textTransform: 'uppercase', letterSpacing: 1, ...style }}>
    {children}
  </div>
);

const cardStyle: React.CSSProperties = {
  position: 'absolute',
  background: C.surface,
  border: `1px solid ${C.ol}`,
  borderRadius: 20,
  padding: '28px 30px',
  boxShadow: '0 40px 90px rgba(0,0,0,.55)',
};

/** Blur + scale in and out at the scene edges. */
const Scene: React.FC<{ dur: number; children: React.ReactNode; exit?: boolean }> = ({ dur, children, exit = true }) => {
  const f = useCurrentFrame();
  const inP = ramp(f, 0, 9);
  const outP = exit ? interpolate(f, [dur - 7, dur], [0, 1], { ...clamp, easing: Easing.in(Easing.cubic) }) : 0;
  const opacity = inP * (1 - outP);
  const blur = (1 - inP) * 14 + outP * 14;
  const scale = 1.035 - 0.035 * inP - 0.03 * outP;
  return (
    <AbsoluteFill style={{ opacity, filter: `blur(${blur}px)`, transform: `scale(${scale})` }}>{children}</AbsoluteFill>
  );
};

const Headline: React.FC<{ f: number; title: string; accent: string; body: string }> = ({ f, title, accent, body }) => {
  const a = ramp(f, 4, 14);
  const b = ramp(f, 10, 16);
  const c = ramp(f, 20, 16);
  return (
    <div style={{ position: 'absolute', left: 72, top: 330, width: 580 }}>
      <div style={{ fontSize: 64, fontWeight: 700, letterSpacing: -2, lineHeight: 1.05 }}>
        <div style={{ opacity: a, transform: `translateY(${(1 - a) * 30}px)` }}>{title}</div>
        <div style={{ opacity: b, transform: `translateY(${(1 - b) * 30}px)` }}>
          <Accent size={80}>{accent}</Accent>
        </div>
      </div>
      <div style={{ color: C.muted, fontSize: 26, marginTop: 26, lineHeight: 1.45, opacity: c }}>{body}</div>
    </div>
  );
};

// ---------- background and top bar ----------

const Background: React.FC = () => {
  const f = useCurrentFrame();
  const x = 50 + Math.sin(f / 90) * 6;
  const y = 55 + Math.cos(f / 110) * 5;
  return (
    <AbsoluteFill style={{ background: C.bg }}>
      <AbsoluteFill style={{ background: `radial-gradient(1200px 700px at ${x}% ${y}%, rgba(127,200,216,.10), transparent 70%)` }} />
      <AbsoluteFill
        style={{
          backgroundImage:
            'linear-gradient(rgba(255,255,255,.025) 1px,transparent 1px),linear-gradient(90deg,rgba(255,255,255,.025) 1px,transparent 1px)',
          backgroundSize: '64px 64px',
          backgroundPosition: `0 ${(f * 0.3) % 64}px`,
          maskImage: 'radial-gradient(closest-side,#000 30%,transparent 100%)',
          WebkitMaskImage: 'radial-gradient(closest-side,#000 30%,transparent 100%)',
        }}
      />
    </AbsoluteFill>
  );
};

/** Persistent over Work → Revisions → Payments; the active step follows the scene. */
const TopBar: React.FC<{ t: Copy }> = ({ t }) => {
  const f = useCurrentFrame(); // local to the Work start
  const dur = SCENES.work[1] + SCENES.revisions[1] + SCENES.payments[1];
  const inP = ramp(f, 0, 12);
  const outP = interpolate(f, [dur - 7, dur], [0, 1], clamp);
  const active = f < SCENES.work[1] ? 0 : f < SCENES.work[1] + SCENES.revisions[1] ? 1 : 2;
  const hintIn = [0, SCENES.work[1], SCENES.work[1] + SCENES.revisions[1]][active];
  const hintP = ramp(f, hintIn + 4, 10);
  return (
    <div
      style={{
        position: 'absolute',
        left: 72,
        right: 72,
        top: 52,
        display: 'flex',
        alignItems: 'center',
        gap: 22,
        opacity: inP * (1 - outP),
        transform: `translateY(${(1 - inP) * -20}px)`,
      }}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: 14, fontWeight: 700, fontSize: 28 }}>
        <Bolt size={38} /> FlowLedger
      </div>
      <div style={{ display: 'flex', gap: 10, marginLeft: 28 }}>
        {t.steps.map((s, i) => {
          const on = i === active;
          const done = i < active;
          return (
            <div
              key={s}
              style={{
                padding: '9px 20px',
                borderRadius: 99,
                fontSize: 20,
                fontWeight: 600,
                border: `1px solid ${on ? C.accent : done ? '#23505e' : C.ol}`,
                background: on ? C.accent : done ? C.accentC : 'transparent',
                color: on ? C.bg : done ? C.accent : C.muted,
              }}
            >
              {s}
            </div>
          );
        })}
      </div>
      <div style={{ marginLeft: 'auto', fontFamily: MONO, fontSize: 18, color: C.muted, opacity: hintP }}>{t.hints[active]}</div>
    </div>
  );
};

// ---------- scenes ----------

const CHIP_POS: [number, number, number, number][] = [
  // left, top, rotation, opacity
  [300, 230, -6, 1],
  [1250, 190, 5, 1],
  [180, 640, 4, 1],
  [1380, 700, -4, 1],
  [760, 120, -2, 0.55],
  [1120, 880, 3, 0.5],
  [420, 860, -3, 0.6],
  [1480, 440, 8, 0.45],
];

const Chaos: React.FC<{ t: Copy }> = ({ t }) => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const dur = SCENES.chaos[1];
  // Chips collapse into the centre at the end, handing over to the logo.
  const implode = interpolate(f, [dur - 14, dur], [0, 1], { ...clamp, easing: Easing.in(Easing.cubic) });
  return (
    <AbsoluteFill>
      {t.chips.map((chip, i) => {
        const [x, y, r, o] = CHIP_POS[i];
        const p = pop(f, i * 3, fps);
        const fromX = x < 960 ? -260 : 260;
        const drift = Math.sin((f + i * 20) / 18) * 6;
        const cx = 960 - 150;
        const cy = 540 - 25;
        const left = interpolate(implode, [0, 1], [x + (1 - p) * fromX, cx]);
        const top = interpolate(implode, [0, 1], [y + drift, cy]);
        return (
          <div
            key={chip}
            style={{
              position: 'absolute',
              left,
              top,
              transform: `rotate(${r * (1 - implode)}deg) scale(${1 - implode * 0.8})`,
              opacity: o * Math.min(1, p) * (1 - implode),
              filter: `blur(${(1 - Math.min(1, p)) * 8 + implode * 6}px)`,
              padding: '14px 22px',
              borderRadius: 14,
              background: 'rgba(26,31,40,.85)',
              border: `1px solid ${C.ol}`,
              fontFamily: MONO,
              fontSize: 24,
              color: i < 4 ? C.text : C.muted,
              boxShadow: '0 20px 50px rgba(0,0,0,.45)',
              whiteSpace: 'nowrap',
            }}
          >
            {chip}
          </div>
        );
      })}
      <AbsoluteFill
        style={{
          alignItems: 'center',
          justifyContent: 'center',
          textAlign: 'center',
          opacity: 1 - implode,
          transform: `scale(${1 - implode * 0.06})`,
        }}
      >
        <div style={{ fontSize: 34, fontWeight: 500, color: C.muted, marginBottom: 14, opacity: ramp(f, 2, 10) }}>{t.chaosSub}</div>
        <div style={{ fontSize: 96, fontWeight: 700, letterSpacing: -3, display: 'flex', gap: 26, alignItems: 'baseline' }}>
          {t.chaosWords.map((w, i) => {
            const p = ramp(f, 8 + i * 4, 10);
            return (
              <span key={w} style={{ opacity: p, transform: `translateY(${(1 - p) * 24}px)`, display: 'inline-block' }}>
                {w}
              </span>
            );
          })}
          {(() => {
            const p = pop(f, 26, fps);
            return (
              <span style={{ display: 'inline-block', transform: `translateY(${(1 - p) * -60}px) rotate(${(1 - p) * -6}deg)`, opacity: Math.min(1, p) }}>
                <Accent size={112}>{t.chaosAccent}</Accent>
              </span>
            );
          })()}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

const Logo: React.FC<{ t: Copy }> = ({ t }) => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const icon = pop(f, 0, fps);
  const word = ramp(f, 6, 14);
  const tag = ramp(f, 16, 14);
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', textAlign: 'center' }}>
      <div
        style={{
          position: 'absolute',
          width: 700,
          height: 500,
          borderRadius: '50%',
          background: 'rgba(127,200,216,.16)',
          filter: 'blur(80px)',
          opacity: icon,
          transform: `scale(${0.6 + 0.4 * Math.min(1, icon)})`,
        }}
      />
      <div style={{ display: 'flex', alignItems: 'center', gap: 34 }}>
        <div style={{ transform: `scale(${0.3 + 0.7 * icon}) rotate(${(1 - icon) * -14}deg)` }}>
          <Bolt size={150} />
        </div>
        <div style={{ fontSize: 128, fontWeight: 700, letterSpacing: -4, opacity: word, transform: `translateX(${(1 - word) * 60}px)`, clipPath: `inset(0 ${(1 - word) * 100}% 0 0)` }}>
          FlowLedger
        </div>
      </div>
      <div style={{ fontSize: 40, fontWeight: 500, marginTop: 34, color: C.muted, opacity: tag, transform: `translateY(${(1 - tag) * 16}px)` }}>
        {t.tagline} <Accent size={48}>{t.taglineAccent}</Accent>
      </div>
    </AbsoluteFill>
  );
};

const Work: React.FC<{ t: Copy }> = ({ t }) => {
  const f = useCurrentFrame();
  const win = ramp(f, 2, 26);
  const count = interpolate(f, [18, 58], [0, 1], { ...clamp, easing: Easing.out(Easing.cubic) });
  const values = [18750, 6000, 12750, 2];
  const rowColors = [C.ok, C.warn, C.ok, C.warn];
  const rowTotals = [8000, 12000, 750, 3000];
  return (
    <AbsoluteFill>
      <Headline f={f} title={t.workTitle} accent={t.workAccent} body={t.workBody} />
      <div
        style={{
          position: 'absolute',
          left: 700 + (1 - win) * 320,
          top: 180,
          width: 1160,
          height: 780,
          opacity: win,
          background: C.surface,
          border: `1px solid ${C.ol}`,
          borderRadius: 22,
          boxShadow: '0 60px 120px rgba(0,0,0,.6)',
          overflow: 'hidden',
          transform: `perspective(2200px) rotateY(${-9 - (1 - win) * 14}deg) rotateX(3deg)`,
          transformOrigin: 'left center',
        }}
      >
        <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: 230, borderRight: `1px solid ${C.ov}`, padding: '26px 18px', background: '#0F1217' }}>
          {t.nav.map((n, i) => (
            <div
              key={n}
              style={{
                padding: '12px 16px',
                borderRadius: 12,
                fontSize: 19,
                fontWeight: 600,
                marginBottom: 4,
                color: i === 1 ? C.accent : C.muted,
                background: i === 1 ? C.accentC : 'transparent',
              }}
            >
              {n}
            </div>
          ))}
        </div>
        <div style={{ position: 'absolute', left: 230, right: 0, top: 0, bottom: 0, padding: '30px 36px' }}>
          <div style={{ fontSize: 17, color: C.muted, marginBottom: 8 }}>{t.crumb}</div>
          <div style={{ fontSize: 36, fontWeight: 700, letterSpacing: -1 }}>Northwind Studio</div>
          <div style={{ display: 'flex', marginTop: 24, border: `1px solid ${C.ov}`, borderRadius: 16, background: C.high }}>
            {t.strip.map((label, i) => (
              <div key={label} style={{ flex: 1, padding: '18px 22px', borderRight: i < 3 ? `1px solid ${C.ov}` : 0 }}>
                <Label>{label}</Label>
                <div style={{ fontSize: 32, fontWeight: 700, marginTop: 6, letterSpacing: -0.5, color: i === 2 ? C.accent : C.text, fontVariantNumeric: 'tabular-nums' }}>
                  {i === 3 ? Math.round(values[i] * count) : money(values[i] * count, t.thousands)}
                </div>
              </div>
            ))}
          </div>
          <div style={{ marginTop: 24, border: `1px solid ${C.ov}`, borderRadius: 16, overflow: 'hidden' }}>
            {t.rows.map(([title, sub], i) => {
              const p = ramp(f, 30 + i * 7, 12);
              return (
                <div
                  key={title}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 18,
                    padding: '18px 20px',
                    borderBottom: i < 3 ? `1px solid ${C.ov}` : 0,
                    fontSize: 20,
                    opacity: p,
                    transform: `translateX(${(1 - p) * 30}px)`,
                  }}
                >
                  <div style={{ width: 12, height: 12, borderRadius: '50%', background: rowColors[i] }} />
                  <div style={{ flex: 1 }}>
                    <b>{title}</b>
                    <div style={{ color: C.muted, fontSize: 16, marginTop: 4 }}>{sub}</div>
                  </div>
                  <b>{money(rowTotals[i], t.thousands)}</b>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </AbsoluteFill>
  );
};

const Revisions: React.FC<{ t: Copy }> = ({ t }) => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const card = ramp(f, 4, 16);
  const fb = ramp(f, 46, 16);
  // Final version status: Draft → Sent → Approved.
  const finalStatus = f < 42 ? 0 : f < 58 ? 1 : 2;
  const statusPop = pop(f, [0, 42, 58][finalStatus], fps);
  const statusStyle = [
    { bg: C.high, fg: C.muted },
    { bg: C.secC, fg: C.sec },
    { bg: C.okC, fg: C.ok },
  ][finalStatus];
  const labels = ['V1', 'V2', 'Final'];
  return (
    <AbsoluteFill>
      <Headline f={f} title={t.revTitle} accent={t.revAccent} body={t.revBody} />
      <div style={{ ...cardStyle, left: 720, top: 250, width: 560, opacity: card, transform: `translateY(${(1 - card) * 40}px)` }}>
        <Label style={{ marginBottom: 18 }}>{t.versionsLabel}</Label>
        {labels.map((v, i) => {
          const p = ramp(f, 12 + i * 8, 10);
          const isFinal = i === 2;
          return (
            <div
              key={v}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 18,
                padding: '14px 0',
                borderBottom: i < 2 ? `1px solid ${C.ov}` : 0,
                fontSize: 20,
                opacity: p * (isFinal ? 1 : i === 0 ? 0.5 : 0.7),
                transform: `translateY(${(1 - p) * 12}px)`,
              }}
            >
              <b style={{ width: 70 }}>{v}</b>
              <span style={{ flex: 1, color: C.muted }}>{t.dates[i]}</span>
              {isFinal ? (
                <Tag bg={statusStyle.bg} fg={statusStyle.fg} style={{ transform: `scale(${0.8 + 0.2 * statusPop})`, display: 'inline-block' }}>
                  {finalStatus === 2 ? '✓ ' : ''}
                  {t.status[finalStatus]}
                </Tag>
              ) : (
                <Tag bg={C.secC} fg={C.sec}>
                  {t.status[1]}
                </Tag>
              )}
            </div>
          );
        })}
      </div>
      <div
        style={{
          position: 'absolute',
          left: 1340,
          top: 400,
          padding: '14px 22px',
          borderRadius: 14,
          background: 'rgba(26,31,40,.85)',
          border: '1px solid #23505e',
          color: C.accent,
          fontFamily: MONO,
          fontSize: 22,
          opacity: ramp(f, 36, 10),
          transform: `translateX(${(1 - ramp(f, 36, 10)) * 30}px)`,
          whiteSpace: 'nowrap',
        }}
      >
        {t.flow}
      </div>
      <div style={{ ...cardStyle, left: 1160, top: 560, width: 680, padding: '24px 28px', opacity: fb, transform: `translateY(${(1 - fb) * 40}px)` }}>
        <Label style={{ marginBottom: 14 }}>{t.feedbackLabel}</Label>
        {t.feedback.map((text, i) => {
          const p = ramp(f, 56 + i * 12, 10);
          const tagP = pop(f, 64 + i * 14, fps);
          return (
            <div
              key={text}
              style={{
                display: 'flex',
                gap: 14,
                alignItems: 'center',
                padding: '12px 0',
                borderBottom: i === 0 ? `1px solid ${C.ov}` : 0,
                opacity: p,
                transform: `translateX(${(1 - p) * 20}px)`,
              }}
            >
              <Tag bg={C.high} fg={C.muted} style={{ fontFamily: MONO }}>
                {i === 0 ? '00:43' : '01:12'}
              </Tag>
              <div style={{ flex: 1, fontSize: 21 }}>{text}</div>
              <Tag
                bg={i === 0 ? C.accentC : C.warnC}
                fg={i === 0 ? C.accent : C.warn}
                style={{ display: 'inline-block', transform: `scale(${Math.max(0, tagP)})` }}
              >
                {t.tags[i]}
              </Tag>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

const Payments: React.FC<{ t: Copy }> = ({ t }) => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const balance = interpolate(f, [16, 50], [12750, 0], { ...clamp, easing: Easing.inOut(Easing.cubic) });
  const check = pop(f, 54, fps);
  const settled = f >= 50;
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', textAlign: 'center', top: 60 }}>
      <Label style={{ fontSize: 22, letterSpacing: 3, opacity: ramp(f, 2, 10) }}>{t.balanceLabel}</Label>
      <div
        style={{
          fontSize: 220,
          fontWeight: 800,
          letterSpacing: -8,
          marginTop: 10,
          fontVariantNumeric: 'tabular-nums',
          color: settled ? C.text : C.accent,
          transform: `scale(${settled ? 1 + 0.04 * Math.max(0, 1 - (f - 50) / 8) : 1})`,
        }}
      >
        {money(balance, t.thousands)}
      </div>
      <div style={{ display: 'flex', gap: 18, marginTop: 10 }}>
        {t.payments.map((label, i) => {
          const p = pop(f, 8 + i * 12, fps);
          return (
            <div
              key={label}
              style={{
                padding: '14px 22px',
                borderRadius: 14,
                background: 'rgba(26,31,40,.85)',
                border: `1px solid ${C.ol}`,
                fontFamily: MONO,
                fontSize: 22,
                color: C.muted,
                opacity: Math.min(1, p),
                transform: `scale(${0.7 + 0.3 * p})`,
              }}
            >
              {label} · <b style={{ color: C.text, fontWeight: 500 }}>{money([6000, 12750][i], t.thousands)}</b>
            </div>
          );
        })}
      </div>
      <div style={{ marginTop: 60, display: 'flex', alignItems: 'center', gap: 18, fontSize: 30, fontWeight: 600, opacity: Math.min(1, check) }}>
        <span
          style={{
            width: 52,
            height: 52,
            borderRadius: '50%',
            background: C.ok,
            color: C.bg,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: 30,
            transform: `scale(${check})`,
          }}
        >
          ✓
        </span>
        {t.closed} <Accent size={40}>{t.closedAccent}</Accent>
      </div>
    </AbsoluteFill>
  );
};

const Proof: React.FC<{ t: Copy }> = ({ t }) => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const h = ramp(f, 0, 12);
  const widths = [360, 400, 400, 360];
  return (
    <AbsoluteFill>
      <div
        style={{
          position: 'absolute',
          top: 230,
          width: '100%',
          textAlign: 'center',
          fontSize: 64,
          fontWeight: 700,
          letterSpacing: -2,
          opacity: h,
          transform: `translateY(${(1 - h) * 24}px)`,
        }}
      >
        {t.proofTitle} <Accent size={80}>{t.proofAccent}</Accent>
      </div>
      <div style={{ position: 'absolute', top: 440, width: '100%', display: 'flex', justifyContent: 'center', gap: 28 }}>
        {t.cards.map(([label, value, sub], i) => {
          const p = pop(f, 8 + i * 4, fps);
          const isCloud = i === 3;
          return (
            <div
              key={label}
              style={{
                width: widths[i],
                height: 270,
                background: C.surface,
                border: `1px solid ${isCloud ? '#23505e' : C.ol}`,
                borderRadius: 22,
                padding: '30px 32px',
                boxShadow: '0 40px 90px rgba(0,0,0,.55)',
                opacity: Math.min(1, p),
                transform: `translateY(${(1 - p) * 140 + (i % 2) * 22}px)`,
              }}
            >
              <Label style={{ color: isCloud ? C.accent : C.muted }}>{label}</Label>
              <div
                style={{
                  fontSize: value.length > 3 ? 60 : 100,
                  fontWeight: 800,
                  letterSpacing: -3,
                  marginTop: value.length > 3 ? 34 : 14,
                  color: isCloud ? C.accent : C.text,
                  whiteSpace: 'nowrap',
                }}
              >
                {value}
              </div>
              <div style={{ color: C.muted, fontSize: 21, marginTop: value.length > 3 ? 20 : 0 }}>{sub}</div>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

const Cta: React.FC<{ t: Copy }> = ({ t }) => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const icon = pop(f, 0, fps);
  const line = ramp(f, 8, 12);
  const btn = pop(f, 14, fps);
  const pulse = 1 + 0.05 * Math.sin(Math.max(0, Math.min(1, (f - 36) / 12)) * Math.PI);
  const foot = ramp(f, 22, 12);
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', textAlign: 'center' }}>
      <div style={{ position: 'absolute', width: 800, height: 520, borderRadius: '50%', background: 'rgba(127,200,216,.14)', filter: 'blur(80px)' }} />
      <div style={{ display: 'flex', alignItems: 'center', gap: 28, transform: `scale(${0.85 + 0.15 * icon})`, opacity: Math.min(1, icon) }}>
        <Bolt size={120} />
        <div style={{ fontSize: 108, fontWeight: 700, letterSpacing: -3.5 }}>FlowLedger</div>
      </div>
      <div style={{ fontSize: 44, fontWeight: 600, marginTop: 30, opacity: line, transform: `translateY(${(1 - line) * 16}px)` }}>
        {t.ctaLine} <Accent size={54}>{t.ctaAccent}</Accent>
      </div>
      <div
        style={{
          display: 'inline-flex',
          alignItems: 'center',
          gap: 14,
          padding: '22px 40px',
          borderRadius: 99,
          background: C.accent,
          color: C.bg,
          fontWeight: 700,
          fontSize: 32,
          marginTop: 54,
          opacity: Math.min(1, btn),
          transform: `scale(${(0.8 + 0.2 * btn) * pulse})`,
          boxShadow: `0 0 ${40 * (pulse - 1) * 20}px rgba(127,200,216,.5)`,
        }}
      >
        <span style={{ fontFamily: MONO, fontSize: 28, fontWeight: 500 }}>github.com/burry0/FlowLedger</span> ↗
      </div>
      <div style={{ fontFamily: MONO, color: C.muted, fontSize: 20, marginTop: 30, opacity: foot }}>{t.footer}</div>
    </AbsoluteFill>
  );
};

// ---------- composition ----------

export const Promo: React.FC<{ locale: Locale }> = ({ locale }) => {
  const t = copy[locale];
  const s = SCENES;
  return (
    <AbsoluteFill lang={locale} style={{ fontFamily: SANS, color: C.text }}>
      <Background />
      <Audio src={staticFile('audio/soundtrack.m4a')} />
      <Sequence from={s.chaos[0]} durationInFrames={s.chaos[1]}>
        <Scene dur={s.chaos[1]} exit={false}>
          <Chaos t={t} />
        </Scene>
      </Sequence>
      <Sequence from={s.logo[0]} durationInFrames={s.logo[1]}>
        <Scene dur={s.logo[1]}>
          <Logo t={t} />
        </Scene>
      </Sequence>
      <Sequence from={s.work[0]} durationInFrames={s.work[1] + s.revisions[1] + s.payments[1]}>
        <TopBar t={t} />
      </Sequence>
      <Sequence from={s.work[0]} durationInFrames={s.work[1]}>
        <Scene dur={s.work[1]}>
          <Work t={t} />
        </Scene>
      </Sequence>
      <Sequence from={s.revisions[0]} durationInFrames={s.revisions[1]}>
        <Scene dur={s.revisions[1]}>
          <Revisions t={t} />
        </Scene>
      </Sequence>
      <Sequence from={s.payments[0]} durationInFrames={s.payments[1]}>
        <Scene dur={s.payments[1]}>
          <Payments t={t} />
        </Scene>
      </Sequence>
      <Sequence from={s.proof[0]} durationInFrames={s.proof[1]}>
        <Scene dur={s.proof[1]}>
          <Proof t={t} />
        </Scene>
      </Sequence>
      <Sequence from={s.cta[0]} durationInFrames={s.cta[1]}>
        <Scene dur={s.cta[1]} exit={false}>
          <Cta t={t} />
        </Scene>
      </Sequence>
    </AbsoluteFill>
  );
};
