import FamilyControls
import SwiftUI

struct LimitsView: View {
    @EnvironmentObject private var model: AppModel
    @State private var editing: AppLimit?

    var body: some View {
        NavigationStack {
            List {
                if model.limits.isEmpty {
                    ContentUnavailableHint(
                        icon: "hourglass",
                        title: "No limits yet",
                        message: "Add a daily limit, e.g. 30 minutes of social media. Once you've used it up, those apps are blocked until midnight."
                    )
                }
                ForEach(model.limits) { limit in
                    Button { editing = limit } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(limit.name).font(.headline).foregroundStyle(.primary)
                                Text("\(formatMinutes(limit.minutes)) a day · \(limit.selection.summary)")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if !limit.isEnabled {
                                Text("Off").font(.caption.bold()).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete { offsets in
                    offsets.map { model.limits[$0] }.forEach(model.delete)
                }
            }
            .navigationTitle("Daily Limits")
            .toolbar {
                Button { editing = AppLimit() } label: { Image(systemName: "plus") }
            }
            .sheet(item: $editing) { limit in
                LimitEditor(limit: limit, isNew: !model.limits.contains { $0.id == limit.id })
            }
        }
    }
}

struct LimitEditor: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State var limit: AppLimit
    let isNew: Bool

    private let presets = [5, 15, 30, 45, 60, 90, 120, 180, 240]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $limit.name)
                    Toggle("Enabled", isOn: $limit.isEnabled)
                }
                Section("Apps, categories & websites") {
                    SelectionRow(title: "Choose", selection: $limit.selection)
                }
                Section {
                    Stepper(value: $limit.minutes, in: 1...720, step: limit.minutes < 15 ? 1 : 5) {
                        Text(formatMinutes(limit.minutes)).font(.title3.monospacedDigit())
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(presets, id: \.self) { m in
                                Button(formatMinutes(m)) { limit.minutes = m }
                                    .buttonStyle(.bordered)
                                    .tint(limit.minutes == m ? .indigo : .gray)
                            }
                        }
                    }
                } header: {
                    Text("Time allowed per day")
                } footer: {
                    Text("When the time is used up, these are blocked until midnight.")
                }
                if !isNew {
                    Section {
                        Button("Delete Limit", role: .destructive) {
                            model.delete(limit)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(isNew ? "New Limit" : "Edit Limit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        model.save(limit)
                        dismiss()
                    }
                    .disabled(limit.selection.isEmpty || limit.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

func formatMinutes(_ minutes: Int) -> String {
    if minutes < 60 { return "\(minutes) min" }
    let h = minutes / 60, m = minutes % 60
    return m == 0 ? "\(h) hr" : "\(h) hr \(m) min"
}

/// Small empty-state view that also works on iOS 16.
struct ContentUnavailableHint: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon).font(.largeTitle).foregroundStyle(.secondary)
            Text(title).font(.headline)
            Text(message).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .listRowBackground(Color.clear)
    }
}
