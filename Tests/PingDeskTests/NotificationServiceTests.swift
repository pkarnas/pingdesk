import Testing
@testable import PingDeskCore
import Foundation

@Suite struct NotificationServiceTests {
    private let service = NotificationService.shared
    private let now = Date()

    @Test func dailyFiresInFuture() {
        let date = service.nextFireDate(
            frequency: .daily,
            weekdays: [],
            dayOfMonth: nil,
            time: makeTime(hour: 9, minute: 0)
        )
        #expect(date != nil)
        #expect(date! > now)
    }

    @Test func dailyHasCorrectTime() {
        let date = service.nextFireDate(
            frequency: .daily,
            weekdays: [],
            dayOfMonth: nil,
            time: makeTime(hour: 14, minute: 30)
        )
        guard let date else {
            Issue.record("Expected non-nil date")
            return
        }
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        #expect(components.hour == 14)
        #expect(components.minute == 30)
    }

    @Test func selectedDaysSingleDayFiresInFuture() {
        let date = service.nextFireDate(
            frequency: .selectedDays,
            weekdays: [2],
            dayOfMonth: nil,
            time: makeTime(hour: 9, minute: 0)
        )
        #expect(date != nil)
        #expect(date! > now)
    }

    @Test func selectedDaysMultipleDaysPicksSoonest() {
        let time = makeTime(hour: 9, minute: 0)

        guard
            let mondayDate = service.nextFireDate(frequency: .selectedDays, weekdays: [2], dayOfMonth: nil, time: time),
            let fridayDate = service.nextFireDate(frequency: .selectedDays, weekdays: [6], dayOfMonth: nil, time: time),
            let combinedDate = service.nextFireDate(frequency: .selectedDays, weekdays: [2, 6], dayOfMonth: nil, time: time)
        else {
            Issue.record("Expected non-nil dates for all three queries")
            return
        }

        let expected = min(mondayDate, fridayDate)
        #expect(abs(combinedDate.timeIntervalSince(expected)) < 1)
    }

    @Test func selectedDaysAllDaysEquivalentToDaily() {
        let time = makeTime(hour: 9, minute: 0)

        guard
            let allDaysDate = service.nextFireDate(frequency: .selectedDays, weekdays: Array(1...7), dayOfMonth: nil, time: time),
            let dailyDate = service.nextFireDate(frequency: .daily, weekdays: [], dayOfMonth: nil, time: time)
        else {
            Issue.record("Expected non-nil dates")
            return
        }

        #expect(abs(allDaysDate.timeIntervalSince(dailyDate)) < 1)
    }

    @Test func selectedDaysEmptyReturnsNil() {
        let date = service.nextFireDate(
            frequency: .selectedDays,
            weekdays: [],
            dayOfMonth: nil,
            time: makeTime(hour: 9, minute: 0)
        )
        #expect(date == nil)
    }

    @Test func monthlyFiresInFuture() {
        let date = service.nextFireDate(
            frequency: .monthly,
            weekdays: [],
            dayOfMonth: 15,
            time: makeTime(hour: 10, minute: 0)
        )
        #expect(date != nil)
        #expect(date! > now)
    }

    @Test func monthlyHasCorrectDayOfMonth() {
        let date = service.nextFireDate(
            frequency: .monthly,
            weekdays: [],
            dayOfMonth: 15,
            time: makeTime(hour: 10, minute: 0)
        )
        guard let date else {
            Issue.record("Expected non-nil date")
            return
        }
        let day = Calendar.current.component(.day, from: date)
        #expect(day == 15)
    }

    private func makeTime(hour: Int, minute: Int) -> DateComponents {
        var c = DateComponents()
        c.hour = hour
        c.minute = minute
        return c
    }
}
