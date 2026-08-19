//
//  HistoryView.swift
//  PillTracker
//
//  Created by P06 on 13/08/26.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var store: MedicationStore
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "it_IT")
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            Group {
                if store.doseLogs.isEmpty {
                    ContentUnavailableView(
                        "Nessuna dose registrata",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Le dosi che segni come prese in \"Oggi\" appariranno qui.")
                    )
                } else {
                    List {
                        ForEach(store.logsGroupedByDay, id: \.date) { group in
                            Section(dateFormatter.string(from: group.date)) {
                                ForEach(group.logs) { log in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(medicationName(for: log.medicationID))
                                                .font(.body)
                                            Text("Programmata per le \(log.scheduledTime.label)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(timeFormatter.string(from: log.takenAt))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Storico")
        }
    }
    
    private func medicationName(for id: UUID) -> String {
        store.medications.first { $0.id == id }?.name ?? "Farmaco eliminato"
    }
}

#Preview {
    HistoryView(store: MedicationStore())
}
