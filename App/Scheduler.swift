import DeviceActivity
import FamilyControls
import Foundation

/// Registers background schedules with iOS. iOS then wakes the ActivityMonitor
/// extension at the right times, even if this app is never opened again.
enum Scheduler {
    static let center = DeviceActivityCenter()

    // MARK: Daily limits

    static func schedule(_ limit: AppLimit) throws {
        center.stopMonitoring([limit.activityName])
        guard limit.isEnabled, !limit.selection.isEmpty else { return }

        let wholeDay = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        let event: DeviceActivityEvent
        if #available(iOS 17.4, *) {
            // Count usage from earlier today too, so editing a limit doesn't reset it.
            event = DeviceActivityEvent(
                applications: limit.selection.applicationTokens,
                categories: limit.selection.categoryTokens,
                webDomains: limit.selection.webDomainTokens,
                threshold: DateComponents(minute: limit.minutes),
                includesPastActivity: true
            )
        } else {
            event = DeviceActivityEvent(
                applications: limit.selection.applicationTokens,
                categories: limit.selection.categoryTokens,
                webDomains: limit.selection.webDomainTokens,
                threshold: DateComponents(minute: limit.minutes)
            )
        }

        try center.startMonitoring(limit.activityName, during: wholeDay, events: [limit.eventName: event])
    }

    static func unschedule(_ limit: AppLimit) {
        center.stopMonitoring([limit.activityName])
        Shield.clear(Shield.store(for: limit))
    }

    // MARK: Downtime

    static func schedule(_ downtime: Downtime) throws {
        center.stopMonitoring([ActivityNames.downtime])
        Shield.clear(Shield.downtimeStore)
        guard downtime.isEnabled else { return }

        try center.startMonitoring(
            ActivityNames.downtime,
            during: DeviceActivitySchedule(
                intervalStart: downtime.startComponents,
                intervalEnd: downtime.endComponents,
                repeats: true
            )
        )
        if isNowInside(start: downtime.startMinute, end: downtime.endMinute) {
            Shield.blockEverything(except: downtime.allowed, in: Shield.downtimeStore)
        }
    }

    static func isNowInside(start: Int, end: Int) -> Bool {
        let c = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let now = (c.hour ?? 0) * 60 + (c.minute ?? 0)
        return start <= end ? (now >= start && now < end) : (now >= start || now < end)
    }

    // MARK: Focus sessions

    static func startFocus(_ focus: FocusSession) throws {
        guard let endsAt = focus.endsAt else { return }
        center.stopMonitoring([ActivityNames.focus])
        Shield.block(focus.selection, in: Shield.focusStore)

        let calendar = Calendar.current
        let parts: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        try center.startMonitoring(
            ActivityNames.focus,
            during: DeviceActivitySchedule(
                intervalStart: calendar.dateComponents(parts, from: Date()),
                intervalEnd: calendar.dateComponents(parts, from: endsAt),
                repeats: false
            )
        )
    }

    static func endFocus() {
        center.stopMonitoring([ActivityNames.focus])
        Shield.clear(Shield.focusStore)
    }
}
