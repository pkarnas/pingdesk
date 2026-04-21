import AppKit
import Foundation
import UserNotifications

final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    static let oneTimeFiredNotification = Notification.Name("PingDeskOneTimeFired")

    private var timers: [UUID: Timer] = [:]

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func schedule(_ reminder: Reminder) {
        cancel(id: reminder.id)

        switch reminder.schedule {
        case .oneTime(let date):
            scheduleTimer(id: reminder.id, title: reminder.title, soundName: reminder.soundName, fireDate: date)
        case .recurring(let frequency, let weekday, let dayOfMonth, let time):
            if let nextFire = nextFireDate(frequency: frequency, weekday: weekday, dayOfMonth: dayOfMonth, time: time) {
                scheduleTimer(id: reminder.id, title: reminder.title, soundName: reminder.soundName, fireDate: nextFire, recurring: true, schedule: reminder.schedule)
            }
        }
    }

    func cancel(id: UUID) {
        timers[id]?.invalidate()
        timers.removeValue(forKey: id)
    }

    func cancelAll() {
        timers.values.forEach { $0.invalidate() }
        timers.removeAll()
    }

    // MARK: - Timer scheduling

    private func scheduleTimer(id: UUID, title: String, soundName: String?, fireDate: Date, recurring: Bool = false, schedule: Schedule? = nil) {
        guard fireDate.timeIntervalSinceNow > 0 else { return }

        let timer = Timer(fire: fireDate, interval: 0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                NotificationPanelController.shared.show(
                    id: id,
                    title: "PingDesk",
                    message: title,
                    soundName: soundName
                )
            }

            // For recurring reminders, schedule the next occurrence
            if recurring, let schedule = schedule,
               case .recurring(let frequency, let weekday, let dayOfMonth, let time) = schedule,
               let nextFire = self?.nextFireDate(frequency: frequency, weekday: weekday, dayOfMonth: dayOfMonth, time: time) {
                self?.scheduleTimer(id: id, title: title, soundName: soundName, fireDate: nextFire, recurring: true, schedule: schedule)
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        timers[id] = timer
    }

    private func nextFireDate(frequency: Frequency, weekday: Int?, dayOfMonth: Int?, time: DateComponents) -> Date? {
        let calendar = Calendar.current
        let now = Date()

        var components = DateComponents()
        components.hour = time.hour
        components.minute = time.minute

        switch frequency {
        case .daily:
            guard let next = calendar.nextDate(after: now.addingTimeInterval(-1), matching: components, matchingPolicy: .nextTime) else { return nil }
            return next
        case .weekly:
            components.weekday = weekday
            guard let next = calendar.nextDate(after: now.addingTimeInterval(-1), matching: components, matchingPolicy: .nextTime) else { return nil }
            return next
        case .monthly:
            components.day = dayOfMonth
            guard let next = calendar.nextDate(after: now.addingTimeInterval(-1), matching: components, matchingPolicy: .nextTime) else { return nil }
            return next
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        if let uuid = UUID(uuidString: identifier) {
            NotificationCenter.default.post(
                name: NotificationService.oneTimeFiredNotification,
                object: uuid
            )
        }
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Suppress native banner — our panel is shown via timer
        completionHandler([])
    }
}
