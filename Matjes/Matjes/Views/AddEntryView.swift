import SwiftUI
import SwiftData

struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var entryType: String = "Produkt"
    
    // Gemeinsame Felder
    @State private var name: String = ""
    @State private var idOrCode: String = ""
    @State private var category: String = ""
    @State private var description: String = ""
    
    // Produktspezifisch
    @State private var dataSource: String = "Lieferant"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Typ auswählen") {
                    Picker("Was erstellst du?", selection: $entryType) {
                        Text("Produkt").tag("Produkt")
                        Text("Technik / Lexikon").tag("Technik")
                    }.pickerStyle(.segmented)
                }
                
                Section("Basis-Infos") {
                    // Beispieltexte als graue Platzhalter hinzugefügt
                    TextField("z. B. Bio-Zitrone oder Räucherlachs", text: $name)
                    
                    TextField(entryType == "Produkt" ? "z. B. Art-Nr. 1005" : "z. B. E-300 oder T-KOCH", text: $idOrCode)
                    
                    TextField("z. B. Obst, Fisch oder Garmethode", text: $category)
                }
                
                Section("Details") {
                    if entryType == "Produkt" {
                        Picker("Quelle", selection: $dataSource) {
                            Text("Natur").tag("Natur")
                            Text("Hering").tag("Hering")
                            Text("Lieferant").tag("Lieferant")
                        }
                    }
                    
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .overlay(alignment: .topLeading) {
                            if description.isEmpty {
                                // Hier ist der graue Text für das große Beschreibungsfeld
                                Text("z. B. Herkunft, Reifegrad oder wichtige Verarbeitungsschritte...")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                            }
                        }
                }
                
                Section("Zukunft") {
                    Label("Foto/Video Scan (Coming Soon)", systemImage: "camera.fill")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Neu anlegen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { saveEntry() }
                        .disabled(name.isEmpty || idOrCode.isEmpty)
                        .bold()
                }
            }
        }
    }
    
    private func saveEntry() {
            // 1. Erstellung des Objekts je nach Typ
            if entryType == "Produkt" {
                let newProduct = Product(
                    id: idOrCode,
                    name: name,
                    category: category,
                    dataSource: dataSource
                )
                newProduct.beschreibung = description
                
                modelContext.insert(newProduct)
                print("🐟 Produkt '\(name)' lokal erstellt.")
                
            } else {
                let newEntry = LexikonEntry(
                    code: idOrCode,
                    name: name,
                    kategorie: category,
                    beschreibung: description
                )
                
                modelContext.insert(newEntry)
                print("📚 Lexikon-Eintrag '\(name)' lokal erstellt.")
            }
            
            // 2. Den „Tresor“ abschließen (Speichern)
            do {
                try modelContext.save()
                print("☁️ Cloud-Sync: Daten erfolgreich zur Synchronisation vorgemerkt.")
                dismiss()
            } catch {
                print("🚨 Fehler beim Speichern: \(error.localizedDescription)")
            }
        }
    }
