//
//  NotificationManager.swift
//  PillTracker
//
//  Created by P06 on 16/08/26.
//

import Foundation
import UserNotifications

class NotificationManager{
    static let instance = NotificationManager()
    
    func requestAuthorization(){
        let options: UNAuthorizationOptions = [.alert,.sound,.badge]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if success{
                print("Allowed")
            }else if let error{
                print("Not Allowed: \(error)")
            }
        }
    }
    
    func scheduleNotifications(for medication: Medication) {
            cancelNotifications(for: medication)
            
            switch medication.schedule.frequency {
            case .everyDay:
                for time in medication.schedule.times {
                    scheduleDaily(medication: medication, time: time)
                }
                
            case .specificDays(let days):
                for day in days {
                    for time in medication.schedule.times {
                        scheduleWeekly(medication: medication, time: time, weekday: day.rawValue)
                    }
                }
            }
    }
    
    private func scheduleDaily(medication: Medication, time: ScheduleTime) {
        let content = makeContent(for: medication, time: time)
        
        var dateComponents = DateComponents()
        dateComponents.hour = time.hour
        dateComponents.minute = time.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let identifier = identifierFor(medication: medication, time: time, weekday: nil)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func scheduleWeekly(medication: Medication, time: ScheduleTime, weekday: Int) {
        let content = makeContent(for: medication, time: time)
        
        var dateComponents = DateComponents()
        dateComponents.hour = time.hour
        dateComponents.minute = time.minute
        dateComponents.weekday = weekday
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let identifier = identifierFor(medication: medication, time: time, weekday: weekday)
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func makeContent(for medication: Medication, time: ScheduleTime) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = medication.name
        content.subtitle = medication.dosage
        content.body = "È ora di prendere \(medication.name)"
        content.sound = .default
        content.badge = 1
        return content
    }
        
    private func identifierFor(medication: Medication, time: ScheduleTime, weekday: Int?) -> String {
        if let weekday {
            return "\(medication.id.uuidString)-\(time.hour)-\(time.minute)-\(weekday)"
        } else {
            return "\(medication.id.uuidString)-\(time.hour)-\(time.minute)"
        }
    }
    
    func cancelNotifications(for medication: Medication) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let idsToRemove = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(medication.id.uuidString) }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
    }    
}
