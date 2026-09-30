import React from 'react';
import { Composition } from 'remotion';
import './fonts';
import { Promo, TOTAL } from './Promo';

export const Root: React.FC = () => (
  <>
    <Composition id="PromoEN" component={Promo} durationInFrames={TOTAL} fps={30} width={1920} height={1080} defaultProps={{ locale: 'en' as const }} />
    <Composition id="PromoTR" component={Promo} durationInFrames={TOTAL} fps={30} width={1920} height={1080} defaultProps={{ locale: 'tr' as const }} />
  </>
);
