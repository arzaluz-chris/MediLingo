import Foundation
import UserNotifications

// Local notifications for streak reminders (CLAUDE-ios.md § Notifications,
// docs/GAMIFICATION.md § Streaks). No remote push in the MVP — a single daily
// reminder scheduled locally keeps the user's streak alive.
protocol NotificationServiceProtocol: Sendable {
    func requestAuthorization() async -> Bool
    func scheduleStreakReminder(hour: Int, minute: Int) async
    func cancelStreakReminder()
}

struct NotificationService: NotificationServiceProtocol {
    private static let streakReminderID = "streak-reminder"

    private var center: UNUserNotificationCenter { .current() }

    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    /// Schedule a repeating daily reminder at the given local time. Replaces any
    /// existing reminder so the schedule always reflects the latest goal time.
    func scheduleStreakReminder(hour: Int, minute: Int) async {
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized ||
              settings.authorizationStatus == .provisional else { return }

        cancelStreakReminder()

        let content = UNMutableNotificationContent()
        content.title = "¡No pierdas tu racha!"
        content.body = "Practica inglés médico unos minutos para mantener tu racha viva. 🔥"
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: Self.streakReminderID,
            content: content,
            trigger: trigger,
        )
        try? await center.add(request)
    }

    func cancelStreakReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [Self.streakReminderID])
    }
}
