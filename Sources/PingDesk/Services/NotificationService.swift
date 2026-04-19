import Foundation
import UserNotifications

final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    static let oneTimeFiredNotification = Notification.Name("PingDeskOneTimeFired")

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func schedule(_ reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "PingDesk"
        content.body = reminder.title
        if let soundName = reminder.soundName {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
        } else {
            content.sound = .default
        }

        let trigger = makeTrigger(for: reminder.schedule)
        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func cancel(id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [id.uuidString]
        )
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func makeTrigger(for schedule: Schedule) -> UNNotificationTrigger {
        switch schedule {
        case .recurring(let frequency, let weekday, let dayOfMonth, let time):
            var components = DateComponents()
            components.hour = time.hour
            components.minute = time.minute
            switch frequency {
            case .daily:
                break
            case .weekly:
                components.weekday = weekday
            case .monthly:
                components.day = dayOfMonth
            }
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        case .oneTime(let date):
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: date
            )
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        }
    }

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
        completionHandler([.banner, .sound])
    }
}
