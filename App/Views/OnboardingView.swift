import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var model: AppModel
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "hourglass.circle.fill")
                .font(.system(size: 88))
                .foregroundStyle(.indigo)
            Text("Take back your time")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            VStack(alignment: .leading, spacing: 14) {
                feature("hourglass", "Daily limits", "Block apps once you've used them for too long.")
                feature("moon.stars", "Focus sessions", "Block distractions right now for a set time.")
                feature("bed.double", "Downtime", "Lock the phone down overnight.")
                feature("lock.shield", "Private", "Everything stays on this phone. No account, no fees.")
            }
            .padding(.horizontal)
            Spacer()
            Button {
                isRequesting = true
                Task {
                    await model.requestAuthorization()
                    isRequesting = false
                }
            } label: {
                Group {
                    if isRequesting { ProgressView() } else { Text("Allow Screen Time Access") }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRequesting)
            Text("iOS will ask you to confirm with Face ID or your passcode.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(24)
    }

    private func feature(_ icon: String, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.indigo)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}
