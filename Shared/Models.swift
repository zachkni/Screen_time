import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

/// Names of the background schedules registered with iOS.
enum ActivityNames {
    static let downtime = DeviceActivityName("downtime")
    static let focus = DeviceActivityName("focus")
    static let limitPrefix = "limit."
}

/// A daily time limit for a group of apps, categories and websites.
struct AppLimit: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String = "New limit"
    var minutes: Int = 60
    var selection = FamilyActivitySelection()
    var isEnabled = true

    var key: String { ActivityNames.limitPrefix + id.uuidString }
    var activityName: DeviceActivityName { DeviceActivityName(key) }
    var eventName: DeviceActivityEvent.Name { DeviceActivityEvent.Name(key) }
    var storeName: ManagedSettingsStore.Name { ManagedSettingsStore.Name(key) }
}

/// A nightly window where everything is blocked except an allow-list.
struct Downtime: Codable, Equatable {
    var isEnabled = false
    /// Minutes after midnight.
    var startMinute = 22 * 60
    var endMinute = 7 * 60
    var allowed = FamilyActivitySelection()

    var startComponents: DateComponents { DateComponents(hour: startMinute / 60, minute: startMinute % 60) }
    var endComponents: DateComponents { DateComponents(hour: endMinute / 60, minute: endMinute % 60) }
}

/// A one-off "block these apps for N minutes" session.
struct FocusSession: Codable, Equatable {
    var selection = FamilyActivitySelection()
    var endsAt: Date?

    var isActive: Bool {
        guard let endsAt else { return false }
        return endsAt > Date()
    }
}

extension FamilyActivitySelection {
    var isEmpty: Bool {
        applicationTokens.isEmpty && categoryTokens.isEmpty && webDomainTokens.isEmpty
    }

    var summary: String {
        var parts: [String] = []
        if !applicationTokens.isEmpty { parts.append("\(applicationTokens.count) app\(applicationTokens.count == 1 ? "" : "s")") }
        if !categoryTokens.isEmpty { parts.append("\(categoryTokens.count) categor\(categoryTokens.count == 1 ? "y" : "ies")") }
        if !webDomainTokens.isEmpty { parts.append("\(webDomainTokens.count) site\(webDomainTokens.count == 1 ? "" : "s")") }
        return parts.isEmpty ? "Nothing selected" : parts.joined(separator: ", ")
    }
}
