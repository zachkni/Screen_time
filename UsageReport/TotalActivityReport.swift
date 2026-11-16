import DeviceActivity
import ManagedSettings
import SwiftUI

struct AppUsage: Identifiable {
    let id = UUID()
    let name: String
    let token: ApplicationToken?
    let duration: TimeInterval
    let pickups: Int
}

struct ActivitySummary {
    var total: TimeInterval = 0
    var pickups: Int = 0
    var apps: [AppUsage] = []
}

struct TotalActivityReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity
    let content: (ActivitySummary) -> TotalActivityView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> ActivitySummary {
        var summary = ActivitySummary()
        var byApp: [String: (token: ApplicationToken?, duration: TimeInterval, pickups: Int)] = [:]

        for await device in data {
            for await segment in device.activitySegments {
                summary.total += segment.totalActivityDuration
                for await category in segment.categories {
                    for await app in category.applications {
                        let name = app.application.localizedDisplayName
                            ?? app.application.bundleIdentifier
                            ?? "Unknown app"
                        var entry = byApp[name] ?? (app.application.token, 0, 0)
                        entry.duration += app.totalActivityDuration
                        entry.pickups += app.numberOfPickups
                        byApp[name] = entry
                        summary.pickups += app.numberOfPickups
                    }
                }
            }
        }

        summary.apps = byApp
            .map { AppUsage(name: $0.key, token: $0.value.token, duration: $0.value.duration, pickups: $0.value.pickups) }
            .filter { $0.duration >= 60 }
            .sorted { $0.duration > $1.duration }
        return summary
    }
}
