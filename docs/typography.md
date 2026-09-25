# Typography

UiTextRole resolves four roles from the nearest shadcn typography:

| Role | Source |
| --- | --- |
| heading | sans merged with h3 |
| body | sans merged with p |
| label | sans merged with small and semiBold |
| supporting | sans merged with small |

There is no Material TextTheme or independent font-size scale. Color variation
for helper/error text comes from the same theme.

Flutter's inherited TextScaler is preserved. Typography does not depend on screen
width, title length, FittedBox or an overridden scale cap. Form layout samples the
body font's scaled size to allocate wider columns; it never shrinks the font.

The package tests exercise long labels/errors/helpers at 100%, 150% and 200% in
both directions and check rendered paragraph height against TextPainter metrics.
Single-line input text scrolls horizontally under shadcn's native editing behavior.
