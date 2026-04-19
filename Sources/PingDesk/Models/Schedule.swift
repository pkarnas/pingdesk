import Foundation

enum Frequency: String, Codable, CaseIterable {
    case daily
    case weekly
    case monthly
}

enum Schedule: Codable, Hashable {
    case recurring(frequency: Frequency, weekday: Int?, dayOfMonth: Int?, time: DateComponents)
    case oneTime(date: Date)

    private enum CodingKeys: String, CodingKey {
        case type, frequency, weekday, dayOfMonth, time, date
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .recurring(let frequency, let weekday, let dayOfMonth, let time):
            try container.encode("recurring", forKey: .type)
            try container.encode(frequency, forKey: .frequency)
            try container.encodeIfPresent(weekday, forKey: .weekday)
            try container.encodeIfPresent(dayOfMonth, forKey: .dayOfMonth)
            try container.encode(time, forKey: .time)
        case .oneTime(let date):
            try container.encode("oneTime", forKey: .type)
            try container.encode(date, forKey: .date)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "recurring":
            let frequency = try container.decode(Frequency.self, forKey: .frequency)
            let weekday = try container.decodeIfPresent(Int.self, forKey: .weekday)
            let dayOfMonth = try container.decodeIfPresent(Int.self, forKey: .dayOfMonth)
            let time = try container.decode(DateComponents.self, forKey: .time)
            self = .recurring(frequency: frequency, weekday: weekday, dayOfMonth: dayOfMonth, time: time)
        case "oneTime":
            let date = try container.decode(Date.self, forKey: .date)
            self = .oneTime(date: date)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown schedule type: \(type)")
        }
    }
}
