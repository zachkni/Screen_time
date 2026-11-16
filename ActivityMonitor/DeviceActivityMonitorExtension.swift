import DeviceActivity
import ManagedSettings
import Foundation

/// iOS wakes this extension in the background when a schedule starts or ends,
/// or when an app limit's time threshold is reached. It works even when the
/// main app is closed.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        if activity == ActivityNames.downtime {
            let downtime = Storage.downtime
            if downtime.isEnabled {
                Shield.blockEverything(except: downtime.allowed, in: Shield.downtimeStore)
            }
        } else if activity == ActivityNames.focus {
            let focus = Storage.focus
            if focus.isActive {
                Shield.block(focus.selection, in: Shield.focusStore)
            }
        } else if let limit = limit(named: activity.rawValue) {
            // A new day has started: lift yesterday's block.
            Shield.clear(Shield.store(for: limit))
        }
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        if activity == ActivityNames.downtime {
            Shield.clear(Shield.downtimeStore)
        } else if activity == ActivityNames.focus {
            Shield.clear(Shield.focusStore)
            var focus = Storage.focus
            focus.endsAt = nil
            Storage.save(focus, key: Storage.focusKey)
        } else if let limit = limit(named: activity.rawValue) {
            Shield.clear(Shield.store(for: limit))
        }
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)

        // The daily limit has been used up: block those apps until midnight.
        guard let limit = limit(named: event.rawValue), limit.isEnabled else { return }
        Shield.block(limit.selection, in: Shield.store(for: limit))
    }

    private func limit(named key: String) -> AppLimit? {
        guard key.hasPrefix(ActivityNames.limitPrefix) else { return nil }
        return Storage.limits.first { $0.key == key }
    }
}
