import Foundation

struct Reminder: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var schedule: Schedule
    var soundName: String?
    var isEnabled: Bool
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        schedule: Schedule,
        soundName: String? = nil,
        isEnabled: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.schedule = schedule
        self.soundName = soundName
        self.isEnabled = isEnabled
        self.createdAt = createdAt
    }
}
