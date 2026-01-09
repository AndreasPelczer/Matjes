import Foundation
import SwiftData

// 1. Die Haupt-Gussform
@Model
final class Product {
    @Attribute(.unique) var id: String
    var name: String
    var category: String
    var dataSource: String
    var beschreibung: String
    
    // Seubert / Infos
    var allergene: String = ""
    var zusatzstoffe: String = ""
    var kcal: String = ""
    var fett: String = ""
    var zucker: String = ""
    
    // Die "Hannes-Auffangschublade" für Temperatur etc.
    var zusatzInfos: [String: String] = [:]
    
    // DAS FEHLTE: Die Verbindung zum Rezept
    @Relationship(deleteRule: .cascade) var rezept: Recipe?
    
    init(id: String, name: String, category: String, dataSource: String) {
        self.id = id
        self.name = name
        self.category = category
        self.dataSource = dataSource
        self.beschreibung = ""
        self.zusatzInfos = [:]
    }
}

// 2. Der Bauplan für das Rezept (Muss in die gleiche Datei!)
@Model
final class Recipe {
    var portionen: String
    var algorithmus: [String]
    @Relationship(deleteRule: .cascade) var komponenten: [Ingredient]
    
    init(portionen: String, algorithmus: [String], komponenten: [Ingredient]) {
        self.portionen = portionen
        self.algorithmus = algorithmus
        self.komponenten = komponenten
    }
}

// 3. Die einzelnen Zutaten
@Model
final class Ingredient {
    var name: String
    var menge: String
    var einheit: String
    
    init(name: String, menge: String, einheit: String) {
        self.name = name
        self.menge = menge
        self.einheit = einheit
    }
}
