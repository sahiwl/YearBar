import SwiftUI

struct MenuBarView: View {

    @Binding var selectedMode: TimeMode
    let yearProgress: Double
    let monthProgress: Double
    let weekProgress: Double

    @State private var isCheckingUpdates = false
    @State private var showUpToDateAlert = false
    @State private var showUpdateAvailableAlert = false
    @State private var updateReleaseURL: URL?
    @State private var updateVersion: String = ""
    @State private var showLaunchAtLoginAlert = false
    @State private var launchAtLoginEnabled = LaunchAtLogin.isEnabled

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

            Button {
                isCheckingUpdates = true
                Task {
                    let result = await UpdateChecker.check()
                    await MainActor.run {
                        isCheckingUpdates = false
                        if result.hasUpdate, let url = result.releaseURL {
                            updateVersion = result.latestVersion ?? ""
                            updateReleaseURL = url
                            showUpdateAvailableAlert = true
                        } else {
                            showUpToDateAlert = true
                        }
                    }
                }
            } label: {
                HStack {
                    Text("Check for updates")
                    if isCheckingUpdates { ProgressView().scaleEffect(0.7).id(1) }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(isCheckingUpdates)

            Button {
                if launchAtLoginEnabled {
                    _ = LaunchAtLogin.disable()
                    launchAtLoginEnabled = false
                } else {
                    if LaunchAtLogin.enable() {
                        launchAtLoginEnabled = true
                        showLaunchAtLoginAlert = true
                    }
                }
            } label: {
                Text("Launch at login: \(launchAtLoginEnabled ? "On" : "Off")")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

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
        .onAppear { launchAtLoginEnabled = LaunchAtLogin.isEnabled }
        .alert("Up to date", isPresented: $showUpToDateAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You're on the latest version.")
        }
        .alert("Update available", isPresented: $showUpdateAvailableAlert) {
            Button("Open release") {
                if let url = updateReleaseURL { NSWorkspace.shared.open(url) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Version \(updateVersion) is available.")
        }
        .alert("Launch at login", isPresented: $showLaunchAtLoginAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("YearBar will open when you log in.")
        }
    }
}
