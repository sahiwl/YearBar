import { test } from "node:test";
import assert from "node:assert/strict";
import {
  dayCounts,
  monthProgress,
  weekProgress,
  yearProgress,
} from "./time.ts";

test("year progress at new year is ~0", () => {
  const at = new Date(2026, 0, 1, 0, 0, 0);
  assert.ok(yearProgress(at) < 0.01);
});

test("year progress mid-year is around 50", () => {
  const at = new Date(2026, 6, 2, 12, 0, 0);
  const p = yearProgress(at);
  assert.ok(p > 49 && p < 52, `got ${p}`);
});

test("month progress day 1 morning is low", () => {
  const at = new Date(2026, 10, 1, 1, 0, 0);
  assert.ok(monthProgress(at) < 5);
});

test("week progress Monday midnight is ~0", () => {
  // 2026-11-02 is a Monday
  const at = new Date(2026, 10, 2, 0, 0, 0);
  assert.ok(weekProgress(at) < 0.01);
});

test("year day counts on Nov 1 2026", () => {
  const at = new Date(2026, 10, 1, 12, 0, 0);
  const { spent, remaining } = dayCounts("year", at);
  assert.equal(spent, 304); // Jan1..Nov1 = 304 days into year for non-leap? 2026 not leap
  // 365 - 304 = 61 if spent is whole days from Jan 1 to Nov 1
  assert.equal(spent + remaining, 365);
});
