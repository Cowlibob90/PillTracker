//
//  MedicationFormView.swift
//  PillTracker
//
//  Created by P06 on 13/08/26.
//

import SwiftUI

struct MedicationFormView: View {
    @ObservedObject var store: MedicationStore
    @Environment(\.dismiss) private var dismiss
    var medicationToEdit: Medication?
    
    @State private var name = ""
    @State private var dosage = ""
    @State private var instructions = ""
    
    @State private var frequency: MedicationFrequency = .everyDay
    @State private var selectedDays: Set<Weekday> = []
    
    @State private var times: [ScheduleTime] = [
        ScheduleTime(hour: 8, minute: 0)
    ]
    
    @State private var showValidationAlert = false
    @State private var showDeleteConfirmation = false
    
    init(store: MedicationStore, medicationToEdit: Medication? = nil) {
        self.store = store
        self.medicationToEdit = medicationToEdit
    }
    
    var body: some View {
        NavigationStack {
            Form {
                basicInformationSection
                frequencySection
                timesSection
                
                if medicationToEdit != nil {
                    deleteSection
                }
            }
            .navigationTitle(medicationToEdit == nil ? "Nuovo farmaco" : "Modifica farmaco")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salva") {
                        saveMedication()
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let medication = medicationToEdit {
                    loadValues(from: medication)
                }
            }
            .alert("Dati mancanti", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Inserisci il nome, il dosaggio e almeno un orario valido.")
            }
            .alert("Eliminare questo farmaco?", isPresented: $showDeleteConfirmation) {
                Button("Elimina", role: .destructive) {
                    deleteMedication()
                }
                Button("Annulla", role: .cancel) {}
            } message: {
                Text("Questa azione non può essere annullata. Verranno rimosse anche le notifiche associate.")
            }
        }
    }
    
    private var basicInformationSection: some View {
        Section("Informazioni") {
            TextField("Nome farmaco", text: $name)
            
            TextField("Dosaggio", text: $dosage)
            
            TextField(
                "Istruzioni opzionali",
                text: $instructions,
                axis: .vertical
            )
            .lineLimit(2...4)
        }
    }
    
    private var frequencySection: some View {
        Section("Giorni di assunzione") {
            Picker("Frequenza", selection: $frequency) {
                Text("Ogni giorno")
                    .tag(MedicationFrequency.everyDay)
                
                Text("Giorni specifici")
                    .tag(MedicationFrequency.specificDays([]))
            }
            
            if isSpecificDaysSelected {
                ForEach(Weekday.allCases) { day in
                    Toggle(day.name, isOn: bindingForDay(day))
                }
            }
        }
    }
    
    private var timesSection: some View {
        Section {
            ForEach($times) { $time in
                DatePicker(
                    "Orario",
                    selection: Binding(
                        get: {
                            time.date
                        },
                        set: { newDate in
                            time = ScheduleTime(date: newDate)
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
            }
            .onDelete { indexSet in
                times.remove(atOffsets: indexSet)
            }
            
            Button {
                times.append(ScheduleTime(hour: 12, minute: 0))
            } label: {
                Label("Aggiungi orario", systemImage: "plus")
            }
        } header: {
            Text("Orari")
        } footer: {
            Text("Puoi aggiungere più orari, ad esempio mattina e sera.")
        }
    }
    
    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Text("Elimina farmaco")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    private var isSpecificDaysSelected: Bool {
        if case .specificDays = frequency {
            return true
        }
        
        return false
    }
    
    private func bindingForDay(_ day: Weekday) -> Binding<Bool> {
        Binding {
            selectedDays.contains(day)
        } set: { isSelected in
            if isSelected {
                selectedDays.insert(day)
            } else {
                selectedDays.remove(day)
            }
            
            frequency = .specificDays(Array(selectedDays))
        }
    }
    
    private func loadValues(from medication: Medication) {
        name = medication.name
        dosage = medication.dosage
        instructions = medication.instructions
        frequency = medication.schedule.frequency
        times = medication.schedule.times
        
        if case .specificDays(let days) = medication.schedule.frequency {
            selectedDays = Set(days)
        }
    }
    
    private func saveMedication() {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDosage = dosage.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanName.isEmpty,
              !cleanDosage.isEmpty,
              !times.isEmpty
        else {
            showValidationAlert = true
            return
        }
        
        let finalFrequency: MedicationFrequency
        
        switch frequency {
        case .everyDay:
            finalFrequency = .everyDay
            
        case .specificDays:
            guard !selectedDays.isEmpty else {
                showValidationAlert = true
                return
            }
            
            finalFrequency = .specificDays(Array(selectedDays))
        }
        
        let updatedSchedule = ScheduleRule(frequency: finalFrequency, times: times)
        
        if let existing = medicationToEdit {
            guard let index = store.medications.firstIndex(where: { $0.id == existing.id }) else {
                dismiss()
                return
            }
            
            store.medications[index].name = cleanName
            store.medications[index].dosage = cleanDosage
            store.medications[index].instructions = instructions
            store.medications[index].schedule = updatedSchedule
            store.save()
            
            NotificationManager.instance.cancelNotifications(for: existing)
            NotificationManager.instance.scheduleNotifications(for: store.medications[index])
        } else {
            let medication = Medication(
                name: cleanName,
                dosage: cleanDosage,
                instructions: instructions.isEmpty ? "" : instructions,
                schedule: updatedSchedule
            )
            
            store.addMedication(medication)
            NotificationManager.instance.scheduleNotifications(for: medication)
        }
        
        dismiss()
    }
    
    private func deleteMedication() {
        guard let existing = medicationToEdit else { return }
        
        NotificationManager.instance.cancelNotifications(for: existing)
        store.medications.removeAll { $0.id == existing.id }
        store.save()
        
        dismiss()
    }
}

#Preview("Nuovo farmaco") {
    MedicationFormView(store: MedicationStore())
}
