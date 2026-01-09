//
//  LexikonEntry.swift
//  Matjes
//
//  Created by Senior-Entwickler (Mentor) am 06.01.26.
//

import Foundation
import SwiftData

/// LexikonEntry: Übersetzt Codes (E-Nummern, Allergene) in Klartext.
/// Architektur: Model (MVVM).
/// Dieses Modell dient als Nachschlagewerk für kryptische Kürzel in den Lieferantendaten.
@Model
class LexikonEntry {
    var code: String
    var name: String
    var kategorie: String?
    var beschreibung: String?
    var details: String? // Das Fragezeichen ist lebenswichtig!
    
    init(code: String, name: String, kategorie: String? = nil, beschreibung: String? = nil, details: String? = nil) {
        self.code = code
        self.name = name
        self.kategorie = kategorie
        self.beschreibung = beschreibung
        self.details = details
    }
}
