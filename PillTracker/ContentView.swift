//
//  ContentView.swift
//  PillTracker
//
//  Created by P06 on 13/08/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = MedicationStore()
    var body: some View {
        TabView {
            TodayView(store: store)
                .tabItem {
                    Label("Oggi", systemImage: "clipboard")
                }

            MedicationListView(store: store)
                .tabItem {
                    Label("Farmaci", systemImage: "pills")
                }

            HistoryView(store: store)
                .tabItem {
                    Label("Storico", systemImage: "brain")
                }
        }
        .tint(Color(red:246/255,
                    green:84/255,
                    blue:125/255))
        
    }
}

#Preview {
    ContentView()
}
