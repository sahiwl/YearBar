//
//  TimeCalculator.swift
//  YearBar
//
//  Created by Sahil Kumar Ray on 17/02/26.
//

import Foundation

// A "struct" is like a lightweight container for related data and functions.
// We use static functions here because we don't need to create an instance --
// these are pure calculations that take no stored state.
struct TimeCalculator {

    // MARK: - Year Progress
    // "How much of this year has passed?"
    //
    // The idea: figure out the total seconds in the year,
    // then figure out how many seconds have elapsed so far.
    // Divide elapsed by total → percentage.

    static func yearProgress() -> Double {
        let calendar = Calendar.current
        let now = Date()

        // DateComponents lets you build a date piece by piece (year, month, day...).
        // calendar.date(from:) converts those components into a real Date object.
        guard let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)),
              let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)
        else { return 0 }

        // timeIntervalSince gives you the difference in seconds (as a Double).
        let total = endOfYear.timeIntervalSince(startOfYear)
        let elapsed = now.timeIntervalSince(startOfYear)

        return (elapsed / total) * 100
    }

    // MARK: - Month Progress
    // Same logic but scoped to the current month.

    static func monthProgress() -> Double {
        let calendar = Calendar.current
        let now = Date()

        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)
        else { return 0 }

        let total = endOfMonth.timeIntervalSince(startOfMonth)
        let elapsed = now.timeIntervalSince(startOfMonth)

        return (elapsed / total) * 100
    }

    // MARK: - Week Progress
    // Scoped to the current week (Sunday→Saturday or Monday→Sunday,
    // depending on the user's locale — Calendar handles this automatically).

    static func weekProgress() -> Double {
        let calendar = Calendar.current
        let now = Date()

        // .weekOfYear component gives us the start of the current week.
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)
        else { return 0 }

        let total = endOfWeek.timeIntervalSince(startOfWeek)
        let elapsed = now.timeIntervalSince(startOfWeek)

        return (elapsed / total) * 100
    }

    // MARK: - Year Day Counts
    // Returns a tuple: (daysSpent, daysRemaining) for the current year.
    //
    // "-> (spent: Int, remaining: Int)" is a named tuple — a lightweight way
    // to return multiple values without creating a whole struct.
    // You access results like: let info = yearDayCounts(); info.spent; info.remaining

    static func yearDayCounts() -> (spent: Int, remaining: Int) {
        let calendar = Calendar.current
        let now = Date()

        guard let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)),
              let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)
        else { return (0, 0) }

        // .day component between two dates gives whole days elapsed.
        let spent = calendar.dateComponents([.day], from: startOfYear, to: now).day ?? 0
        let totalDays = calendar.dateComponents([.day], from: startOfYear, to: endOfYear).day ?? 365
        let remaining = totalDays - spent

        return (spent, remaining)
    }
}
