# YearBar — Noctalia plugin

Bar capsule like **sysmon** (glyph + `%`, hover key/value tooltip).  
Click opens a **Mac-style** panel with three circular rings (Year / Month / Week).

## Install (CachyOS + Noctalia 5.4)

Your settings already point a path source at this folder’s parent:

```toml
[[plugins.source]]
name = "yearbar-dev"
kind = "path"
location = "/home/sahilkr/Repos/YearBar/linux/noctalia"
```

1. Make sure Noctalia is running.
2. Enable the plugin:
   ```bash
   noctalia msg plugins enable sahiwl/yearbar
   ```
3. **Settings → Bar** → add widget **`sahiwl/yearbar:bar`**  
   Put it in the same capsule group as sysmon if you want it next to CPU/RAM.
4. Click the widget → panel with rings. Hover → Year/Month/Week tooltip.

Or: Settings → Plugins → enable **YearBar**, then add the bar widget.

## Honest UI note

| Surface | Looks like |
|---|---|
| Bar capsule | **Noctalia** (same chrome as sysmon) — cannot be macOS menu bar |
| Hover tooltip | **Noctalia** key/value panel (like your screenshot) |
| Click panel | **Mac YearBar** layout (circular rings, labels, day counts) using theme colors |

Exact SwiftUI pixels aren’t possible inside Noctalia; the rings match Mac colors/geometry.

## Dev reload

After editing `.luau` files:

```bash
noctalia msg plugins disable sahiwl/yearbar
noctalia msg plugins enable sahiwl/yearbar
```
