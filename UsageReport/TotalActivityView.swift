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
                        Text(format(summary.total)).font(.system(size: 40, weight: .bold, design: .rounded))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Pickups").font(.subheadline).foregroundStyle(.secondary)
                        Text("\(summary.pickups)").font(.title2.bold())
                    }
                }
                .padding(.vertical, 6)
            }

            Section("Most used") {
                if summary.apps.isEmpty {
                    Text("No app usage recorded yet today.").foregroundStyle(.secondary)
                }
                ForEach(summary.apps.prefix(15)) { app in
                    HStack {
                        if let token = app.token {
                            Label(token).labelStyle(.iconOnly)
                        }
                        VStack(alignment: .leading) {
                            Text(app.name).lineLimit(1)
                            ProgressView(value: app.duration, total: max(summary.apps.first?.duration ?? 1, 1))
                                .tint(.indigo)
                        }
                        Text(format(app.duration))
                            .font(.callout.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 60, alignment: .trailing)
                    }
                }
            }
        }
    }

    private func format(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        return minutes >= 60 ? "\(minutes / 60)h \(minutes % 60)m" : "\(minutes)m"
    }
}
