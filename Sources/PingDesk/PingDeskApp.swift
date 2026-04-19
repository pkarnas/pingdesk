import SwiftUI

@main
struct PingDeskApp: App {
    @StateObject private var store = ReminderStore()

    init() {
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
