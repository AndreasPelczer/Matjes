import SwiftUI
import SwiftData

// 1. Die Kombi-Logik (Bleibt gleich)
enum SearchResult: Identifiable, Hashable {
    case product(Product)
    case lexikon(LexikonEntry)
    var id: String { switch self { case .product(let p): return p.id; case .lexikon(let e): return e.code } }
    var displayName: String { switch self { case .product(let p): return p.name; case .lexikon(let e): return e.name } }
}

import SwiftUI
import SwiftData

struct MainScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ContentViewModel
    
    // Wir holen die Daten direkt aus dem Speicher
    @Query(sort: \Product.name) private var allProducts: [Product]
    @Query(sort: \LexikonEntry.name) private var allLexikonEntries: [LexikonEntry]
    
    @State private var searchText: String = ""
    @State private var selectedSource: String = "Alle"
    @State private var selectedCategory: String = "Alle"
    @State private var selectedResult: SearchResult?
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: ContentViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                // Die Reiter für Natur, Hering, Lieferant
                Picker("Quelle", selection: $selectedSource) {
                    Text("Alle").tag("Alle")
                    Text("Natur").tag("Natur")
                    Text("Hering").tag("Hering")
                    Text("Lieferant").tag("Lieferant")
                }
                .pickerStyle(.segmented).padding()

                // Suche
                TextField("Suchen...", text: $searchText)
                    .padding(10).background(Color(.systemGray6)).cornerRadius(8).padding(.horizontal)

                // Dynamische Kategorien (Chips)
                categoryPicker
                
                // DIE LISTE (Hier war der Fehler!)
                if combinedResults.isEmpty {
                    ContentUnavailableView("Keine Daten", systemImage: "tray.fill", description: Text("Prüfe, ob die JSON-Dateien geladen wurden."))
                } else {
                    List(combinedResults, selection: $selectedResult) { result in
                        NavigationLink(value: result) {
                            rowView(for: result)
                        }
                    }
                    .listStyle(.sidebar)
                }
            }
            .navigationTitle("Matjes")
        } detail: {
            if let res = selectedResult {
                switch res {
                case .product(let p): ProductDetailView(product: p)
                case .lexikon(let e): ProductDetailView(entry: e)
                }
            }
        }
        .onAppear {
            // Erzwingt das Update der Chips beim Start
            viewModel.updateCategories(from: allProducts, and: allLexikonEntries)
        }
    }

    // MARK: - Filter-Logik (KORRIGIERT)
    private var combinedResults: [SearchResult] {
            let term = searchText.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            
            // 1. Lexikon-Teil filtern
            let lexPart = allLexikonEntries.filter { e in
                let matchesSource = (selectedSource == "Alle" || selectedSource == "Hering")
                let matchesCat = (selectedCategory == "Alle" || e.kategorie == selectedCategory)
                let matchesSearch = searchText.isEmpty || e.name.lowercased().contains(term)
                return matchesSource && matchesCat && matchesSearch
            }.map { SearchResult.lexikon($0) }
            
            // 2. Produkt-Teil filtern
            let prodPart = allProducts.filter { p in
                let matchesSource = (selectedSource == "Alle" || p.dataSource == selectedSource)
                let matchesCat = (selectedCategory == "Alle" || p.category == selectedCategory)
                let matchesSearch = searchText.isEmpty || p.name.lowercased().contains(term)
                return matchesSource && matchesCat && matchesSearch
            }.map { SearchResult.product($0) }
            
            // --- NEU: DUBLETTEN-FILTER ---
            var seenIDs = Set<String>()
            var uniqueResults = [SearchResult]()
            
            // Wir gehen alle gefundenen Einträge durch (Lexikon + Produkte)
            for item in (lexPart + prodPart) {
                // Wir prüfen, ob wir diese ID (oder diesen Namen) schon im Set haben
                if !seenIDs.contains(item.id) {
                    uniqueResults.append(item)
                    seenIDs.insert(item.id) // ID als "erledigt" markieren
                }
            }
            
            // Die saubere Liste sortiert zurückgeben
            return uniqueResults.sorted { $0.displayName < $1.displayName }
        }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                hannesChip(title: "Alle")
                ForEach(viewModel.dynamicCategories, id: \.self) { cat in
                    hannesChip(title: cat)
                }
            }.padding()
        }
    }

    private func hannesChip(title: String) -> some View {
        Button(title) { selectedCategory = title }
            .padding(8)
            .background(selectedCategory == title ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(selectedCategory == title ? .white : .primary)
            .cornerRadius(8)
    }

    @ViewBuilder
        private func rowView(for result: SearchResult) -> some View {
            switch result {
            case .product(let p):
                HStack {
                    // Der farbige Balken links (Natur=Grün, Lieferant=Blau)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(p.dataSource == "Natur" ? .green : .blue)
                        .frame(width: 4, height: 35)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(p.name.uppercased()).bold()
                        Text(p.category).font(.caption).foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // --- NEU: DAS WARNSYSTEM (PUNKTE) ---
                    HStack(spacing: 4) {
                        // ROTE PUNKTE für Allergene
                        if !p.allergene.isEmpty {
                            let count = p.allergene.components(separatedBy: ",").count
                            ForEach(0..<min(count, 3), id: \.self) { _ in
                                Circle().fill(.red).frame(width: 8, height: 8)
                            }
                        }
                        
                        // GELBE PUNKTE für Zusatzstoffe
                        if !p.zusatzstoffe.isEmpty {
                            Circle().fill(.yellow).frame(width: 8, height: 8)
                        }
                    }
                    // ------------------------------------
                }
            case .lexikon(let e):
                HStack {
                    RoundedRectangle(cornerRadius: 2).fill(.orange).frame(width: 4, height: 35)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(e.name.uppercased()).bold()
                        Text(e.kategorie ?? "Lexikon").font(.caption).foregroundColor(.secondary)
                    }
                }
            }
        }
}
