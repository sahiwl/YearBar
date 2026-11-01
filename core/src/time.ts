export type TimeMode = "year" | "month" | "week";

export type DayCounts = { spent: number; remaining: number };

function startOfYear(d: Date): Date {
  return new Date(d.getFullYear(), 0, 1);
}

function startOfMonth(d: Date): Date {
  return new Date(d.getFullYear(), d.getMonth(), 1);
}

/** Monday-based week start (ISO-style), local time. */
function startOfWeek(d: Date): Date {
  const day = d.getDay(); // 0 Sun .. 6 Sat
  const mondayOffset = day === 0 ? -6 : 1 - day;
  const start = new Date(d.getFullYear(), d.getMonth(), d.getDate() + mondayOffset);
  start.setHours(0, 0, 0, 0);
  return start;
}

function addYears(d: Date, n: number): Date {
  return new Date(d.getFullYear() + n, d.getMonth(), d.getDate(), d.getHours(), d.getMinutes(), d.getSeconds(), d.getMilliseconds());
}

function addMonths(d: Date, n: number): Date {
  return new Date(d.getFullYear(), d.getMonth() + n, 1);
}

function addDays(d: Date, n: number): Date {
  const out = new Date(d);
  out.setDate(out.getDate() + n);
  return out;
}

function ratio(elapsed: number, total: number): number {
  if (total <= 0) return 0;
  return (elapsed / total) * 100;
}

export function yearProgress(at: Date = new Date()): number {
  const start = startOfYear(at);
  const end = addYears(start, 1);
  return ratio(at.getTime() - start.getTime(), end.getTime() - start.getTime());
}

export function monthProgress(at: Date = new Date()): number {
  const start = startOfMonth(at);
  const end = addMonths(start, 1);
  return ratio(at.getTime() - start.getTime(), end.getTime() - start.getTime());
}

export function weekProgress(at: Date = new Date()): number {
  const start = startOfWeek(at);
  const end = addDays(start, 7);
  return ratio(at.getTime() - start.getTime(), end.getTime() - start.getTime());
}

export function progress(mode: TimeMode, at: Date = new Date()): number {
  switch (mode) {
    case "year":
      return yearProgress(at);
    case "month":
      return monthProgress(at);
    case "week":
      return weekProgress(at);
  }
}

function wholeDaysBetween(from: Date, to: Date): number {
  const ms = to.getTime() - from.getTime();
  return Math.floor(ms / 86_400_000);
}

export function yearDayCounts(at: Date = new Date()): DayCounts {
  const start = startOfYear(at);
  const end = addYears(start, 1);
  const spent = wholeDaysBetween(start, at);
  const total = wholeDaysBetween(start, end);
  return { spent, remaining: total - spent };
}

export function monthDayCounts(at: Date = new Date()): DayCounts {
  const spent = at.getDate();
  const total = new Date(at.getFullYear(), at.getMonth() + 1, 0).getDate();
  return { spent, remaining: total - spent };
}

export function weekDayCounts(at: Date = new Date()): DayCounts {
  const start = startOfWeek(at);
  const end = addDays(start, 7);
  const spent = wholeDaysBetween(start, at);
  const total = wholeDaysBetween(start, end);
  return { spent, remaining: total - spent };
}

export function dayCounts(mode: TimeMode, at: Date = new Date()): DayCounts {
  switch (mode) {
    case "year":
      return yearDayCounts(at);
    case "month":
      return monthDayCounts(at);
    case "week":
      return weekDayCounts(at);
  }
}

export function formatPercent(value: number, decimals = 1): string {
  return `${value.toFixed(decimals)}%`;
}
