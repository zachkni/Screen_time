import Foundation

/// The app and its extensions run in separate processes. They share settings
/// through an App Group container whose ID comes from Info.plist (set in project.yml).
enum AppGroup {
    static let id: String =
        Bundle.main.object(forInfoDictionaryKey: "AppGroupID") as? String
        ?? "group.com.yourname.screentime"

    static let defaults: UserDefaults = UserDefaults(suiteName: id) ?? .standard
}

enum Storage {
    static let limitsKey = "limits"
    static let downtimeKey = "downtime"
    static let focusKey = "focus"

    static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = AppGroup.defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    static func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        AppGroup.defaults.set(data, forKey: key)
    }

    static var limits: [AppLimit] { load([AppLimit].self, key: limitsKey) ?? [] }
    static var downtime: Downtime { load(Downtime.self, key: downtimeKey) ?? Downtime() }
    static var focus: FocusSession { load(FocusSession.self, key: focusKey) ?? FocusSession() }
}
