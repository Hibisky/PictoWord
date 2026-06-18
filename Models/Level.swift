// Models/Level.swift
// Représente un niveau / thème jouable dans PictoWord.
// Conforme à Codable pour être lu depuis le JSON seed,
// et à Identifiable pour les listes SwiftUI.

import Foundation
import GRDB

struct Level: Identifiable, Codable {

    // ─── Champs principaux ───────────────────────────────
    var id: String          // ex: "animaux_1"
    var name: String        // ex: "Animaux — Niveau 1"
    var theme: String       // ex: "animaux"
    var difficulty: Int     // 1 = facile · 2 = moyen · 3 = difficile
    var unlocked: Bool      // false = verrouillé (déblocable plus tard)

    // ─── Champs optionnels ───────────────────────────────
    var iconName: String?   // nom de l'image SF Symbol ou asset pour l'icône du thème
    var colorHex: String?   // couleur d'accent propre à ce thème (ex: "#A8D8EA")
    var description: String? // courte description affichée dans LevelPickerView
}

// ─── Conformité GRDB ────────────────────────────────────
// Permet à GRDB de lire / écrire un Level directement dans SQLite.

extension Level: FetchableRecord, PersistableRecord {

    // Nom de la table SQLite
    static var databaseTableName: String { "levels" }

    // Colonnes — miroir exact des propriétés ci-dessus
    enum Columns {
        static let id          = Column(CodingKeys.id)
        static let name        = Column(CodingKeys.name)
        static let theme       = Column(CodingKeys.theme)
        static let difficulty  = Column(CodingKeys.difficulty)
        static let unlocked    = Column(CodingKeys.unlocked)
        static let iconName    = Column(CodingKeys.iconName)
        static let colorHex    = Column(CodingKeys.colorHex)
        static let description = Column(CodingKeys.description)
    }
}

// ─── Helpers pratiques ──────────────────────────────────

extension Level {

    /// Retourne une couleur lisible pour la difficulté (utilisée dans l'UI)
    var difficultyLabel: String {
        switch difficulty {
        case 1: return "Facile"
        case 2: return "Moyen"
        case 3: return "Difficile"
        default: return "Inconnu"
        }
    }

    /// Niveau démo pour les previews SwiftUI
    static var preview: Level {
        Level(
            id: "animaux_1",
            name: "Animaux — Niveau 1",
            theme: "animaux",
            difficulty: 1,
            unlocked: true,
            iconName: "pawprint.fill",
            colorHex: "#A8D8EA",
            description: "Reconnais les animaux les plus connus !"
        )
    }
}