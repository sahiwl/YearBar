//
//  CircularProgressView.swift
//  YearBar
//
//  Created by Sahil Kumar Ray on 17/02/26.
//

import SwiftUI

// A reusable circular progress bar.
// In SwiftUI, you build UI by composing small "View" structs like this.

struct CircularProgressView: View {

    // These are the inputs (parameters) this view needs.
    // "let" means they're constants — set once when you create the view.
    let progress: Double       // 0–100
    let label: String          // e.g. "Year"
    let color: Color           // ring color

    // "body" is the ONE required property of any View.
    // It describes what this view looks like.
    var body: some View {

        // VStack = vertical stack. It arranges children top-to-bottom.
        VStack(spacing: 8) {

            // ZStack layers views on top of each other (back to front).
            // Perfect for putting text on top of a ring.
            ZStack {

                // Background ring (the "track")
                Circle()
                    // .stroke draws just the outline, not a filled circle.
                    // lineWidth is how thick the ring is.
                    .stroke(color.opacity(0.15), lineWidth: 6)

                // Foreground ring (the "progress arc")
                Circle()
                    // .trim(from:to:) draws only a portion of the circle.
                    // from: 0, to: 0.75 would draw 75% of the ring.
                    .trim(from: 0, to: progress / 100)
                    // StrokeStyle lets us set lineWidth AND lineCap.
                    // .round makes the ends of the arc rounded instead of flat.
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    // By default, SwiftUI draws circles starting at 3 o'clock.
                    // Rotating -90° makes it start at 12 o'clock (top).
                    .rotationEffect(.degrees(-90))

                // Percentage text in the center
                Text("\(String(format: "%.1f", progress))%")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(color)
            }
            .frame(width: 72, height: 72)

            // Label below the ring
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)   // .secondary = slightly dimmed text
        }
    }
}
