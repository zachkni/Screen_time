import FamilyControls
import SwiftUI

struct DowntimeView: View {
    @EnvironmentObject private var model: AppModel
    @State private var draft = Downtime()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Downtime", isOn: $draft.isEnabled)
                } footer: {
                    Text("During downtime every app is blocked except the ones you allow below. Phone and Settings always work.")
                }
                Section("Schedule (every day)") {
                    DatePicker("From", selection: timeBinding(\.startMinute), displayedComponents: .hourAndMinute)
                    DatePicker("Until", selection: timeBinding(\.endMinute), displayedComponents: .hourAndMinute)
                }
                Section("Always allowed") {
                    SelectionRow(title: "Allowed apps", selection: $draft.allowed)
                }
                Section {
                    Button("Save") { model.save(draft) }
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .disabled(draft == model.downtime)
                }
            }
            .navigationTitle("Downtime")
            .onAppear { draft = model.downtime }
        }
    }

    /// Bridges "minutes after midnight" to a Date for DatePicker.
    private func timeBinding(_ keyPath: WritableKeyPath<Downtime, Int>) -> Binding<Date> {
        Binding(
            get: {
                let minutes = draft[keyPath: keyPath]
                return Calendar.current.date(
                    bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: Date()
                ) ?? Date()
            },
            set: { date in
                let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                draft[keyPath: keyPath] = (c.hour ?? 0) * 60 + (c.minute ?? 0)
            }
        )
    }
}
