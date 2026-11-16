import SwiftUI

@main
struct ScreenTimeApp: App {
    @StateObject private var model = AppModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                .tint(.indigo)
                .onChange(of: scenePhase) { phase in
                    if phase == .active { model.refresh() }
                }
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Group {
            if model.isAuthorized {
                TabView {
                    TodayView().tabItem { Label("Today", systemImage: "chart.bar.fill") }
                    LimitsView().tabItem { Label("Limits", systemImage: "hourglass") }
                    FocusView().tabItem { Label("Focus", systemImage: "moon.stars.fill") }
                    DowntimeView().tabItem { Label("Downtime", systemImage: "bed.double.fill") }
                    SettingsView().tabItem { Label("Settings", systemImage: "gearshape.fill") }
                }
            } else {
                OnboardingView()
            }
        }
        .alert("Something went wrong", isPresented: Binding(
            get: { model.errorMessage != nil },
            set: { if !$0 { model.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}
