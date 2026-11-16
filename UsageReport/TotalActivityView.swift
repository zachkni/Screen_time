import ManagedSettings
import SwiftUI

struct TotalActivityView: View {
    let summary: ActivitySummary

    var body: some View {
        List {
            Section {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Screen time today").font(.subheadline).foregroundStyle(.secondary)
                        Text(formatDuration(summary.total)).font(.system(size: 40, weight: .bold, design: .rounded))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Pickups").font(.subheadline).foregroundStyle(.secondary)
                        Text("\(summary.pickups)").font(.title2.bold())
                    }
                }
                .padding(.vertical, 6)
            }

            Section {
                if summary.apps.isEmpty {
                    Text("No app usage recorded yet today.").foregroundStyle(.secondary)
                } else {
                    let top = max(summary.apps[0].duration, 1)
                    ForEach(Array(summary.apps.prefix(15))) { app in
                        AppUsageRow(app: app, maxDuration: top)
                    }
                }
            } header: {
                Text("Most used")
            }
        }
    }
}

struct AppUsageRow: View {
    let app: AppUsage
    let maxDuration: TimeInterval

    var body: some View {
        HStack {
            if let token = app.token {
                Label(token).labelStyle(.iconOnly)
            }
            VStack(alignment: .leading) {
                Text(app.name).lineLimit(1)
                ProgressView(value: min(app.duration, maxDuration), total: maxDuration)
                    .tint(.indigo)
            }
            Text(formatDuration(app.duration))
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(minWidth: 60, alignment: .trailing)
        }
    }
}

func formatDuration(_ interval: TimeInterval) -> String {
    let minutes = Int(interval / 60)
    return minutes >= 60 ? "\(minutes / 60)h \(minutes % 60)m" : "\(minutes)m"
}
