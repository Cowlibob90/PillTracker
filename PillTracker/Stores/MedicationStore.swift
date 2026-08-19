//
//  MedicationStore.swift
//  PillTracker
//
//  Created by P06 on 14/08/26.
//

import Foundation
import Combine

@MainActor
final class MedicationStore: ObservableObject {
    @Published var medications: [Medication] = []
    @Published var doseLogs: [DoseLog] = []
    
    private let storage = JSONStorage()
    private let medicationsFile = "medications.json"
    private let logsFile = "dose_logs.json"
    
    init() {
        load()
        loadLogs()
    }
    
    //Medication
    
    func addMedication(_ medication: Medication) {
        medications.append(medication)
        save()
    }
    
    func load() {
        medications = (try? storage.load([Medication].self, from: medicationsFile)) ?? []
    }
    
    func save() {
        try? storage.save(medications, as: medicationsFile)
    }
    
    func isScheduledToday(_ medication: Medication) -> Bool {
        switch medication.schedule.frequency {
        case .everyDay:
            return true
        case .specificDays(let days):
            let today = Calendar.current.component(.weekday, from: Date())
            return days.contains { $0.rawValue == today }
        }
    }
    
    //Dose logs
    
    func takenToday(medicationID: UUID, time: ScheduleTime) -> Bool {
        doseLogs.contains {
            $0.medicationID == medicationID &&
            $0.scheduledTime.hour == time.hour &&
            $0.scheduledTime.minute == time.minute &&
            Calendar.current.isDate($0.takenAt, inSameDayAs: Date())
        }
    }
    
    func toggleDose(medicationID: UUID, time: ScheduleTime) {
        if let index = doseLogs.firstIndex(where: {
            $0.medicationID == medicationID &&
            $0.scheduledTime.hour == time.hour &&
            $0.scheduledTime.minute == time.minute &&
            Calendar.current.isDate($0.takenAt, inSameDayAs: Date())
        }) {
            doseLogs.remove(at: index)
        } else {
            doseLogs.append(DoseLog(medicationID: medicationID, scheduledTime: time, takenAt: Date()))
        }
        saveLogs()
    }
    
    func saveLogs() {
        try? storage.save(doseLogs, as: logsFile)
    }
    
    func loadLogs() {
        doseLogs = (try? storage.load([DoseLog].self, from: logsFile)) ?? []
    }
    
    var logsGroupedByDay: [(date: Date, logs: [DoseLog])] {
            let calendar = Calendar.current
            
            let grouped = Dictionary(grouping: doseLogs) { log in
                calendar.startOfDay(for: log.takenAt)
            }
            
            return grouped
                .map { (date: $0.key, logs: $0.value.sorted { $0.takenAt > $1.takenAt }) }
                .sorted { $0.date > $1.date }
    }
}
