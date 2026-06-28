import Testing
@testable import PingDeskCore
import Foundation

@Suite struct ReminderTests {
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    @Test func reminderRoundtrip() throws {
        let original = Reminder(
            title: "Stand-up meeting",
            schedule: .recurring(
                frequency: .daily,
                weekdays: [],
                dayOfMonth: nil,
                time: makeTime(hour: 9, minute: 30)
            ),
            soundName: "Ping",
            isEnabled: true
        )

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(Reminder.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.title == original.title)
        #expect(decoded.soundName == original.soundName)
        #expect(decoded.isEnabled == original.isEnabled)
        #expect(decoded.schedule == original.schedule)
    }

    @Test func reminderDefaultsToEnabled() {
        let reminder = Reminder(title: "Test", schedule: .oneTime(date: Date()))
        #expect(reminder.isEnabled)
    }

    @Test func reminderWithNoSound() throws {
        let original = Reminder(title: "Silent", schedule: .oneTime(date: Date()), soundName: nil)
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(Reminder.self, from: data)
        #expect(decoded.soundName == nil)
    }

    private func makeTime(hour: Int, minute: Int) -> DateComponents {
        var c = DateComponents()
        c.hour = hour
        c.minute = minute
        return c
    }
}
