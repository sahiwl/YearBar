//
//  YearBarApp.swift
//  YearBar
//
//  Created by Sahil Kumar Ray on 17/02/26.
//

import SwiftUI

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
    // (The _ = means "I don't need to read this variable, just keep it around.")
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some Scene {
        // MenuBarExtra is the magic API (macOS 13+) that puts your app
        // in the menu bar instead of opening a window.
        //
        // First argument: the text shown IN the menu bar itself.
        // We format the percentage to 2 decimal places.
        //
        // The trailing closure is what appears in the DROPDOWN when you click it.
        MenuBarExtra("\(String(format: "%.2f", yearProgress))%") {
            MenuBarView()
                // .onReceive listens to a Publisher (here, our timer).
                // Every time the timer fires, we recalculate the year progress.
                .onReceive(timer) { _ in
                    yearProgress = TimeCalculator.yearProgress()
                }
        }
        // .menuBarExtraStyle(.window) gives us a nice popover-style dropdown
        // instead of a plain NSMenu. This lets us use rich SwiftUI views inside.
        .menuBarExtraStyle(.window)
    }
}
