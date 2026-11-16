import FamilyControls
import ManagedSettings
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    @Published private(set) var limits: [AppLimit] = Storage.limits
    @Published private(set) var downtime: Downtime = Storage.downtime
    @Published private(set) var focus: FocusSession = Storage.focus
    @Published var errorMessage: String?

    @Published var preventAppDeletion = AppGroup.defaults.bool(forKey: "preventAppDeletion") {
        didSet {
            AppGroup.defaults.set(preventAppDeletion, forKey: "preventAppDeletion")
            Shield.guardStore.application.denyAppRemoval = preventAppDeletion ? true : nil
        }
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            errorMessage = "Screen Time access wasn't granted. \(error.localizedDescription)"
        }
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }

    /// Re-read shared state (the extension may have changed it while we were closed).
    func refresh() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        limits = Storage.limits
        downtime = Storage.downtime
        focus = Storage.focus
        if focus.endsAt != nil && !focus.isActive {
            // Safety net in case the end-of-session callback was missed.
            Scheduler.endFocus()
            focus.endsAt = nil
            Storage.save(focus, key: Storage.focusKey)
        }
    }

    // MARK: Limits

    func save(_ limit: AppLimit) {
        if let index = limits.firstIndex(where: { $0.id == limit.id }) {
            limits[index] = limit
        } else {
            limits.append(limit)
        }
        Storage.save(limits, key: Storage.limitsKey)
        Shield.clear(Shield.store(for: limit))
        run { try Scheduler.schedule(limit) }
    }

    func delete(_ limit: AppLimit) {
        limits.removeAll { $0.id == limit.id }
        Storage.save(limits, key: Storage.limitsKey)
        Scheduler.unschedule(limit)
    }

    // MARK: Downtime

    func save(_ downtime: Downtime) {
        guard minutesBetween(downtime.startMinute, downtime.endMinute) >= 15 else {
            errorMessage = "Downtime must be at least 15 minutes long."
            return
        }
        self.downtime = downtime
        Storage.save(downtime, key: Storage.downtimeKey)
        run { try Scheduler.schedule(downtime) }
    }

    private func minutesBetween(_ start: Int, _ end: Int) -> Int {
        (end - start + 24 * 60) % (24 * 60)
    }

    // MARK: Focus

    func startFocus(selection: FamilyActivitySelection, minutes: Int) {
        focus = FocusSession(selection: selection, endsAt: Date().addingTimeInterval(TimeInterval(minutes * 60)))
        Storage.save(focus, key: Storage.focusKey)
        run { try Scheduler.startFocus(focus) }
    }

    func endFocus() {
        Scheduler.endFocus()
        focus.endsAt = nil
        Storage.save(focus, key: Storage.focusKey)
    }

    func saveFocusSelection(_ selection: FamilyActivitySelection) {
        focus.selection = selection
        Storage.save(focus, key: Storage.focusKey)
    }

    private func run(_ work: () throws -> Void) {
        do { try work() } catch { errorMessage = error.localizedDescription }
    }
}
