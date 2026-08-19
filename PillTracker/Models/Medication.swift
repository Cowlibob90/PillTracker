//
//  Medication.swift
//  PillTracker
//
//  Created by P06 on 14/08/26.
//
import Foundation

enum Weekday: Int, CaseIterable, Codable, Hashable, Identifiable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    var id: Int {
        rawValue
    }
    
    var name: String {
        switch self {
        case .sunday:
            return "Domenica"
        case .monday:
            return "Lunedì"
        case .tuesday:
            return "Martedì"
        case .wednesday:
            return "Mercoledì"
        case .thursday:
            return "Giovedì"
        case .friday:
            return "Venerdì"
        case .saturday:
            return "Sabato"
        }
    }
}

struct ScheduleTime: Codable, Hashable, Identifiable {
    var id = UUID()
    var hour: Int
    var minute: Int
    
    var label: String {
        String(format: "%02d:%02d", hour, minute)
    }
    
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    init(date: Date) {
        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: date
        )
        
        self.hour = components.hour ?? 8
        self.minute = components.minute ?? 0
    }
    
    var date: Date {
        Calendar.current.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: Date()
        ) ?? Date()
    }
}

enum MedicationFrequency: Codable, Hashable {
    case everyDay
    case specificDays([Weekday])
}

struct ScheduleRule: Codable, Hashable {
    var frequency: MedicationFrequency
    var times: [ScheduleTime]
}

struct Medication: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var dosage: String
    var instructions: String
    var schedule: ScheduleRule
}

struct DoseLog: Identifiable, Codable {
    var id = UUID()
    var medicationID: UUID
    var scheduledTime: ScheduleTime
    var takenAt: Date
}
