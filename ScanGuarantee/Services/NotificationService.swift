import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Notification permission error: \(error.localizedDescription)")
            return false
        }
    }
    
    func scheduleNotification(for item: CertificateModel) async {
        guard item.notifyEnabled else { return }
        
        let notificationDate = Calendar.current.date(
            byAdding: .day,
            value: -item.notifyDaysBefore,
            to: item.validTo
        ) ?? item.validTo
        
        // Не ставим уведомление в прошлое
        guard notificationDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Гарантия скоро истекает"
        content.body = "У товара \"\(item.productName)\" гарантия заканчивается \(item.validTo.formatted(date: .abbreviated, time: .omitted))."
        content.sound = .default
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notificationDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: notificationID(for: item),
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule notification: \(error.localizedDescription)")
        }
    }
    
    func removeNotification(for item: CertificateModel) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationID(for: item)])
    }
    
    func rescheduleNotification(for item: CertificateModel) async {
        removeNotification(for: item)
        await scheduleNotification(for: item)
    }
    
    private func notificationID(for item: CertificateModel) -> String {
        "certificate_\(item.id.uuidString)"
    }
}