import DeviceActivity
import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var model: AppModel
    @State private var filter = TodayView.makeFilter()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if model.focus.isActive, let endsAt = model.focus.endsAt {
                    HStack {
                        Image(systemName: "moon.stars.fill")
                        Text("Focus on until \(endsAt.formatted(date: .omitted, time: .shortened))")
                        Spacer()
                    }
                    .font(.subheadline.weight(.medium))
                    .padding()
                    .background(.indigo.opacity(0.15))
                }
                // Rendered by the UsageReport extension. Apple keeps the data inside it.
                DeviceActivityReport(.totalActivity, filter: filter)
            }
            .navigationTitle("Today")
            .toolbar {
                Button { filter = TodayView.makeFilter() } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }

    static func makeFilter() -> DeviceActivityFilter {
        let now = Date()
        let start = Calendar.current.startOfDay(for: now)
        return DeviceActivityFilter(
            segment: .daily(during: DateInterval(start: start, end: now)),
            users: .all,
            devices: .init([.iPhone, .iPad])
        )
    }
}
