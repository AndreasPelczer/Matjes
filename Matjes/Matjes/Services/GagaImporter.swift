import Foundation
import SwiftData

@MainActor
class GagaImporter {
    
    // MARK: - HAUPTFUNKTION (Der Zündschlüssel)
    static func importJSON(into context: ModelContext) {
        // Zuerst deine bewährten Produkte laden
        importProdukte(into: context)
        
        // Danach das Fachwissen aus dem Hering-Lexikon laden
        importLexikon(into: context)
    }
    
    // MARK: - 1. PRODUKT-IMPORT (Dein funktionierender Code)
    private static func importProdukte(into context: ModelContext) {
        // Tabula Rasa: Wir machen das Lager einmal leer
        try? context.delete(model: Product.self)
        
        guard let url = Bundle.main.url(forResource: "Produkte", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("🚨 Fehler: Produkte.json nicht gefunden")
            return
        }
        
        do {
            let rawList = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            
            for entry in rawList {
                let id = entry["id"] as? String ?? "000"
                let name = entry["name"] as? String ?? "Unbekannt"
                let cat = entry["kategorie"] as? String ?? "Allgemein"
                let typ = entry["typ"] as? String ?? "Lieferant"
                
                let p = Product(id: id, name: name, category: cat, dataSource: typ)
                p.beschreibung = entry["beschreibung"] as? String ?? ""
                
                if let meta = entry["metadata"] as? [String: String] {
                    p.allergene = meta["allergene"] ?? ""
                    p.zusatzstoffe = meta["zusatzstoffe"] ?? ""
                    p.kcal = meta["kcal_100g"] ?? ""
                    p.fett = meta["fett"] ?? ""
                    p.zucker = meta["zucker"] ?? ""
                    
                    for (key, value) in meta {
                        let bekannteKeys = ["allergene", "zusatzstoffe", "kcal_100g", "fett", "zucker"]
                        if !bekannteKeys.contains(key) {
                            p.zusatzInfos[key.capitalized] = value
                        }
                    }
                }
                context.insert(p)
            }
            try context.save()
            print("✅ Import fertig: \(rawList.count) Produkte geladen.")
        } catch {
            print("🚨 Fehler beim Produkt-Import: \(error)")
        }
    }
    
    // MARK: - 2. LEXIKON-IMPORT (Neu für Hering Fachkunde)
    private static func importLexikon(into context: ModelContext) {
        // Wir räumen das Lexikon einmal auf, damit keine Dubletten entstehen
        try? context.delete(model: LexikonEntry.self)
        
        // Wir suchen die Lexikon.json im Projekt
        guard let url = Bundle.main.url(forResource: "Lexikon", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("📚 Info: Lexikon.json noch nicht im Projekt - überspringe Fachkunde.")
            return
        }
        
        do {
            // Wir laden das Lexikon-JSON
            let rawLexikon = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            
            for entry in rawLexikon {
                            // 1. Daten aus dem JSON ziehen
                            let code = entry["code"] as? String ?? "???"
                            let name = entry["name"] as? String ?? "Unbenannt"
                            let kategorie = entry["kategorie"] as? String ?? "Fachkunde" // Kategorie nach oben
                            let beschreibung = entry["beschreibung"] as? String ?? ""
                            let details = entry["details"] as? String ?? "" // NEU: Das Details-Feld
                            
                            // 2. Den Eintrag erstellen (REIHENFOLGE BEACHTEN!)
                            let newEntry = LexikonEntry(
                                code: code,
                                name: name,
                                kategorie: kategorie,      // Kategorie kommt ZUERST
                                beschreibung: beschreibung, // Dann Beschreibung
                                details: details           // Und zum Schluss Details
                            )
                            
                            context.insert(newEntry)
                        }
            
            try context.save()
            print("📚 Hering-Lexikon: \(rawLexikon.count) Einträge erfolgreich importiert.")
        } catch {
            print("🚨 Fehler beim Lexikon-Import: \(error)")
        }
    }
}
