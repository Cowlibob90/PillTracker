//
//  MedicationListView.swift
//  PillTracker
//
//  Created by P06 on 18/08/26.
//

import SwiftUI

struct MedicationListView: View {
    @ObservedObject var store: MedicationStore
    @State private var medicationToEdit: Medication?
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                if store.medications.isEmpty {
                    ContentUnavailableView(
                        "Nessun farmaco",
                        systemImage: "pills",
                        description: Text("Aggiungi il tuo primo farmaco dal pulsante +")
                    )
                } else {
                    ForEach(store.medications) { medication in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(medication.name)
                                .font(.headline)
                            Text(medication.dosage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(scheduleSummary(for: medication))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            medicationToEdit = medication
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                removeMedication(medication)
                            } label: {
                                Label("Elimina", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("I tuoi farmaci")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                        
                    }label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $medicationToEdit) { medication in
                MedicationFormView(store: store, medicationToEdit: medication)
            }
            .sheet(isPresented: $showAddSheet) {
                MedicationFormView(store: store)
            }
            
        }
    }
    
    private func removeMedication(_ medication: Medication) {
        NotificationManager.instance.cancelNotifications(for: medication)
        store.medications.removeAll { $0.id == medication.id }
        store.save()
    }
    
    private func scheduleSummary(for medication: Medication) -> String {
        let times = medication.schedule.times.map(\.label).joined(separator: ", ")
        
        switch medication.schedule.frequency {
        case .everyDay:
            return "Ogni giorno alle \(times)"
        case .specificDays(let days):
            let dayNames = days.sorted { $0.rawValue < $1.rawValue }.map(\.name).joined(separator: ", ")
            return "\(dayNames) alle \(times)"
        }
    }
}

#Preview {
    MedicationListView(store: MedicationStore())
}
