import SwiftUI
import SwiftData
import SafariServices

struct ProductDetailView: View {
    let product: Product?
    let lexikonEntry: LexikonEntry?
    
    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedDescription = ""
    @State private var selectedLinkID: String?
    @State private var navigateToLink = false
    @State private var activeURL: URL?
    @State private var showBrowser = false
    @Query private var allLexikonEntries: [LexikonEntry]

    init(product: Product) { self.product = product; self.lexikonEntry = nil }
    init(entry: LexikonEntry) { self.lexikonEntry = entry; self.product = nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                
                // 1. Header (Nutzt editedName oder den echten Namen)
                headerSection
                
                // 2. Buttons
                HStack(spacing: 12) {
                    actionButton(title: "YOUTUBE", icon: "play.rectangle.fill", color: .red) { openGastroSearch(prefix: "youtube.com/results?search_query=Profi+Kochen+") }
                    actionButton(title: "WIKI", icon: "book.fill", color: .gray) { openGastroSearch(prefix: "de.wikipedia.org/wiki/") }
                    actionButton(title: "GOOGLE", icon: "globe", color: .blue) { openGastroSearch(prefix: "google.com/search?q=Gastronomie+Warenkunde+") }
                }
                .padding(.horizontal)

                // 3. Sicherheit
                if let p = product, (!p.allergene.isEmpty || !p.zusatzstoffe.isEmpty) {
                    safetyPanel
                        .padding(.horizontal)
                }

                // 4. Beschreibung (Hier sitzt der Zentrale Edit-Button)
                infoBlock
                    .padding(.horizontal)

                // 5. Rezept & Nährwerte
                VStack(alignment: .leading, spacing: 25) {
                    if let recipe = product?.rezept {
                        recipeSection(for: recipe)
                    }
                    if let p = product, !p.kcal.isEmpty {
                        nutritionGrid(for: p)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(product?.name ?? lexikonEntry?.name ?? "Detail")
        .sheet(isPresented: $showBrowser) { if let url = activeURL { SafariWebView(url: url) } }
        .navigationDestination(isPresented: $navigateToLink) { if let id = selectedLinkID { UniversalDetailSelector(queryID: id) } }
    }

    // MARK: - LOGIK FUNKTIONEN
    
    private func startEditing() {
        editedName = product?.name ?? lexikonEntry?.name ?? ""
        editedDescription = product?.beschreibung ?? lexikonEntry?.beschreibung ?? ""
        isEditing = true
    }

    private func saveChanges() {
        // 1. Wachmacher senden & Daten schreiben
        if let p = product {
            p.objectWillChange.send()
            p.name = editedName
            p.beschreibung = editedDescription
        } else if let e = lexikonEntry {
            e.objectWillChange.send()
            e.name = editedName
            e.beschreibung = (editedDescription.isEmpty ? nil : editedDescription)
        }
        
        // 2. Permanent speichern
        try? product?.modelContext?.save()
        try? lexikonEntry?.modelContext?.save()
        
        // 3. Modus beenden
        isEditing = false
    }

    // MARK: - SUBVIEWS
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product?.category ?? lexikonEntry?.kategorie ?? "INFO")
                .font(.caption.bold())
                .padding(6).background(Color.blue).foregroundColor(.white).cornerRadius(4)
            
            if isEditing {
                TextField("Name korrigieren", text: $editedName)
                    .font(.largeTitle.bold())
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(.black)
            } else {
                Text(product?.name ?? lexikonEntry?.name ?? "")
                    .font(.largeTitle.bold())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LinearGradient(colors: [Color.blue.opacity(0.2), Color(.systemGroupedBackground)], startPoint: .top, endPoint: .bottom))
    }

    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("BESCHREIBUNG").font(.caption.bold()).foregroundColor(.secondary)
                Spacer()
                
                // DER ZENTRALE BUTTON
                Button(isEditing ? "Änderung speichern" : "Daten korrigieren") {
                    if isEditing {
                        saveChanges()
                    } else {
                        startEditing()
                    }
                }
                .font(.caption.bold())
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(isEditing ? Color.green : Color.blue.opacity(0.1))
                .foregroundColor(isEditing ? .white : .blue)
                .cornerRadius(6)
            }

            if isEditing {
                TextEditor(text: $editedDescription)
                    .frame(minHeight: 150)
                    .padding(4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue.opacity(0.5), lineWidth: 1))
            } else {
                Text(product?.beschreibung ?? lexikonEntry?.beschreibung ?? "Keine Daten.")
                    .font(.body).lineSpacing(4)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground)).cornerRadius(12)
    }

    // ... Restliche Subviews (safetyPanel, recipeSection etc.) und HILFSSTRUKTUREN am Ende bleiben gleich

    private var safetyPanel: some View {
            VStack(alignment: .leading, spacing: 0) {
                // 1. ALARM-HEADER
                HStack {
                    Image(systemName: "exclamationmark.octagon.fill")
                        .font(.title2.bold())
                    Text("ALLERGEN-CHECK")
                        .font(.headline.weight(.heavy))
                    Spacer()
                }
                .padding().background(Color.red).foregroundColor(.white)

                VStack(alignment: .leading, spacing: 20) {
                    // NUR DIE ALLERGENE (Das Wichtigste zuerst)
                    if let p = product, !p.allergene.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            let codes = p.allergene.components(separatedBy: ",")
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                            
                            // Jedes Allergen bekommt seine eigene, saubere Zeile
                            ForEach(codes, id: \.self) { code in
                                HStack(alignment: .top, spacing: 15) {
                                    // Das Kürzel: Eine rote, fette Box
                                    Text(code.uppercased())
                                        .font(.system(size: 18, weight: .black, design: .monospaced))
                                        .frame(width: 45, height: 35)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(6)
                                    
                                    // Die Erklärung: Direkt daneben, groß und klar
                                    Text(GastroLegende.erklärung(for: code).uppercased())
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.primary)
                                        .padding(.top, 6)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    // ZUSATZSTOFFE (Gleiches Prinzip, aber farblich dezenter)
                    if let p = product, !p.zusatzstoffe.isEmpty {
                        Divider().padding(.vertical, 5)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ZUSATZSTOFFE").font(.caption.bold()).foregroundColor(.secondary)
                            let zCodes = p.zusatzstoffe.components(separatedBy: ",")
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                            
                            ForEach(zCodes, id: \.self) { code in
                                HStack(alignment: .top, spacing: 15) {
                                    Text(code)
                                        .font(.system(size: 18, weight: .black, design: .monospaced))
                                        .frame(width: 45, height: 35)
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.primary)
                                        .cornerRadius(6)
                                    
                                    Text(GastroLegende.erklärung(for: code).uppercased())
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color.red.opacity(0.05))
            }
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 3))
        }
    
   
    // ... (Andere Hilfs-Views wie recipeSection, nutritionGrid, etc. bleiben wie gehabt)
    @ViewBuilder
    private func recipeSection(for recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("KÜCHEN-REZEPTUR").font(.caption.bold()).foregroundColor(.secondary)
            if let items = recipe.komponenten {
                ForEach(items) { item in
                    HStack {
                        Text(item.name).font(.subheadline)
                        Spacer()
                        Text("\(item.menge) \(item.einheit)").font(.subheadline.bold())
                    }
                    Divider()
                }
            }
        }
        .padding().background(Color(.secondarySystemGroupedBackground)).cornerRadius(12)
    }
    
    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack { Image(systemName: icon); Text(title).font(.caption2.bold()) }
            .frame(maxWidth: .infinity).padding(.vertical, 10).background(color.opacity(0.1)).foregroundColor(color).cornerRadius(8)
        }
    }

    @ViewBuilder
    private func nutritionGrid(for p: Product) -> some View {
        HStack {
            nutritionItem(label: "KCAL", value: p.kcal)
            nutritionItem(label: "FETT", value: p.fett)
            nutritionItem(label: "ZUCKER", value: p.zucker)
        }
    }

    private func nutritionItem(label: String, value: String) -> some View {
        VStack { Text(value).bold(); Text(label).font(.caption2) }.frame(maxWidth: .infinity).padding(8).background(Color.gray.opacity(0.1)).cornerRadius(8)
    }

    private func openGastroSearch(prefix: String) {
        let name = product?.name ?? lexikonEntry?.name ?? ""
        if let url = URL(string: "https://\(prefix)\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            self.activeURL = url; self.showBrowser = true
        }
    }
}

/// MARK: - HILFSSTRUKTUREN (Müssen am Ende der Datei stehen)

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct UniversalDetailSelector: View {
    let queryID: String
    @Query private var products: [Product]
    @Query private var entries: [LexikonEntry]
    var body: some View {
        if let p = products.first(where: { $0.id == queryID || $0.name.lowercased() == queryID.lowercased() }) {
            ProductDetailView(product: p)
        }
        else if let e = entries.first(where: { $0.code == queryID || $0.name.lowercased() == queryID.lowercased() }) {
            ProductDetailView(entry: e)
        }
        else {
            ContentUnavailableView("Nicht gefunden", systemImage: "magnifyingglass")
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += size.height + spacing
            }
            view.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
        }
    }
}

struct GastroLegende {
    static let allergene = [
        "a":"Gluten", "b":"Krebstiere", "c":"Eier", "d":"Fisch", "e":"Erdnüsse",
        "f":"Soja", "g":"Milch/Laktose", "h":"Nüsse", "i":"Sellerie",
        "j":"Senf", "k":"Sesam", "l":"Sulfite", "m":"Lupinen", "n":"Weichtiere"
    ]
    static func erklärung(for code: String) -> String {
        allergene[code.lowercased().trimmingCharacters(in: .whitespaces)] ?? "Zusatzstoff"
    }
}
