import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Block deleting apps", isOn: $model.preventAppDeletion)
                } header: {
                    Text("Make it harder to cheat")
                } footer: {
                    Text("Stops any app (including this one) from being deleted, so you can't uninstall your way around a limit. Turn this off before deleting apps.")
                }
                Section {
                    Text("To make limits harder to bypass, ask someone you trust to set a Screen Time passcode in Settings ▸ Screen Time ▸ Lock Screen Time Settings. That passcode is then needed to remove this app's access.")
                        .font(.subheadline)
                } header: {
                    Text("Extra strictness")
                }
                Section("About") {
                    LabeledContent("Data", value: "Stays on this device")
                    LabeledContent("Cost", value: "Free, forever")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
