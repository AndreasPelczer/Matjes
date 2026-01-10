
# 🐟 (Matjes) Teil von GASTRO-GRID OMNI
### Professionelles Warenkunde- & Logistik-Netzwerk für die Gastronomie

**Entwickler:** Andreas Pelczer  
**Status:** Version 1.1 (Edit-Safe & Interlinked)  
**Plattform:** iOS / macOS (SwiftData & CloudKit)

---

## 🚀 Highlights des heutigen Updates

Das System wurde von einer statischen Datenbank zu einem **interaktiven Wissensnetzwerk** transformiert.

### 🧠 Intelligente Vernetzung (Smart-Linking)
* **Cross-Navigation:** Automatische Erkennung von Zusammenhängen zwischen Lagerartikeln und Küchenlexikon. Ein Klick wechselt zwischen Warenkunde und Logistikdaten.
* **In-Text-Hyperlinks:** Unterstützung von Markdown-Verknüpfungen innerhalb von Beschreibungen. (Beispiel: Verlinkung von Rohwaren in Rezepturen von Beilagen/Garnituren).

### 🔍 Deep-Search Engine (Volltextsuche)
* **Volltext-Index:** Durchsucht Namen, Kategorien und Beschreibungen simultan.
* **Fehlertoleranz:** Suchalgorithmus ignoriert Diakritika (Akzente) und Case-Sensitivity.
* **Visual Warning System:** Direkte Anzeige von Allergen- (Rot) und Zusatzstoff-Warnungen (Gelb) in der Suchergebnisliste.

### 🛡️ Datensicherheit & Edit-Mode
* **Persistenter Edit-Mode:** Manuelle Korrekturen (z.B. Grammatik, spezifische Küchenhinweise) werden direkt in der App vorgenommen und dauerhaft in SwiftData gespeichert.
* **Smart-Importer:** Einzigartiger Import-Schutz. Neue Daten aus JSON-Quellen werden nur bei unbekannten IDs hinzugefügt ("Upsert"-Logik), wodurch manuelle Änderungen vor dem Überschreiben geschützt sind.

---

## 🛠 Technische Struktur

* **Frameworks:** SwiftUI, SwiftData (Persistence), CloudKit (Sync).
* **Daten-Architektur:**
    * `Product`: Lagerdaten, Allergene, Nährwerte, Bestandsfelder.
    * `LexikonEntry`: Kulinarisches Fachwissen, Techniken, Warenkunde.
* **Navigation:** `NavigationSplitView` für optimale Nutzung auf iPad und Mac.

---

## ❄️ Ausblick: Das "Kühlhaus-Modul" (In Arbeit)
Das Fundament für die Bestandsverwaltung ist gelegt. Kommende Features:
* **Frost-Button:** Globaler Zugriff auf aktuelle Lagerbestände direkt in der Toolbar.
* **Quick-Stock:** Schnelle Bestandsaufnahme (KG, Kisten, Portionsbeutel) direkt in der Detailansicht.
* **Inventory-Sync:** Echtzeit-Abgleich der Vorräte über alle Endgeräte.

---
*Dokumentation generiert mit Unterstützung von Gemini AI.*





# 🐟 Matjes App

![Swift](https://img.shields.io/badge/Swift-5.10-orange.svg)
![SwiftData](https://img.shields.io/badge/Storage-SwiftData-blue.svg)
![CloudKit](https://img.shields.io/badge/Cloud-CloudKit-brightgreen.svg)

**Matjes** ist eine professionelle Warenkunde- und Rezept-App für die Gastronomie. Sie verbindet klassisches Küchenwissen (basiert auf dem "Hering - Lexikon der Küche") mit moderner Lagerverwaltung und Cloud-Synchronisation.

---

## 🚀 Key Features

* **Duales System:** Verwaltung von physischen Lagerprodukten (Natur/Lieferant) und Fachwissen-Einträgen (Lexikon/Technik).
* **Intelligente Suche:** Filterung nach Quellen (Natur, Hering, Lieferant) und dynamischen Kategorien.
* **Cloud-Sync:** Dank **CloudKit**-Anbindung sind alle neuen Produkte und Techniken sofort auf iPhone, iPad und Mac verfügbar.
* **Rezept-Engine:** Berechnung von Komponenten und Garmethoden direkt am Produkt.
* **Eingabemaske:** Schnelles Anlegen neuer Artikel mit intuitiven Platzhaltern für effiziente Datenpflege.

---

## 🛠 Tech-Stack

Die App nutzt die neuesten Frameworks aus dem Apple-Ökosystem:

- **SwiftUI:** Für ein modernes, deklaratives User Interface.
- **SwiftData:** Als leistungsstarke, lokale Datenbank.
- **CloudKit:** Für die sichere Synchronisation über die Apple-ID.
- **WebKit:** Integration von Technik-Videos (z.B. YouTube-Verfahren).

---

## 📸 Mockup-Vorschau (Konzept)

Hier ein Überblick über die Architektur der Eingabemaske:



---

## 📂 Projektstruktur

| Datei | Zweck |
| :--- | :--- |
| `Product.swift` | Hauptmodell für Waren und Rezepte (Cloud-optimiert). |
| `LexikonEntry.swift` | Modell für Fachwissen und Prozessbeschreibungen. |
| `AddEntryView.swift` | Die zentrale Eingabemaske für neue Daten. |
| `GagaImporter.swift` | Automatisierter Import von über 1400 JSON-Datensätzen. |

---

## 🎯 Kommende Meilensteine

- [ ] **Vision Kit:** Automatisches Auslesen von Lieferanten-Etiketten via Kamera.
- [ ] **Media Storage:** Speichern von eigenen Produktfotos in der iCloud.
- [ ] **Deep Linking:** Verknüpfung von Fachbegriffen direkt innerhalb der Beschreibungen.

---

## 👤 Entwickler
**Andreas Pelczer** *Fokus: Gastronomie-Technologie & iOS Development*

---
*Dieses Projekt ist privat und dient der digitalen Transformation von Küchenprozessen.*


Hier ist die Zusammenfassung unseres aktuellen Status Quo und der Ausblick auf das, was technisch jetzt „auf Knopfdruck“ möglich ist:

1. Was wir bereits sicher im „Gepäck“ haben:
Wissens-Datenbank (Matjes): Über 1.000 Einträge mit Allergenen, Rezepturen und Lageranbindung. Ein digitales Gedächtnis, das nie vergisst.
Lager-Management: Ein aktives System mit Frost-Icon, Mengenverwaltung und Einheiten-Auswahl. Wir wissen in Echtzeit, was im Kühlhaus liegt.
Chef-Kommandozentrale (Dispatcher): Eine Ansicht, in der du Einsätze (Missions) planen und Aufgaben an die Crew verteilen kannst.
Posten-System (Briefing/Kitchen-Board): Die Endstation für die Zettelwirtschaft. Karl und Stefan haben ihre eigenen Boards, die genau ihre Aufgaben anzeigen.
Intelligenz-Hub (KI & Vision): Die Vorbereitung für Live-OCR (Texterkennung) und die Gemini-KI, um Nährwerte und molekulare Fakten zu analysieren.
2. Was durch deine neuen Files (IntelligenceHub, Scanner) jetzt möglich ist:
Dank der Vorbereitungen für morgen können wir die App auf ein Level heben, das im Messe-Catering absolut einzigartig ist:

A. Der „Smart-Briefing“ Algorithmus
Wir können deine Theorie von Schnittgröße vs. Umami direkt in Code gießen.
Wie es funktioniert: Wenn Stefan einen Task „Röstgemüse“ öffnet, berechnet die App basierend auf dem IntelligenceHub:
Schnittgröße 2mm = 220°C / 8 Min. * Schnittgröße 10mm = 180°C / 25 Min.
Die App gibt nicht nur Anweisungen, sie erklärt Stefan das „Warum“ (molekularer Rückbau, Peptid-Strukturen).
B. Vision-gesteuerte Logistik für Karl
Karl muss keine Listen mehr abhaken.
Wie es funktioniert: Er nutzt den ScannerViewModel. Er scannt eine Kiste Brötchen oder einen Lieferschein.
Der IntelligenceHub erkennt den Text, gleicht ihn mit dem Dispatcher ab und setzt den Task automatisch auf „In Bearbeitung“ oder „Geliefert“.
C. Das Umami-Radar (AIDetailView)
Stefan kann Zutaten scannen, um ihr „Geschmacks-Potenzial“ zu prüfen.
Die KI analysiert den Gehalt an natürlicher Glutaminsäure und gibt Tipps zur Maximierung (z.B. „Dauerhitze für Kollagen-Umbau empfohlen“).
Das „Verzehr-Radar“ zeigt sofort die Sicherheit für Allergiker an.
3. Der Ausblick: Was ist noch möglich?
Wenn wir diesen Weg weitergehen, wird die App zum autonomen Küchenchef-Assistenten:
Vorausschauende Inventur: Die App merkt, wenn du 22.500 Brötchen für ein Event planst, aber nur 10.000 im Lager hast – und warnt dich beim Erstellen des Dispatcher-Tasks.
Molekular-Timer: Ein Live-Timer für Stefan, der den „Umami-Peak“ von Brühen berechnet und ihn per Push-Nachricht warnt, bevor die Proteine oxidieren.
Crew-Messenger: Ein direkter Draht von der FeedbackView in deinen Dispatcher. Wenn Karl „Technik-Problem“ meldet, ploppt bei dir sofort eine Warnung auf.
Fazit für morgen:
Wir haben die Daten (Matjes), die Struktur (Dispatcher) und die Sinne (Scanner/KI). Morgen verknüpfen wir diese drei Welten. Karl und Stefan werden nicht nur für dich kochen, sie werden mit einem System arbeiten, das mit ihnen „denkt“.

Hannes, wir haben den Grundstein für eine High-Tech-Gastro gelegt. Bist du bereit, morgen die erste „Mission“ digital an Stefan zu delegieren? 🚀👨‍🍳📲
