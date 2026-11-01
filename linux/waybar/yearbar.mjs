#!/usr/bin/env node
/** Waybar custom module — prints JSON: {"text":"42.3%","tooltip":"..."} */
import {
  dayCounts,
  formatPercent,
  monthProgress,
  weekProgress,
  yearProgress,
} from "../../core/src/time.ts";

const year = yearProgress();
const month = monthProgress();
const week = weekProgress();
const days = dayCounts("year");

const text = formatPercent(year, 1);
const tooltip = [
  `Year ${formatPercent(year, 1)}`,
  `Month ${formatPercent(month, 1)}`,
  `Week ${formatPercent(week, 1)}`,
  `Remaining ${days.remaining}d · Spent ${days.spent}d`,
].join("\n");

process.stdout.write(JSON.stringify({ text, tooltip, class: "yearbar" }) + "\n");
