import SwiftUI

@main
struct PingDeskApp: App {
    @StateObject private var store = ReminderStore()

    // Exclusive file lock held for the process lifetime. When the process
    // exits (or crashes), the OS releases the lock automatically.
    private static let lockFD: Int32 = {
        let path = FileManager.default.temporaryDirectory
            .appendingPathComponent("com.pingdesk.app.lock").path
        let fd = open(path, O_CREAT | O_WRONLY, 0o644)
        guard fd >= 0 else { return -1 }
        if flock(fd, LOCK_EX | LOCK_NB) != 0 {
            exit(0) // Another instance holds the lock
        }
        return fd
    }()

    init() {
        _ = Self.lockFD
        NotificationService.shared.requestAuthorization()
    }

    var body: some Scene {
        MenuBarExtra("PingDesk", systemImage: "bell.badge") {
            MenuPopoverView()
                .environmentObject(store)
        }
        .menuBarExtraStyle(.window)
    }
}
