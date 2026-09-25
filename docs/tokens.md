# Composition tokens

| Token | Value | Decision |
| --- | ---: | --- |
| fieldGap | 8 | Label/control/supporting-text separation |
| contentGap | 24 | Independent content separation and default content inset |
| formMaxWidth | 960 | Readable small form width |
| formColumnMinWidth | 280 | Base useful field width before user text scaling |
| controlMinHeight | 48 | Minimum interactive target height |

These are composition defaults, not a copied palette of legacy tokens.
Shadcn owns visual radius, border, density, color and typography. No aliases,
additional radius system or motion tokens are introduced. The 48-pixel policy
applies to the control only; labels and supporting text grow freely.
