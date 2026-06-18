---
name: Aura Radiant
source: Google Stitch (design-first, generated before any code)
colors:
  surface: '#fff8f5'
  surface-container-low: '#fff1e9'
  surface-container: '#fcebe1'
  surface-container-high: '#f6e5db'
  surface-container-highest: '#f0dfd6'
  surface-container-lowest: '#ffffff'
  on-surface: '#221a14'
  on-surface-variant: '#534434'
  outline-variant: '#d8c3ad'
  primary: '#855300'
  primary-container: '#f59e0b'
  on-primary: '#ffffff'
  secondary: '#a93349'
  secondary-container: '#fe7488'
  tertiary: '#944a23'
  error: '#ba1a1a'
  background: '#fff8f5'
typography:
  font-family: Inter
  display-lg: { size: 48, weight: 800, tracking: -0.02em }
  headline-lg: { size: 32, weight: 700, tracking: -0.01em }
  headline-md: { size: 24, weight: 600 }
  body-lg: { size: 18, weight: 400 }
  body-md: { size: 16, weight: 400 }
  label-md: { size: 14, weight: 600 }
  label-sm: { size: 12, weight: 500 }
rounded: { sm: 4, DEFAULT: 8, md: 12, lg: 16, xl: 24, full: 9999 }
spacing: { base: 8, container-margin: 24, gutter: 16 }
---

## Brand & Style
"Golden Hour" warmth - human, inviting, socially optimistic. Modern-Organic:
high-key lighting, soft physical depth, limited but vibrant palette. Soft shadows
and rounded geometries that feel like soft-touch material in late-afternoon sun.
Emotional response: comfort, energy, clarity.

## Colors
Warm off-white base (no pure #FFFFFF). Amber primary for CTAs/active states.
Sunset pink for social interactions (likes/hearts). Deep-cocoa text (#221a14)
keeps warmth even at the darkest values (no sterile pure black).

## Typography
Inter throughout. Weights bumped slightly to hold presence on the light surface.
Headlines: tighter tracking, heavier weight. Body: spacious, conversational.

## Elevation
Ambient shadows, never lines or glass. Warm amber-tinted shadow
(`rgba(120,53,15,0.05-0.12)`). Level 1 = cards, Level 2 = modals/overlays.

## Shapes
Consistently rounded - 16px for buttons/inputs/small cards, 24px for containers,
circular avatars. No sharp 90deg angles.

## Components
- Buttons: amber (#f59e0b) + white text, subtle "squish" inner-shadow.
- Inputs: darker off-white fill, no border; 2px amber stroke on focus.
- Cards: white/cream surface, Level 1 shadow, no borders.
- Chips: pill, 10% sunset-pink fill with full-color text.
- Hearts/likes: sunset pink (#fb7185) for a warm emotional pop.

> The four key screens (Onboarding, Discover, Map, Chat) were generated in Google
> Stitch first; the SwiftUI app was then built to match this design system
> (layout, color, typography, spacing, elevation).
