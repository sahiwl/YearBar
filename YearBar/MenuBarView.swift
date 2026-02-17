//
//  MenuBarView.swift
//  YearBar
//
//  Created by Sahil Kumar Ray on 17/02/26.
//

import SwiftUI

// This is the dropdown that appears when you click the menu bar item.

struct MenuBarView: View {

    var body: some View {

        VStack(spacing: 16) {

            // --- Header ---
            Text("Time Left")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)

            // --- Three circular progress bars side-by-side ---
            // HStack = horizontal stack (left to right).
            HStack(spacing: 20) {
                CircularProgressView(
                    progress: TimeCalculator.yearProgress(),
                    label: "Year",
                    color: .blue
                )
                CircularProgressView(
                    progress: TimeCalculator.monthProgress(),
                    label: "Month",
                    color: .orange
                )
                CircularProgressView(
                    progress: TimeCalculator.weekProgress(),
                    label: "Week",
                    color: .green
                )
            }

            // A thin horizontal line to separate content from the button.
            Divider()

            // --- Quit button ---
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
