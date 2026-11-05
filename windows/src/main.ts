import { invoke } from "@tauri-apps/api/core";
import { disable as disableAutostart, enable as enableAutostart, isEnabled as isAutostartEnabled } from "@tauri-apps/plugin-autostart";
import { openUrl } from "@tauri-apps/plugin-opener";
import {
  dayCounts,
  formatPercent,
  monthProgress,
  type TimeMode,
  weekProgress,
  yearProgress,
} from "@yearbar/core";

const COLORS: Record<TimeMode, string> = {
  year: "#0A84FF",
  month: "#FF9F0A",
  week: "#30D158",
};

const LABELS: Record<TimeMode, string> = {
  year: "Year",
  month: "Month",
  week: "Week",
};

const APP_VERSION = "0.1.0";
const REPO = "sahiwl/YearBar";

type Snapshot = {
  at: Date;
  year: number;
  month: number;
  week: number;
};

let selected: TimeMode = "year";
let snap: Snapshot = readSnapshot();
let checkingUpdates = false;
let launchAtLogin = false;

function readSnapshot(at = new Date()): Snapshot {
  return {
    at,
    year: yearProgress(at),
    month: monthProgress(at),
    week: weekProgress(at),
  };
}

function activeProgress(): number {
  return snap[selected];
}

function ringSvg(progress: number, color: string): string {
  const p = Math.min(100, Math.max(0, progress));
  const circ = 2 * Math.PI * 30;
  const offset = circ * (1 - p / 100);
  const text = `${p.toFixed(2)}%`;
  return `
    <svg class="ring-svg" viewBox="0 0 72 72" aria-hidden="true">
      <circle cx="36" cy="36" r="30" fill="none" stroke="${color}" stroke-opacity="0.15" stroke-width="6"/>
      <circle cx="36" cy="36" r="30" fill="none" stroke="${color}" stroke-width="6"
        stroke-linecap="round" stroke-dasharray="${circ.toFixed(4)}" stroke-dashoffset="${offset.toFixed(4)}"
        transform="rotate(-90 36 36)"/>
      <text x="36" y="40.5" text-anchor="middle" font-size="13" font-weight="600"
        font-family="Segoe UI, system-ui, sans-serif" fill="${color}">${text}</text>
    </svg>`;
}

function renderRings() {
  const root = document.getElementById("rings");
  if (!root) return;

  root.innerHTML = (["year", "month", "week"] as TimeMode[])
    .map((mode) => {
      const color = COLORS[mode];
      const selectedClass = mode === selected ? " selected" : "";
      return `
        <button type="button" class="ring-item${selectedClass}" data-mode="${mode}" aria-pressed="${mode === selected}">
          ${ringSvg(snap[mode], color)}
          <span class="ring-label">${LABELS[mode]}</span>
          <span class="ring-dot" style="background:${color}"></span>
        </button>`;
    })
    .join("");

  root.querySelectorAll<HTMLButtonElement>(".ring-item").forEach((btn) => {
    btn.addEventListener("click", () => {
      const mode = btn.dataset.mode as TimeMode;
      if (!mode || mode === selected) return;
      selected = mode;
      render();
    });
  });
}

function renderDays() {
  const el = document.getElementById("days");
  if (!el) return;
  const days = dayCounts(selected, snap.at);
  el.innerHTML = `
    <div>Remaining: ${days.remaining} days</div>
    <div>Spent: ${days.spent} days</div>`;
}

async function syncTray() {
  const progress = activeProgress();
  const tooltip = `${LABELS[selected]} ${formatPercent(progress, 1)}`;
  try {
    await invoke("update_tray", { progress, tooltip });
  } catch (err) {
    console.error("update_tray failed", err);
  }
}

function render() {
  renderRings();
  renderDays();
  void syncTray();
}

function refresh() {
  snap = readSnapshot();
  render();
}

function showAlert(title: string, message: string, actions: { label: string; primary?: boolean; onClick?: () => void }[]) {
  const root = document.getElementById("alert");
  const titleEl = document.getElementById("alert-title");
  const msgEl = document.getElementById("alert-message");
  const actionsEl = document.getElementById("alert-actions");
  if (!root || !titleEl || !msgEl || !actionsEl) return;

  titleEl.textContent = title;
  msgEl.textContent = message;
  actionsEl.innerHTML = "";
  for (const action of actions) {
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "btn";
    btn.textContent = action.label;
    btn.addEventListener("click", () => {
      root.hidden = true;
      action.onClick?.();
    });
    actionsEl.appendChild(btn);
  }
  root.hidden = false;
}

function parseVersion(s: string): number[] {
  return s.split(".").map((part) => Number.parseInt(part, 10) || 0);
}

function isNewer(latest: string, current: string): boolean {
  const l = parseVersion(latest);
  const c = parseVersion(current);
  const n = Math.max(l.length, c.length);
  for (let i = 0; i < n; i++) {
    const a = l[i] ?? 0;
    const b = c[i] ?? 0;
    if (a > b) return true;
    if (a < b) return false;
  }
  return false;
}

async function checkUpdates() {
  if (checkingUpdates) return;
  checkingUpdates = true;
  const btn = document.getElementById("btn-updates") as HTMLButtonElement | null;
  const spinner = document.getElementById("updates-spinner");
  if (btn) btn.disabled = true;
  if (spinner) spinner.hidden = false;

  try {
    const res = await fetch(`https://api.github.com/repos/${REPO}/releases/latest`, {
      headers: { Accept: "application/vnd.github+json" },
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const json = (await res.json()) as { tag_name?: string; html_url?: string };
    const tag = json.tag_name ?? "";
    const latest = tag.startsWith("v") ? tag.slice(1) : tag;
    const url = json.html_url;

    if (latest && url && isNewer(latest, APP_VERSION)) {
      showAlert("Update available", `Version ${latest} is available.`, [
        { label: "Cancel" },
        {
          label: "Open release",
          primary: true,
          onClick: () => {
            void openUrl(url);
          },
        },
      ]);
    } else {
      showAlert("Up to date", "You're on the latest version.", [{ label: "OK" }]);
    }
  } catch {
    showAlert("Up to date", "You're on the latest version.", [{ label: "OK" }]);
  } finally {
    checkingUpdates = false;
    if (btn) btn.disabled = false;
    if (spinner) spinner.hidden = true;
  }
}

async function refreshAutostartLabel() {
  const btn = document.getElementById("btn-autostart");
  try {
    launchAtLogin = await isAutostartEnabled();
  } catch {
    launchAtLogin = false;
  }
  if (btn) btn.textContent = `Launch at login: ${launchAtLogin ? "On" : "Off"}`;
}

async function toggleAutostart() {
  try {
    if (launchAtLogin) {
      await disableAutostart();
      launchAtLogin = false;
    } else {
      await enableAutostart();
      launchAtLogin = true;
      showAlert("Launch at login", "YearBar will open when you log in.", [{ label: "OK" }]);
    }
  } catch (err) {
    console.error(err);
    showAlert("Launch at login", "Could not change startup setting.", [{ label: "OK" }]);
  }
  await refreshAutostartLabel();
}

async function quit() {
  await invoke("quit_app");
}

window.addEventListener("DOMContentLoaded", () => {
  document.getElementById("btn-updates")?.addEventListener("click", () => {
    void checkUpdates();
  });
  document.getElementById("btn-autostart")?.addEventListener("click", () => {
    void toggleAutostart();
  });
  document.getElementById("btn-quit")?.addEventListener("click", () => {
    void quit();
  });
  document.getElementById("link-sahil")?.addEventListener("click", (e) => {
    e.preventDefault();
    void openUrl("https://github.com/sahiwl");
  });

  void refreshAutostartLabel();
  refresh();
  window.setInterval(refresh, 60_000);
});
