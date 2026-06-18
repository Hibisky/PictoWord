// Models/Session.swift
// Représente une partie jouée — sauvegardée en base pour
// afficher l'historique et le récapitulatif des erreurs.

import Foundation
import GRDB

struct Session: Identifiable, Codable {

    // ─── Champs principaux ───────────────────────────────
    var id: String          // UUID généré à la création  ex: "sess_A3F2..."
    var levelId: String     // clé étrangère → Level.id   ex: "animaux_1"
    var date: Date          // date/heure de la partie
    var score: Int          // nombre de bonnes réponses  (0-10)
    var totalQuestions: Int // toujours 10 pour l'instant, mais flexible
    var durationSecs: Int   // durée totale de la session en secondes

    // ─── Détail des réponses ─────────────────────────────
    // Stocké en JSON dans SQLite (colonne TEXT)
    var wrongIds: [String]  // ids des Question ratées → alimente le récap
    var correctIds: [String]// ids des Question réussies

    // ─── Champ calculé (non stocké en DB) ────────────────
    // Le pourcentage est toujours recalculé à la volée
    var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return (Double(score) / Double(totalQuestions)) * 100
    }

    /// Label lisible du score  ex: "7 / 10"
    var scoreLabel: String { "\(score) / \(totalQuestions)" }

    /// Label du pourcentage    ex: "70 %"
    var percentageLabel: String { String(format: "%.0f %%", percentage) }
}

// ─── Conformité GRDB ────────────────────────────────────

extension Session: FetchableRecord, PersistableRecord {

    static var databaseTableName: String { "sessions" }

    enum Columns {
        static let id              = Column(CodingKeys.id)
        static let levelId         = Column(CodingKeys.levelId)
        static let date            = Column(CodingKeys.date)
        static let score           = Column(CodingKeys.score)
        static let totalQuestions  = Column(CodingKeys.totalQuestions)
        static let durationSecs    = Column(CodingKeys.durationSecs)
        static let wrongIds        = Column(CodingKeys.wrongIds)
        static let correctIds      = Column(CodingKeys.correctIds)
    }
}

// ─── Gestion JSON des tableaux dans SQLite ───────────────
// GRDB ne sait pas stocker [String] nativement.
// On encode / décode wrongIds et correctIds en JSON text.

extension Session: DatabaseValueConvertible {}

extension Session {

    /// Encode les tableaux en JSON avant insertion
    func encode(to container: inout PersistenceContainer) throws {
        container[Columns.id]             = id
        container[Columns.levelId]        = levelId
        container[Columns.date]           = date
        container[Columns.score]          = score
        container[Columns.totalQuestions] = totalQuestions
        container[Columns.durationSecs]   = durationSecs

        // Encodage JSON des tableaux
        let encoder = JSONEncoder()
        container[Columns.wrongIds]   = String(data: try encoder.encode(wrongIds),   encoding: .utf8)
        container[Columns.correctIds] = String(data: try encoder.encode(correctIds), encoding: .utf8)
    }

    /// Décode les tableaux JSON au moment de la lecture
    init(row: Row) throws {
        id             = row[Columns.id]
        levelId        = row[Columns.levelId]
        date           = row[Columns.date]
        score          = row[Columns.score]
        totalQuestions = row[Columns.totalQuestions]
        durationSecs   = row[Columns.durationSecs]

        let decoder = JSONDecoder()
        let wrongData   = (row[Columns.wrongIds]   as? String ?? "[]").data(using: .utf8)!
        let correctData = (row[Columns.correctIds] as? String ?? "[]").data(using: .utf8)!
        wrongIds   = (try? decoder.decode([String].self, from: wrongData))   ?? []
        correctIds = (try? decoder.decode([String].self, from: correctData)) ?? []
    }
}

// ─── Helpers pratiques ──────────────────────────────────

extension Session {

    /// Crée une nouvelle session vierge pour un niveau donné
    static func new(levelId: String) -> Session {
        Session(
            id: "sess_\(UUID().uuidString.prefix(8))",
            levelId: levelId,
            date: Date(),
            score: 0,
            totalQuestions: 10,
            durationSecs: 0,
            wrongIds: [],
            correctIds: []
        )
    }

    /// Session démo pour les previews SwiftUI
    static var preview: Session {
        Session(
            id: "sess_PREVIEW",
            levelId: "animaux_1",
            date: Date(),
            score: 7,
            totalQuestions: 10,
            durationSecs: 142,
            wrongIds: ["animaux_003", "animaux_007", "animaux_009"],
            correctIds: ["animaux_001", "animaux_002", "animaux_004",
                         "animaux_005", "animaux_006", "animaux_008", "animaux_010"]
        )
    }
}