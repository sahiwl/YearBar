import Foundation

enum TimeMode: String, CaseIterable {
    case year = "Year"
    case month = "Month"
    case week = "Week"
}

struct TimeCalculator {

    // All methods accept an optional `at:` date so every caller can
    // compute from the same instant, eliminating drift between values.

    // MARK: - Progress (seconds-based for sub-day accuracy)

    static func yearProgress(at now: Date = Date()) -> Double {
        let calendar = Calendar.current
        guard let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)),
              let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)
        else { return 0 }
        let total = endOfYear.timeIntervalSince(startOfYear)
        let elapsed = now.timeIntervalSince(startOfYear)
        return (elapsed / total) * 100
    }

    static func monthProgress(at now: Date = Date()) -> Double {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)
        else { return 0 }
        let total = endOfMonth.timeIntervalSince(startOfMonth)
        let elapsed = now.timeIntervalSince(startOfMonth)
        return (elapsed / total) * 100
    }

    static func weekProgress(at now: Date = Date()) -> Double {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)
        else { return 0 }
        let total = endOfWeek.timeIntervalSince(startOfWeek)
        let elapsed = now.timeIntervalSince(startOfWeek)
        return (elapsed / total) * 100
    }

    static func progress(for mode: TimeMode, at now: Date = Date()) -> Double {
        switch mode {
        case .year: yearProgress(at: now)
        case .month: monthProgress(at: now)
        case .week: weekProgress(at: now)
        }
    }

    // MARK: - Day Counts (complete days elapsed)

    static func yearDayCounts(at now: Date = Date()) -> (spent: Int, remaining: Int) {
        let calendar = Calendar.current
        guard let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)),
              let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)
        else { return (0, 0) }
        let spent = calendar.dateComponents([.day], from: startOfYear, to: now).day ?? 0
        let totalDays = calendar.dateComponents([.day], from: startOfYear, to: endOfYear).day ?? 365
        return (spent, totalDays - spent)
    }

    /// Spent = day of month (1–28), remaining = days left in month. Matches month progress.
    static func monthDayCounts(at now: Date = Date()) -> (spent: Int, remaining: Int) {
        let calendar = Calendar.current
        let spent = calendar.component(.day, from: now)
        guard let range = calendar.range(of: .day, in: .month, for: now) else { return (0, 0) }
        let totalDays = range.count
        return (spent, totalDays - spent)
    }

    static func weekDayCounts(at now: Date = Date()) -> (spent: Int, remaining: Int) {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)
        else { return (0, 0) }
        let spent = calendar.dateComponents([.day], from: startOfWeek, to: now).day ?? 0
        let totalDays = calendar.dateComponents([.day], from: startOfWeek, to: endOfWeek).day ?? 7
        return (spent, totalDays - spent)
    }

    static func dayCounts(for mode: TimeMode, at now: Date = Date()) -> (spent: Int, remaining: Int) {
        switch mode {
        case .year: yearDayCounts(at: now)
        case .month: monthDayCounts(at: now)
        case .week: weekDayCounts(at: now)
        }
    }
}
