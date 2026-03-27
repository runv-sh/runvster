# Runvster Brand

## Source

Brand direction derived from [assets/runvster.png](../assets/runvster.png).

The logo is visually aggressive, high-contrast, and fast. It feels closer to motorsport, competition, and performance branding than to a quiet SaaS dashboard.

## Core Palette

These are the representative colors sampled from the logo and simplified into design tokens.

```css
:root {
  --rv-color-brand-500: #f01010;
  --rv-color-brand-600: #e01010;
  --rv-color-brand-700: #d01010;
  --rv-color-brand-800: #c00010;
  --rv-color-white: #ffffff;

  /* inferred supporting neutrals */
  --rv-color-ink-900: #141414;
  --rv-color-ink-700: #2a2a2a;
  --rv-color-ink-100: #f6f6f6;
  --rv-color-ink-50: #fcfcfc;
}
```

## Visual Principles

- Use strong contrast. White on red should be a signature move, not an occasional accent.
- Avoid soft, washed-out UI. The brand wants confidence and clarity.
- Keep surfaces mostly light or near-black, then spend red deliberately on calls to action, active states, badges, and moderation emphasis.
- Rounded corners should be assertive, not bubbly.
- Motion should feel quick and purposeful.

## Product Personality

- fast
- sharp
- competitive
- technical
- trustworthy

## Typography Direction

Recommended pairings:

- display: `Sora`
- interface/body: `Inter Tight`
- fallback code font: `JetBrains Mono`

If we want something even more mechanical later, we can test `Oxanium` for headings.

## UI Guidance

- Keep feeds dense but readable.
- Use cards sparingly; list rhythm is more important than chrome.
- Give moderation states a strong visual language.
- Make voting, saving, and triage feel instant.
- Do not lean into generic purple-on-white startup styling.

