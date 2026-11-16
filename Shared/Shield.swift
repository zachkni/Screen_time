import Foundation
import FamilyControls
import ManagedSettings

/// Applies and removes blocks. Each feature uses its own named store so they
/// don't overwrite each other; iOS combines all stores (most restrictive wins).
enum Shield {
    static let downtimeStore = ManagedSettingsStore(named: .init("downtime"))
    static let focusStore = ManagedSettingsStore(named: .init("focus"))
    static let guardStore = ManagedSettingsStore(named: .init("guard"))

    static func store(for limit: AppLimit) -> ManagedSettingsStore {
        ManagedSettingsStore(named: limit.storeName)
    }

    /// Block exactly the apps / categories / sites in `selection`.
    static func block(_ selection: FamilyActivitySelection, in store: ManagedSettingsStore) {
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
        store.shield.webDomainCategories = selection.categoryTokens.isEmpty
            ? nil : .specific(selection.categoryTokens)
    }

    /// Block everything except the apps / sites in `allowed`.
    /// (iOS never blocks Phone, Settings or this app itself.)
    static func blockEverything(except allowed: FamilyActivitySelection, in store: ManagedSettingsStore) {
        store.shield.applicationCategories = .all(except: allowed.applicationTokens)
        store.shield.webDomainCategories = .all(except: allowed.webDomainTokens)
    }

    static func clear(_ store: ManagedSettingsStore) {
        store.clearAllSettings()
    }
}
