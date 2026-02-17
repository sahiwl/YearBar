//
//  YearBarApp.swift
//  YearBar
//
//  Created by Sahil Kumar Ray on 17/02/26.
//

import SwiftUI
import AppKit
internal import Combine

// @main tells Swift "this is the entry point of the app."
// The App protocol is SwiftUI's way of defining an application.
@main
struct YearBarApp: App {

    // @State is SwiftUI's way of saying "this variable can change,
    // and when it does, redraw anything that uses it."
    // Here we store the year progress percentage so the menu bar text updates live.
    @State private var yearProgress: Double = TimeCalculator.yearProgress()

    // A Timer that fires every 60 seconds to refresh the percentage.
    // We store it so it stays alive for the app's lifetime.
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some Scene {
        // MenuBarExtra is the magic API (macOS 13+) that puts your app
        // in the menu bar instead of opening a window.
        //
        // The "content:" closure is the DROPDOWN when clicked.
        // The "label:" closure is what shows IN the menu bar itself.
        MenuBarExtra {
            MenuBarView()
                // .onReceive listens to a Publisher (here, our timer).
                // Every time the timer fires, we recalculate the year progress.
                .onReceive(timer) { _ in
                    yearProgress = TimeCalculator.yearProgress()
                }
        } label: {
            // The menu bar label: a small ring icon + percentage text.
            // We render the ring as an NSImage because the menu bar
            // only reliably displays Image and Text, not arbitrary shapes.
            HStack(spacing: 3) {
                Image(nsImage: MenuBarIconRenderer.render(progress: yearProgress))
                Text("\(String(format: "%.1f", yearProgress))%")
            }
        }
        // .menuBarExtraStyle(.window) gives us a nice popover-style dropdown
        // instead of a plain NSMenu. This lets us use rich SwiftUI views inside.
        .menuBarExtraStyle(.window)
    }
}

// MARK: - Menu Bar Icon Renderer
// Renders a tiny circular progress ring as an NSImage.
// We need this because the menu bar label doesn't support
// arbitrary SwiftUI shapes — only Image and Text render reliably.

enum MenuBarIconRenderer {

    static func render(progress: Double, size: CGFloat = 16) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        let rect = NSRect(x: 1.5, y: 1.5, width: size - 3, height: size - 3)
        let lineWidth: CGFloat = 1.8

        // Draw the background track (faint ring)
        let trackPath = NSBezierPath(ovalIn: rect)
        trackPath.lineWidth = lineWidth
        NSColor.labelColor.withAlphaComponent(0.2).setStroke()
        trackPath.stroke()

        // Draw the progress arc
        // NSBezierPath angles: 0° = right (3 o'clock).
        // We want to start at top (90° in AppKit's coordinate system)
        // and sweep clockwise (negative direction in AppKit).
        let center = NSPoint(x: size / 2, y: size / 2)
        let radius = (size - 3) / 2
        let startAngle: CGFloat = 90
        let endAngle: CGFloat = 90 - (progress / 100) * 360

        let arcPath = NSBezierPath()
        arcPath.appendArc(
            withCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        arcPath.lineWidth = lineWidth
        arcPath.lineCapStyle = .round
        NSColor.labelColor.setStroke()
        arcPath.stroke()

        image.unlockFocus()
        // isTemplate = true makes the icon adapt to light/dark mode automatically,
        // just like system menu bar icons do.
        image.isTemplate = true
        return image
    }
}
