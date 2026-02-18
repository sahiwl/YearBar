import Foundation

enum UpdateChecker {

    private static let repo = "sahiwl/YearBar"
    private static let apiURL = URL(string: "https://api.github.com/repos/\(repo)/releases/latest")!

    static var currentVersion: String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0"
    }

    /// Returns (hasUpdate, latestVersion, releaseURL). Runs on background; call from MainActor for UI.
    static func check() async -> (hasUpdate: Bool, latestVersion: String?, releaseURL: URL?) {
        guard let (version, url) = await fetchLatest() else {
            return (false, nil, nil)
        }
        let hasUpdate = isNewer(latest: version, current: currentVersion)
        return (hasUpdate, version, url)
    }

    private static func fetchLatest() async -> (String, URL)? {
        var request = URLRequest(url: apiURL)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tag = json["tag_name"] as? String,
              let htmlURLString = json["html_url"] as? String,
              let htmlURL = URL(string: htmlURLString)
        else { return nil }
        let version = tag.hasPrefix("v") ? String(tag.dropFirst()) : tag
        return (version, htmlURL)
    }

    private static func isNewer(latest: String, current: String) -> Bool {
        let l = parseVersion(latest)
        let c = parseVersion(current)
        for i in 0..<max(l.count, c.count) {
            let a = i < l.count ? l[i] : 0
            let b = i < c.count ? c[i] : 0
            if a > b { return true }
            if a < b { return false }
        }
        return false
    }

    private static func parseVersion(_ s: String) -> [Int] {
        s.split(separator: ".").compactMap { Int($0) }
    }
}
