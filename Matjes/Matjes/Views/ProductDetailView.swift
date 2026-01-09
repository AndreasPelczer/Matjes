import SwiftUI
import SwiftData

struct ProductDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let product: Product?
    let lexikonEntry: LexikonEntry?
    
    @State private var servings: Int = 4
    @State private var hasInitializedServings = false
    @State private var selectedLinkID: String?
    @State private var navigateToLink = false

    @Query private var allProducts: [Product]
    @Query private var allLexikonEntries: [LexikonEntry]

    init(product: Product) { self.product = product; self.lexikonEntry = nil }
    init(entry: LexikonEntry) { self.lexikonEntry = entry; self.product = nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                VStack(alignment: .leading, spacing: 25) {
                    titleSection
                    if let p = product, (!p.allergene.isEmpty || !p.zusatzstoffe.isEmpty) { safetyPanel(for: p) }
                    actionZone
                    if let p = product {
                        if !p.kcal.isEmpty { nutritionGrid(for: p) }
                        if !p.zusatzInfos.isEmpty { extraInfoPanel(for: p) }
                        if let recipe = p.rezept { hannesRecipeCard(recipe) }
                    }
                    if let entry = lexikonEntry { lexikonFachkundePanel(for: entry) }
                    if let details = lexikonEntry?.details, !details.isEmpty { storageComponentPanel(details: details) }
                }
                .padding(.top, -30).padding(.horizontal)
                Spacer(minLength: 80)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color(.systemGroupedBackground))
        .navigationDestination(isPresented: $navigateToLink) {
            if let id = selectedLinkID { UniversalDetailSelector(queryID: id) }
        }
        .onAppear { initializeServings() }
    }

    private func lexikonFachkundePanel(for entry: LexikonEntry) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("FACHWISSEN").font(.caption.bold()).foregroundColor(.orange)
            Text(LocalizedStringKey(entry.beschreibung ?? "")).font(.body)
                .environment(\.openURL, OpenURLAction { url in handleInternalLink(url: url) })
        }.padding().background(Color(.secondarySystemGroupedBackground)).cornerRadius(20)
    }
    
    private func storageComponentPanel(details: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("KOMPONENTEN AUS DEM LAGER").font(.caption.bold()).foregroundColor(.secondary)
            Text(LocalizedStringKey(details)).font(.body).tint(.blue)
                .environment(\.openURL, OpenURLAction { url in handleInternalLink(url: url) })
        }.padding().background(Color(.systemGray6)).cornerRadius(12)
    }
    
    private func handleInternalLink(url: URL) -> OpenURLAction.Result {
        let link = url.absoluteString
        if link.hasPrefix("http") { return .systemAction }
        DispatchQueue.main.async {
            self.selectedLinkID = link
            self.navigateToLink = true
        }
        return .handled
    }

    // UI Hilfsmethoden
    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [headerColor, .black.opacity(0.8)], startPoint: .top, endPoint: .bottom).frame(height: 220)
            HStack {
                Text(product?.id ?? lexikonEntry?.code ?? "MATJES").font(.system(size: 16, weight: .black, design: .monospaced)).foregroundColor(.white).padding(8).background(Color.black.opacity(0.6)).cornerRadius(8)
                Spacer()
                Text((product?.dataSource ?? lexikonEntry?.kategorie ?? "INFO").uppercased()).font(.caption.bold()).foregroundColor(.white.opacity(0.8)).padding(8).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white.opacity(0.5)))
            }.padding(20)
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text((product?.name ?? lexikonEntry?.name ?? "Unbekannt").uppercased()).font(.system(size: 30, weight: .black, design: .rounded))
            Text((product?.category ?? lexikonEntry?.kategorie ?? "FACHWISSEN").uppercased()).font(.callout.bold()).foregroundColor(headerColor).padding(.horizontal, 10).padding(.vertical, 4).background(headerColor.opacity(0.1)).cornerRadius(5)
        }.padding(25).frame(maxWidth: .infinity, alignment: .leading).background(Color(.secondarySystemGroupedBackground)).cornerRadius(24)
    }

    private var headerColor: Color {
        if lexikonEntry != nil { return .orange }
        return product?.dataSource == "Natur" ? .green : (product?.dataSource == "Hering" ? .blue : .orange)
    }

    private func safetyPanel(for p: Product) -> some View { EmptyView() }
    private var actionZone: some View { EmptyView() }
    private func nutritionGrid(for p: Product) -> some View { EmptyView() }
    private func extraInfoPanel(for p: Product) -> some View { EmptyView() }
    private func hannesRecipeCard(_ recipe: Recipe) -> some View { EmptyView() }
    private func initializeServings() { hasInitializedServings = true }
}

// MARK: - Die Weiche
struct UniversalDetailSelector: View {
    let queryID: String
    @Query private var products: [Product]
    @Query private var entries: [LexikonEntry]
    var body: some View {
        if let prod = products.first(where: { $0.id == queryID }) { ProductDetailView(product: prod) }
        else if let ent = entries.first(where: { $0.code == queryID }) { ProductDetailView(entry: ent) }
        else { SearchResultView(query: queryID) }
    }
}

// MARK: - SearchResultView (WICHTIG: Das hat gefehlt!)
struct SearchResultView: View {
    let query: String
    @Query private var allProducts: [Product]
    var body: some View {
        let results = allProducts.filter { $0.name.lowercased().contains(query.lowercased()) }
        List(results) { product in
            NavigationLink(destination: ProductDetailView(product: product)) {
                Text(product.name)
            }
        }.navigationTitle("Ergebnisse für \(query)")
    }
}
