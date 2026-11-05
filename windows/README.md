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

If the build fails with `An Application Control policy has blocked this file (os error 4551)`, Smart App Control is blocking Rust's build helpers. Turn it off while building, or let GitHub Actions build it (below).

## Release

Mac and Windows share one version and one GitHub release per tag. The app's update check compares against the latest release tag.

1. Set `version` in [`src-tauri/Cargo.toml`](src-tauri/Cargo.toml) to the new version (e.g. `1.3.0`) and push.
2. Publish a GitHub release tagged `v1.3.0`.
3. [`.github/workflows/windows-release.yml`](../.github/workflows/windows-release.yml) builds the installer and attaches the `.exe` and `.msi` to that release. It fails early if the tag doesn't match `Cargo.toml`.

To test a build without releasing, run the workflow manually from the Actions tab; the installers are kept as workflow artifacts.
