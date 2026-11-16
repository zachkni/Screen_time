import DeviceActivity
import SwiftUI

/// Apple only lets usage data be read inside this sandboxed extension;
/// the main app embeds its output with `DeviceActivityReport`.
@main
struct UsageReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        TotalActivityReport { summary in
            TotalActivityView(summary: summary)
        }
    }
}
