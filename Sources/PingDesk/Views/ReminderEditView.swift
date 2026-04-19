import SwiftUI

struct ReminderEditView: View {
    @EnvironmentObject private var store: ReminderStore

    let editingReminder: Reminder?
    let onDismiss: () -> Void

    @State private var title: String = ""
    @State private var scheduleType: ScheduleType = .recurring
    @State private var frequency: Frequency = .daily
    @State private var weekday: Int = 2
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
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()

            Divider()

            Form {
                Section {
                    TextField("Reminder message", text: $title)
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
                            Text("Weekly").tag(Frequency.weekly)
                            Text("Monthly").tag(Frequency.monthly)
                        }

                        if frequency == .weekly {
                            Picker("Weekday", selection: $weekday) {
                                ForEach(1...7, id: \.self) { day in
                                    Text(Calendar.current.weekdaySymbols[day - 1]).tag(day)
                                }
                            }
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
        .frame(width: 360, height: editingReminder != nil ? 480 : 420)
        .onAppear { loadFromReminder() }
    }

    private func loadFromReminder() {
        guard let reminder = editingReminder else { return }
        title = reminder.title
        soundName = reminder.soundName
        switch reminder.schedule {
        case .recurring(let freq, let wd, let dom, let t):
            scheduleType = .recurring
            frequency = freq
            weekday = wd ?? 2
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
                weekday: frequency == .weekly ? weekday : nil,
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
