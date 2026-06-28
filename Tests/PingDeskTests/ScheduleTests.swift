import Testing
@testable import PingDeskCore
import Foundation

@Suite struct ScheduleTests {
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

    @Test func dailyRoundtrip() throws {
        let schedule = Schedule.recurring(
            frequency: .daily,
            weekdays: [],
            dayOfMonth: nil,
            time: makeTime(hour: 8, minute: 0)
        )
        #expect(try roundtrip(schedule) == schedule)
    }

    @Test func selectedDaysSingleDayRoundtrip() throws {
        let schedule = Schedule.recurring(
            frequency: .selectedDays,
            weekdays: [2],
            dayOfMonth: nil,
            time: makeTime(hour: 9, minute: 0)
        )
        #expect(try roundtrip(schedule) == schedule)
    }

    @Test func selectedDaysMultipleDaysRoundtrip() throws {
        let schedule = Schedule.recurring(
            frequency: .selectedDays,
            weekdays: [2, 4, 6],
            dayOfMonth: nil,
            time: makeTime(hour: 9, minute: 0)
        )
        let decoded = try roundtrip(schedule)
        #expect(decoded == schedule)

        guard case .recurring(_, let weekdays, _, _) = decoded else {
            Issue.record("Expected recurring schedule")
            return
        }
        #expect(weekdays == [2, 4, 6])
    }

    @Test func monthlyRoundtrip() throws {
        let schedule = Schedule.recurring(
            frequency: .monthly,
            weekdays: [],
            dayOfMonth: 15,
            time: makeTime(hour: 10, minute: 0)
        )
        #expect(try roundtrip(schedule) == schedule)
    }

    @Test func oneTimeRoundtrip() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let schedule = Schedule.oneTime(date: date)
        #expect(try roundtrip(schedule) == schedule)
    }

    @Test func weekdaysEmptyForDaily() throws {
        let schedule = Schedule.recurring(
            frequency: .daily,
            weekdays: [],
            dayOfMonth: nil,
            time: makeTime(hour: 7, minute: 30)
        )
        let decoded = try roundtrip(schedule)
        guard case .recurring(_, let weekdays, _, _) = decoded else {
            Issue.record("Expected recurring schedule")
            return
        }
        #expect(weekdays.isEmpty)
    }

    @Test func selectedDaysAllSevenDays() throws {
        let allDays = Array(1...7)
        let schedule = Schedule.recurring(
            frequency: .selectedDays,
            weekdays: allDays,
            dayOfMonth: nil,
            time: makeTime(hour: 12, minute: 0)
        )
        let decoded = try roundtrip(schedule)
        guard case .recurring(_, let weekdays, _, _) = decoded else {
            Issue.record("Expected recurring schedule")
            return
        }
        #expect(weekdays == allDays)
    }

    private func roundtrip(_ schedule: Schedule) throws -> Schedule {
        let data = try encoder.encode(schedule)
        return try decoder.decode(Schedule.self, from: data)
    }

    private func makeTime(hour: Int, minute: Int) -> DateComponents {
        var c = DateComponents()
        c.hour = hour
        c.minute = minute
        return c
    }
}
