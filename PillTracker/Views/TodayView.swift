//
//  TodayView.swift
//  PillTracker
//
//  Created by P06 on 13/08/26.
//

import SwiftUI

struct TodayView: View {
    @ObservedObject var store: MedicationStore
    
    private var todaysMedications: [Medication] {
        store.medications.filter { store.isScheduledToday($0) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(todaysMedications) { medication in
                    Section(medication.name) {
                        Text(medication.dosage)
                            .foregroundStyle(.secondary)
                        
                        if !medication.instructions.isEmpty {
                            Text(medication.instructions)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        
                        ForEach(medication.schedule.times) { time in
                            Toggle(isOn: bindingForDose(medication: medication, time: time)) {
                                Text("Alle ore \(time.label)")
                            }
                        }
                    }
                }
                
            }
            .navigationTitle("Oggi")
        }
    }
    
    private func bindingForDose(medication: Medication, time: ScheduleTime) -> Binding<Bool> {
        Binding(
            get: {
                store.takenToday(medicationID: medication.id, time: time)
            },
            set: { _ in
                store.toggleDose(medicationID: medication.id, time: time)
            }
        )
    }
}

#Preview {
    TodayView(store: MedicationStore())
}
