import Foundation
import Combine

final class ReminderStore: ObservableObject {
    @Published var reminders: [Reminder] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        load()
        scheduleAll()
        observeOneTimeFired()
    }

    func add(_ reminder: Reminder) {
        reminders.append(reminder)
        save()
        if reminder.isEnabled {
            NotificationService.shared.schedule(reminder)
        }
    }

    func update(_ reminder: Reminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        NotificationService.shared.cancel(id: reminder.id)
        reminders[index] = reminder
        save()
        if reminder.isEnabled {
            NotificationService.shared.schedule(reminder)
        }
    }

    func delete(_ reminder: Reminder) {
        NotificationService.shared.cancel(id: reminder.id)
        reminders.removeAll { $0.id == reminder.id }
        save()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets {
            NotificationService.shared.cancel(id: reminders[index].id)
        }
        reminders.remove(atOffsets: offsets)
        save()
    }

    func toggleEnabled(_ reminder: Reminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        reminders[index].isEnabled.toggle()
        save()
        if reminders[index].isEnabled {
            NotificationService.shared.schedule(reminders[index])
        } else {
            NotificationService.shared.cancel(id: reminder.id)
        }
    }

    private func scheduleAll() {
        for reminder in reminders where reminder.isEnabled {
            NotificationService.shared.schedule(reminder)
        }
    }

    private func observeOneTimeFired() {
        NotificationCenter.default
            .publisher(for: NotificationService.oneTimeFiredNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self, let uuid = notification.object as? UUID else { return }
                if let index = self.reminders.firstIndex(where: { $0.id == uuid }) {
                    if case .oneTime = self.reminders[index].schedule {
                        self.reminders[index].isEnabled = false
                        self.save()
                    }
                }
            }
            .store(in: &cancellables)
    }

    private var fileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("PingDesk", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("reminders.json")
    }

    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(reminders)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("PingDesk: failed to save reminders: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            reminders = try decoder.decode([Reminder].self, from: data)
        } catch {
            print("PingDesk: failed to load reminders: \(error)")
        }
    }
}
