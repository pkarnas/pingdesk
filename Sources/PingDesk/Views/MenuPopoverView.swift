import SwiftUI

struct MenuPopoverView: View {
    @EnvironmentObject private var store: ReminderStore

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("PingDesk")
                    .font(.headline)
                Spacer()
                Button {
                    EditWindowController.shared.open(store: store)
                } label: {
                    Image(systemName: "plus")
                        .font(.body.weight(.medium))
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            if store.reminders.isEmpty {
                emptyState
            } else {
                reminderList
            }

            Divider()

            Button("Quit PingDesk") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            .padding(.vertical, 8)
        }
        .frame(width: 400)
        .frame(maxHeight: 400)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "bell.slash")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text("No reminders yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Tap + to add one")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private var reminderList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(store.reminders) { reminder in
                    ReminderRowView(
                        reminder: reminder,
                        onToggle: { store.toggleEnabled(reminder) },
                        onEdit: { EditWindowController.shared.open(for: reminder, store: store) },
                        onDelete: { store.delete(reminder) }
                    )
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)

                    if reminder.id != store.reminders.last?.id {
                        Divider()
                            .padding(.leading, 12)
                    }
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxHeight: 300)
    }
}
