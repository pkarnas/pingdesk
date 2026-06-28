import SwiftUI

struct ReminderEditView: View {
    @EnvironmentObject private var store: ReminderStore

    let editingReminder: Reminder?
    let onDismiss: () -> Void

    @State private var title: String = ""
    @State private var scheduleType: ScheduleType = .recurring
    @State private var frequency: Frequency = .daily
    @State private var weekdays: Set<Int> = [2]
    @State private var dayOfMonth: Int = 1
    @State private var time: Date = defaultTime()
    @State private var oneTimeDate: Date = Date().addingTimeInterval(3600)
    @State private var soundName: String? = nil

    enum ScheduleType: String, CaseIterable {
        case recurring = "Recurring"
        case oneTime = "One-time"
    }

    init(editingReminder: Reminder? = nil, onDismiss: @escaping () -> Void = {}) {
        self.editingReminder = editingReminder
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") { onDismiss() }
                Spacer()
                Text(editingReminder == nil ? "New Reminder" : "Edit Reminder")
                    .font(.headline)
                Spacer()
                Button("Save") { save() }
                    .disabled(isSaveDisabled)
            }
            .padding()

            Divider()

            Form {
                Section {
                    TextField("Reminder message", text: $title, axis: .vertical)
                        .labelsHidden()
                        .lineLimit(3, reservesSpace: true)
                        .onChange(of: title) { _, newValue in
                            if newValue.count > 100 {
                                title = String(newValue.prefix(100))
                            }
                        }
                } footer: {
                    HStack {
                        Spacer()
                        Text("\(title.count)/100")
                            .foregroundStyle(title.count > 90 ? .orange : .secondary)
                            .font(.caption)
                    }
                }

                Section("Schedule") {
                    Picker("Type", selection: $scheduleType) {
                        ForEach(ScheduleType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    if scheduleType == .recurring {
                        Picker("Frequency", selection: $frequency) {
                            Text("Daily").tag(Frequency.daily)
                            Text("Selected Days").tag(Frequency.selectedDays)
                            Text("Monthly").tag(Frequency.monthly)
                        }

                        if frequency == .selectedDays {
                            weekdayPicker
                        }

                        if frequency == .monthly {
                            Picker("Day of month", selection: $dayOfMonth) {
                                ForEach(1...31, id: \.self) { day in
                                    Text("\(day)").tag(day)
                                }
                            }
                        }

                        DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    } else {
                        DatePicker("Date & Time", selection: $oneTimeDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    }
                }

                Section("Sound") {
                    SoundPickerView(selectedSound: $soundName)
                }

                if editingReminder != nil {
                    Section {
                        Button(role: .destructive) {
                            deleteReminder()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Reminder")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 360, height: editingReminder != nil ? 520 : 460)
        .onAppear { loadFromReminder() }
    }

    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty ||
        (frequency == .selectedDays && scheduleType == .recurring && weekdays.isEmpty)
    }

    private var weekdayPicker: some View {
        let symbols = Calendar.current.veryShortWeekdaySymbols
        return HStack(spacing: 6) {
            ForEach(1...7, id: \.self) { wd in
                let selected = weekdays.contains(wd)
                Button {
                    if selected {
                        weekdays.remove(wd)
                    } else {
                        weekdays.insert(wd)
                    }
                } label: {
                    Text(symbols[wd - 1])
                        .font(.caption.weight(.semibold))
                        .frame(width: 30, height: 30)
                        .background(selected ? Color.accentColor : Color.primary.opacity(0.08))
                        .foregroundStyle(selected ? Color.white : Color.primary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func loadFromReminder() {
        guard let reminder = editingReminder else { return }
        title = reminder.title
        soundName = reminder.soundName
        switch reminder.schedule {
        case .recurring(let freq, let wds, let dom, let t):
            scheduleType = .recurring
            frequency = freq
            weekdays = wds.isEmpty ? [2] : Set(wds)
            dayOfMonth = dom ?? 1
            var components = DateComponents()
            components.hour = t.hour ?? 9
            components.minute = t.minute ?? 0
            time = Calendar.current.date(from: components) ?? Self.defaultTime()
        case .oneTime(let date):
            scheduleType = .oneTime
            oneTimeDate = date
        }
    }

    private func save() {
        let schedule = buildSchedule()
        if let existing = editingReminder {
            var updated = existing
            updated.title = title.trimmingCharacters(in: .whitespaces)
            updated.schedule = schedule
            updated.soundName = soundName
            store.update(updated)
        } else {
            let reminder = Reminder(
                title: title.trimmingCharacters(in: .whitespaces),
                schedule: schedule,
                soundName: soundName
            )
            store.add(reminder)
        }
        onDismiss()
    }

    private func deleteReminder() {
        guard let reminder = editingReminder else { return }
        store.delete(reminder)
        onDismiss()
    }

    private func buildSchedule() -> Schedule {
        switch scheduleType {
        case .recurring:
            let cal = Calendar.current
            let hour = cal.component(.hour, from: time)
            let minute = cal.component(.minute, from: time)
            var timeComponents = DateComponents()
            timeComponents.hour = hour
            timeComponents.minute = minute
            return .recurring(
                frequency: frequency,
                weekdays: frequency == .selectedDays ? Array(weekdays).sorted() : [],
                dayOfMonth: frequency == .monthly ? dayOfMonth : nil,
                time: timeComponents
            )
        case .oneTime:
            return .oneTime(date: oneTimeDate)
        }
    }

    private static func defaultTime() -> Date {
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
}
