# YearBar for Windows

Tauri 2 system-tray app that mirrors the macOS YearBar UI. Shared time math comes from [`../core`](../core).

## Prerequisites

- [Node.js](https://nodejs.org/) LTS
- [Rust](https://rustup.rs/) (`rustc` / `cargo`)
- WebView2 (preinstalled on most Windows 10/11)

## Develop

```powershell
cd windows
npm install
npm run tauri dev
```

The tray icon is a progress ring with the whole percent inside (Windows tray slots are square, so the text can't sit beside the ring like on macOS). Hover for the exact `X.X%`, left-click for the full panel, right-click → Quit. If the icon is hidden under `^`, drag it onto the taskbar.

## Build

```powershell
cd windows
npm run tauri build
```

Installers land under `src-tauri/target/release/bundle/`.
