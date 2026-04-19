import AppKit
import SwiftUI

final class EditWindowController {
    static let shared = EditWindowController()

    private var window: NSWindow?

    private init() {}

    func open(for reminder: Reminder? = nil, store: ReminderStore) {
        window?.close()

        let view = ReminderEditView(editingReminder: reminder, onDismiss: { [weak self] in
            self?.window?.close()
        })
        .environmentObject(store)

        let hosting = NSHostingView(rootView: view)

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 440),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = reminder == nil ? "New Reminder" : "Edit Reminder"
        win.contentView = hosting
        win.center()
        win.isReleasedWhenClosed = false
        self.window = win

        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
