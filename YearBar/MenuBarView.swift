import SwiftUI

struct MenuBarView: View {

    @Binding var selectedMode: TimeMode
    let yearProgress: Double
    let monthProgress: Double
    let weekProgress: Double

    private var activeDays: (spent: Int, remaining: Int) {
        TimeCalculator.dayCounts(for: selectedMode)
    }

    var body: some View {

        VStack(spacing: 16) {

            Text("Time Passed")
                .foregroundStyle(.primary)

            HStack(spacing: 20) {
                CircularProgressView(
                    progress: yearProgress,
                    label: "Year",
                    color: .blue,
                    isSelected: selectedMode == .year
                )
                .contentShape(Rectangle())
                .onTapGesture { selectedMode = .year }

                CircularProgressView(
                    progress: monthProgress,
                    label: "Month",
                    color: .orange,
                    isSelected: selectedMode == .month
                )
                .contentShape(Rectangle())
                .onTapGesture { selectedMode = .month }

                CircularProgressView(
                    progress: weekProgress,
                    label: "Week",
                    color: .green,
                    isSelected: selectedMode == .week
                )
                .contentShape(Rectangle())
                .onTapGesture { selectedMode = .week }
            }

            // Divider()

            let days = activeDays

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Remaining: \(days.remaining) days")
                    Text("Spent: \(days.spent) days")
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)

                Spacer()
            }

            Divider()

            HStack(spacing: 4) {
                Text("Built by")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                Link("Sahil", destination: URL(string: "https://github.com/sahiwl")!)
                    .font(.system(size: 12, weight: .medium))
            }

            Button("Quit") {
                // NSApplication.shared is the running macOS app instance.
                // .terminate(nil) shuts it down.
                NSApplication.shared.terminate(nil)
            }
            // .keyboardShortcut lets you trigger this with ⌘Q.
            .keyboardShortcut("q")
        }
        .padding(16)
    }
}
