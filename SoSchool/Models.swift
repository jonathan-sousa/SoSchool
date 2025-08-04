import SwiftUI
import SwiftData

// MARK: - Modèles SwiftData

/// Modèle pour un enfant
@Model
final class Child {
    var firstName: String
    var level: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var scores: [Score] = []

    init(firstName: String, level: String = "débutant") {
        self.firstName = firstName
        self.level = level
        self.createdAt = Date()
    }
}

/// Modèle pour un exercice
@Model
final class Exercise {
    var id: String
    var type: String
    var verb: String
    var level: String
    var sentence: String
    var correctAnswer: String
    var options: [String]?
    var subject: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var scores: [Score] = []

    init(id: String = UUID().uuidString, type: String, verb: String, level: String, sentence: String, correctAnswer: String, options: [String]? = nil, subject: String) {
        self.id = id
        self.type = type
        self.verb = verb
        self.level = level
        self.sentence = sentence
        self.correctAnswer = correctAnswer
        self.options = options
        self.subject = subject
        self.createdAt = Date()
    }
}

/// Modèle pour un score
@Model
final class Score {
    var score: Int
    var maxScore: Int
    var completedAt: Date
    var elapsedTime: TimeInterval
    var child: Child?
    var exercise: Exercise?

    init(score: Int, maxScore: Int, elapsedTime: TimeInterval, completedAt: Date = Date()) {
        self.score = score
        self.maxScore = maxScore
        self.elapsedTime = elapsedTime
        self.completedAt = completedAt
    }
}

// MARK: - Extensions utilitaires

extension Child {
    var displayName: String {
        firstName
    }
}

extension Exercise {
    var displayName: String {
        "\(type) - \(level)"
    }
}

extension Score {
    var percentage: Double {
        guard maxScore > 0 else { return 0 }
        return Double(score) / Double(maxScore)
    }

    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
