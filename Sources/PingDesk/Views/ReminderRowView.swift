import SwiftUI

struct ReminderRowView: View {
    let reminder: Reminder
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Toggle("", isOn: Binding(
                get: { reminder.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .scaleEffect(0.8)

            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(.body)
                    .foregroundStyle(reminder.isEnabled ? .primary : .secondary)
                    .lineLimit(1)

                Text(scheduleDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if reminder.soundName != nil {
                Image(systemName: "speaker.wave.2")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button { onDelete() } label: {
                Image(systemName: "trash")
                    .font(.callout.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.12))
                    .foregroundStyle(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)

            Button { onEdit() } label: {
                Image(systemName: "pencil")
                    .font(.callout.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primary.opacity(0.08))
                    .foregroundStyle(.primary.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
        }
    }

    private var scheduleDescription: String {
        switch reminder.schedule {
        case .recurring(let frequency, let weekday, let dayOfMonth, let time):
            let timeStr = formatTime(time)
            switch frequency {
            case .daily:
                return "Daily at \(timeStr)"
            case .weekly:
                let dayName = weekday.flatMap { weekdayName($0) } ?? "?"
                return "Every \(dayName) at \(timeStr)"
            case .monthly:
                let day = dayOfMonth.map { ordinal($0) } ?? "?"
                return "Monthly on the \(day) at \(timeStr)"
            }
        case .oneTime(let date):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }

    private func formatTime(_ components: DateComponents) -> String {
        var dc = DateComponents()
        dc.hour = components.hour ?? 0
        dc.minute = components.minute ?? 0
        guard let date = Calendar.current.date(from: dc) else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func weekdayName(_ weekday: Int) -> String {
        let symbols = Calendar.current.weekdaySymbols
        guard weekday >= 1 && weekday <= 7 else { return "" }
        return symbols[weekday - 1]
    }

    private func ordinal(_ n: Int) -> String {
        let suffix: String
        switch n % 10 {
        case 1 where n % 100 != 11: suffix = "st"
        case 2 where n % 100 != 12: suffix = "nd"
        case 3 where n % 100 != 13: suffix = "rd"
        default: suffix = "th"
        }
        return "\(n)\(suffix)"
    }
}
