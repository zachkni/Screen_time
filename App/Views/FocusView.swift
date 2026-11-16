import FamilyControls
import SwiftUI

struct FocusView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selection = FamilyActivitySelection()
    @State private var minutes = 30
    @State private var confirmEnd = false

    private let durations = [15, 30, 45, 60, 90, 120, 180, 240]

    var body: some View {
        NavigationStack {
            Form {
                if model.focus.isActive, let endsAt = model.focus.endsAt {
                    Section {
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            VStack(spacing: 8) {
                                Text("Focus in progress").font(.headline).foregroundStyle(.secondary)
                                Text(remaining(until: endsAt, now: context.date))
                                    .font(.system(size: 56, weight: .bold, design: .rounded).monospacedDigit())
                                Text("Blocking \(model.focus.selection.summary)")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                        }
                    }
                    Section {
                        Button("End Focus Early", role: .destructive) { confirmEnd = true }
                    }
                } else {
                    Section {
                        SelectionRow(title: "Apps to block", selection: $selection)
                    } footer: {
                        Text("Tip: pick whole categories like Social or Games to catch everything.")
                    }
                    Section("How long?") {
                        Picker("Duration", selection: $minutes) {
                            ForEach(durations, id: \.self) { Text(formatMinutes($0)).tag($0) }
                        }
                        .pickerStyle(.wheel)
                    }
                    Section {
                        Button {
                            model.saveFocusSelection(selection)
                            model.startFocus(selection: selection, minutes: minutes)
                        } label: {
                            Label("Start Focus", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                                .font(.headline)
                        }
                        .disabled(selection.isEmpty)
                    }
                }
            }
            .navigationTitle("Focus")
            .onAppear { selection = model.focus.selection }
            .confirmationDialog("End focus early?", isPresented: $confirmEnd, titleVisibility: .visible) {
                Button("End Focus", role: .destructive) { model.endFocus() }
            } message: {
                Text("Your future self might be disappointed.")
            }
        }
    }

    private func remaining(until end: Date, now: Date) -> String {
        let seconds = max(0, Int(end.timeIntervalSince(now)))
        let h = seconds / 3600, m = (seconds % 3600) / 60, s = seconds % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
    }
}
