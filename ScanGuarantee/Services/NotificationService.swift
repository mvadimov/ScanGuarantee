//
//  NotificationService.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 17.04.26.
//

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
            print("Ошибка разрешения на уведомление: \(error.localizedDescription)")
            return false
        }
    }
    
    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    func isAuthorized() async -> Bool {
        let status = await getAuthorizationStatus()
        return status == .authorized || status == .provisional
    }
    
    func scheduleNotification(for item: CertificateModel) async {
        guard item.notifyEnabled else { return }
        
        guard let notificationDate = makeNotificationDate(for: item.validTo) else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Гарантия скоро истекает"
        content.body = "\"\(item.productName)\" гарантия истекает \(item.validTo.formatted(date: .abbreviated, time: .omitted))."
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
            print("Ошибка запланирования уведомления: \(error.localizedDescription)")
        }
    }
    
    func removeNotification(for item: CertificateModel) {
        let id = notificationID(for: item)
        let center = UNUserNotificationCenter.current()
        
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.removeDeliveredNotifications(withIdentifiers: [id])
    }
    
    func rescheduleNotification(for item: CertificateModel) async {
        removeNotification(for: item)
        await scheduleNotification(for: item)
    }
    
    private func notificationID(for item: CertificateModel) -> String {
        "certificate_\(item.id.uuidString)"
    }
    
    private func makeNotificationDate(for validTo: Date) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        guard let sevenDaysBefore = calendar.date(byAdding: .day, value: -7, to: validTo) else {
            return nil
        }
        
        let sevenDaysBeforeAtTen = calendar.date(
            bySettingHour: 10,
            minute: 0,
            second: 0,
            of: sevenDaysBefore
        ) ?? sevenDaysBefore
        
        if sevenDaysBeforeAtTen > now {
            return sevenDaysBeforeAtTen
        }
        
        let todayAtTen = calendar.date(
            bySettingHour: 10,
            minute: 0,
            second: 0,
            of: now
        ) ?? now
        
        let fallbackDate: Date
        if now < todayAtTen {
            fallbackDate = todayAtTen
        } else {
            fallbackDate = calendar.date(byAdding: .day, value: 1, to: todayAtTen) ?? todayAtTen
        }
        
        if fallbackDate >= validTo {
            return nil
        }
        
        return fallbackDate
    }
}
