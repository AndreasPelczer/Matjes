//
//  MatjesApp.swift
//  Matjes
//
//  Created by Senior-Entwickler (Mentor) am 08.01.26.
//

import SwiftUI
import SwiftData

@main
struct MatjesApp: App {
    
    var sharedModelContainer: ModelContainer = {
        // HIER: Du musst BEIDE Modelle angeben, damit SwiftData die Tabellen erstellt
        let schema = Schema([
            Product.self,
            LexikonEntry.self  // <-- DAS FEHLTE!
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("🚨 ModelContainer-Fehler: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainScannerView(modelContext: sharedModelContainer.mainContext)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    Task { @MainActor in
                        let context = sharedModelContainer.mainContext
                        
                        // 1. Importieren (Der Allesfresser-Import)
                        GagaImporter.importJSON(into: context)
                        
                        // 2. Speichern
                        do {
                            try context.save()
                            print("✅ Alles im Kasten: 1400 Produkte sind startklar.")
                        } catch {
                            print("🚨 Fehler beim Sichern: \(error)")
                        }
                    }
                }
        }
    }
}
