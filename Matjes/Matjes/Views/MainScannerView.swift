import SwiftUI
import SwiftData

// MARK: - SearchResult
enum SearchResult: Identifiable, Hashable {
    case product(Product)
    case lexikon(LexikonEntry)
    
    var id: String {
        switch self {
        case .product(let p): return p.id
        case .lexikon(let e): return e.code
        }
    }
    
    var displayName: String {
        switch self {
        case .product(let p): return p.name
        case .lexikon(let e): return e.name
        }
    }
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool { lhs.id == rhs.id }
}

struct MainScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ContentViewModel
    
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
                searchHeader
                
                if combinedResults.isEmpty {
                    hannesEmptyState
                } else {
                    List(combinedResults, selection: $selectedResult) { result in
                        NavigationLink(value: result) {
                            switch result {
                            case .product(let product):
                                HannesProductRow(product: product)
                            case .lexikon(let entry):
                                hannesLexikonRow(entry: entry)
                            }
                        }
                    }
                    .listStyle(.sidebar)
                }
            }
            .navigationTitle("Matjes")
            .navigationSplitViewColumnWidth(min: 300, ideal: 350, max: 500)
            
        } detail: {
            NavigationStack {
                if let result = selectedResult {
                    switch result {
                    case .product(let product):
                        ProductDetailView(product: product)
                    case .lexikon(let entry):
                        ProductDetailView(entry: entry)
                    }
                } else {
                    hannesDesktopPlaceholder
                }
            }
        }
        .onChange(of: allProducts) { _, newValue in
            viewModel.updateCategories(from: newValue, and: allLexikonEntries)
        }
    }
    
    private var combinedResults: [SearchResult] {
        let filteredProducts = allProducts.filter { product in
            let matchesSource = (selectedSource == "Alle") || (product.dataSource == selectedSource)
            let matchesCategory = (selectedCategory == "Alle") || (product.category == selectedCategory)
            let term = searchText.lowercased().folding(options: .diacriticInsensitive, locale: .current).replacingOccurrences(of: " ", with: "")
            let nameNorm = product.name.lowercased().folding(options: .diacriticInsensitive, locale: .current).replacingOccurrences(of: " ", with: "")
            return (searchText.isEmpty || nameNorm.contains(term)) && matchesSource && matchesCategory
        }.map { SearchResult.product($0) }
        
        let filteredLexikon = allLexikonEntries.filter { entry in
            let term = searchText.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            let nameNorm = entry.name.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            return (searchText.isEmpty || nameNorm.contains(term) || entry.code.lowercased().contains(term)) && (selectedSource == "Alle")
        }.map { SearchResult.lexikon($0) }
        
        return (filteredProducts + filteredLexikon).sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
    }
    
    private var searchHeader: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.blue)
                    TextField("Suchen...", text: $searchText).font(.headline).textFieldStyle(.plain)
                }
                .padding(12).background(Color(.systemGray6)).cornerRadius(10).padding(.horizontal)
                
                Picker("Quelle", selection: $selectedSource) {
                    Text("Alle").tag("Alle"); Text("Natur").tag("Natur"); Text("Hering").tag("Hering"); Text("Lieferant").tag("Lieferant")
                }.pickerStyle(.segmented).padding(.horizontal)
            }.padding(.vertical, 12)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    hannesChip(title: "Alle")
                    ForEach(viewModel.dynamicCategories, id: \.self) { cat in hannesChip(title: cat) }
                }.padding(.horizontal).padding(.bottom, 10)
            }
        }.background(Color(.systemBackground)).overlay(Divider(), alignment: .bottom)
    }

    @ViewBuilder
    private func hannesChip(title: String) -> some View {
        Button { selectedCategory = title } label: {
            Text(title).font(.subheadline.bold()).padding(.horizontal, 12).padding(.vertical, 6)
                .background(selectedCategory == title ? Color.blue : Color(.secondarySystemBackground))
                .foregroundColor(selectedCategory == title ? .white : .primary).cornerRadius(8)
        }
    }

    @ViewBuilder
    private func hannesLexikonRow(entry: LexikonEntry) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2).fill(Color.orange).frame(width: 4, height: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name.uppercased()).font(.subheadline.bold())
                Text(entry.kategorie ?? "LEXIKON").font(.caption2).foregroundColor(.orange)
            }
        }
    }

    private var hannesEmptyState: some View {
        ContentUnavailableView("Nichts gefunden", systemImage: "fish.circle", description: Text("Hannes findet leider keine Treffer."))
    }
    
    private var hannesDesktopPlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: "fish.circle.fill").font(.system(size: 100)).foregroundColor(.blue.opacity(0.1))
            Text("Wähle links ein Produkt aus.").font(.title2.bold()).foregroundColor(.secondary)
        }
    }
}

// MARK: - HannesProductRow (WICHTIG: Das hat gefehlt!)
struct HannesProductRow: View {
    let product: Product
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2).fill(sourceColor).frame(width: 4, height: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name.uppercased()).font(.subheadline.bold())
                Text(product.category).font(.caption2).foregroundColor(.blue)
            }
        }
    }
    var sourceColor: Color {
        switch product.dataSource {
        case "Natur": return .green
        case "Hering": return .blue
        case "Lieferant": return .orange
        default: return .gray
        }
    }
}
