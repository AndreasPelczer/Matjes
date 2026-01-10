import Foundation
import SwiftData

@MainActor
class GagaImporter {
    
    static func importJSON(into context: ModelContext) {
        // 1. RADIKALKUR: Erst alles löschen
        try? context.delete(model: Product.self)
        try? context.delete(model: LexikonEntry.self)
        
        // 2. Kurz zwischenspeichern, um Platz zu schaffen
        try? context.save()
        
        print("🧹 Speicher geleert. Starte Neu-Import für GASTRO-GRID...")
        
        // 3. Jetzt die Funktionen aufrufen (die jetzt im Scope sind!)
        importProdukte(into: context)
        importLexikon(into: context)
        
        // 4. Finales Speichern
        do {
            try context.save()
            print("🚀 GASTRO-GRID OMNI: Daten erfolgreich importiert!")
        } catch {
            print("🚨 Fehler beim finalen Speichern: \(error)")
        }
    }
    
    // MARK: - Private Import-Logik
    
    private static func importProdukte(into context: ModelContext) {
        guard let url = Bundle.main.url(forResource: "Produkte", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("🚨 KRITISCH: Produkte.json nicht gefunden!")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedProducts = try decoder.decode([JSONProduct].self, from: data)
            
            for jsonP in decodedProducts {
                let p = Product(
                    id: jsonP.id,
                    name: jsonP.name,
                    category: jsonP.kategorie,
                    dataSource: jsonP.typ
                )
                p.beschreibung = jsonP.beschreibung
                
                if let meta = jsonP.metadata {
                    p.allergene = meta.allergene
                    p.zusatzstoffe = meta.zusatzstoffe
                    p.kcal = meta.kcal_100g
                    p.fett = meta.fett
                    p.zucker = meta.zucker
                }
                
                if let jsonRecipe = jsonP.rezept {
                    let newRecipe = Recipe(
                        portionen: jsonRecipe.portionen,
                        algorithmus: jsonRecipe.algorithmus
                    )
                    for jsonIng in jsonRecipe.komponenten {
                        let ingredient = Ingredient(
                            name: jsonIng.name,
                            menge: jsonIng.menge,
                            einheit: jsonIng.einheit
                        )
                        ingredient.recipe = newRecipe
                    }
                    p.rezept = newRecipe
                }
                context.insert(p)
            }
            print("✅ \(decodedProducts.count) Produkte inklusive Allergene & Rezepte geladen.")
        } catch {
            print("🚨 PARSE-FEHLER in Produkte.json: \(error)")
        }
    }
    
    private static func importLexikon(into context: ModelContext) {
        guard let url = Bundle.main.url(forResource: "Lexikon", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("🚨 KRITISCH: Lexikon.json nicht gefunden!")
            return
        }
        
        do {
            let raw = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            for e in raw {
                let code = (e["code"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let name = (e["name"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                if name.isEmpty || code.isEmpty { continue }

                let entry = LexikonEntry(
                    code: code,
                    name: name,
                    kategorie: e["kategorie"] as? String ?? "Fachbuch",
                    beschreibung: e["beschreibung"] as? String ?? "",
                    details: e["details"] as? String ?? ""
                )
                context.insert(entry)
            }
            print("📚 BASIS HERING: \(raw.count) Einträge geladen.")
        } catch {
            print("🚨 PARSE-FEHLER im Lexikon: \(error)")
        }
    }
} // <--- Diese Klammer schließt die Klasse GagaImporter ab.
