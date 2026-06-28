import Testing
@testable import PingDeskCore
import Foundation

@Suite struct ReminderStoreTests {
    @Test func emptyStoreHasNoReminders() {
        let store = makeStore()
        #expect(store.reminders.isEmpty)
    }

    @Test func addedReminderPersistsAfterReload() {
        let url = tempURL()
        let store = ReminderStore(fileURL: url)
        let reminder = Reminder(
            title: "Test reminder",
            schedule: .recurring(
                frequency: .daily,
                weekdays: [],
                dayOfMonth: nil,
                time: makeTime(hour: 9, minute: 0)
            )
        )
        store.add(reminder)

        let store2 = ReminderStore(fileURL: url)
        #expect(store2.reminders.count == 1)
        #expect(store2.reminders.first?.id == reminder.id)
        #expect(store2.reminders.first?.title == reminder.title)
    }

    @Test func selectedDaysReminderPersists() {
        let url = tempURL()
        let store = ReminderStore(fileURL: url)
        let reminder = Reminder(
            title: "Mon/Wed/Fri standup",
            schedule: .recurring(
                frequency: .selectedDays,
                weekdays: [2, 4, 6],
                dayOfMonth: nil,
                time: makeTime(hour: 10, minute: 0)
            )
        )
        store.add(reminder)

        let store2 = ReminderStore(fileURL: url)
        guard let loaded = store2.reminders.first else {
            Issue.record("Expected one reminder")
            return
        }
        guard case .recurring(let frequency, let weekdays, _, _) = loaded.schedule else {
            Issue.record("Expected recurring schedule")
            return
        }
        #expect(frequency == .selectedDays)
        #expect(weekdays == [2, 4, 6])
    }

    @Test func deleteReminder() {
        let url = tempURL()
        let store = ReminderStore(fileURL: url)
        let reminder = Reminder(title: "To delete", schedule: .oneTime(date: Date().addingTimeInterval(3600)))
        store.add(reminder)
        #expect(store.reminders.count == 1)

        store.delete(reminder)
        #expect(store.reminders.isEmpty)

        let store2 = ReminderStore(fileURL: url)
        #expect(store2.reminders.isEmpty)
    }

    @Test func updateReminder() {
        let url = tempURL()
        let store = ReminderStore(fileURL: url)
        let reminder = Reminder(title: "Original", schedule: .oneTime(date: Date().addingTimeInterval(3600)))
        store.add(reminder)

        var updated = reminder
        updated.title = "Updated"
        store.update(updated)

        let store2 = ReminderStore(fileURL: url)
        #expect(store2.reminders.first?.title == "Updated")
    }

    @Test func multipleRemindersPersist() {
        let url = tempURL()
        let store = ReminderStore(fileURL: url)
        let reminders = (1...5).map { i in
            Reminder(
                title: "Reminder \(i)",
                schedule: .recurring(
                    frequency: .daily,
                    weekdays: [],
                    dayOfMonth: nil,
                    time: makeTime(hour: i, minute: 0)
                )
            )
        }
        reminders.forEach { store.add($0) }

        let store2 = ReminderStore(fileURL: url)
        #expect(store2.reminders.count == 5)
    }

    private func makeStore() -> ReminderStore {
        ReminderStore(fileURL: tempURL())
    }

    private func tempURL() -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("test-reminders.json")
    }

    private func makeTime(hour: Int, minute: Int) -> DateComponents {
        var c = DateComponents()
        c.hour = hour
        c.minute = minute
        return c
    }
}
