//
//  ExerciseData.swift
//  SoSchool
//
//  Created by Jonathan Sousa on 03/08/2025.
//

import Foundation
import SwiftData
import SwiftUI

/// Types d'exercices disponibles
enum ExerciseType: String, CaseIterable {
    case qcm = "QCM"
    case complete = "Compléter"
    case match = "Associer"
    case memory = "Memory"
    case puzzle = "Puzzle"

    var displayName: String {
        return self.rawValue
    }

    var systemImage: String {
        switch self {
        case .qcm:
            return "questionmark.circle.fill"
        case .complete:
            return "text.insert"
        case .match:
            return "link"
        case .memory:
            return "square.grid.2x2.fill"
        case .puzzle:
            return "puzzlepiece"
        }
    }
}

/// Niveaux de difficulté
enum Level: String, CaseIterable {
    case beginner = "débutant"
    case intermediate = "intermédiaire"
    case expert = "expert"

    var displayName: String {
        return self.rawValue
    }

    var color: Color {
        switch self {
        case .beginner:
            return .green
        case .intermediate:
            return .orange
        case .expert:
            return .red
        }
    }
}

/// Verbes disponibles
enum Verb: String, CaseIterable {
    case avoir = "avoir"
    case etre = "être"
    case aller = "aller"
}

/// Structure pour les données d'exercice
struct ExerciseDataModel {
    let id: String
    let type: String
    let verb: String
    let level: String
    let sentence: String
    let correctAnswer: String
    let options: [String]
    let subject: String
}

/// Structure pour les combinaisons cohérentes
struct CoherentCombination {
    let subject: String
    let verb: Verb
    let complement: String
    let correctAnswer: String
    let sentence: String
}

/// Gestionnaire des exercices
struct ExerciseData {

    // MARK: - Configuration

    /// Nombre d'exercices par session (configurable)
    static let exercisesPerSession = 20

    // MARK: - Matrice de données pour génération aléatoire

    /// Sujets disponibles avec leurs propriétés
    private static let subjects = [
        SubjectData(pronoun: "je", display: "Je", isPlural: false, gender: .masculine),
        SubjectData(pronoun: "tu", display: "Tu", isPlural: false, gender: .masculine),
        SubjectData(pronoun: "il", display: "Il", isPlural: false, gender: .masculine),
        SubjectData(pronoun: "elle", display: "Elle", isPlural: false, gender: .feminine),
        SubjectData(pronoun: "nous", display: "Nous", isPlural: true, gender: .masculine),
        SubjectData(pronoun: "vous", display: "Vous", isPlural: true, gender: .masculine),
        SubjectData(pronoun: "ils", display: "Ils", isPlural: true, gender: .masculine),
        SubjectData(pronoun: "elles", display: "Elles", isPlural: true, gender: .feminine)
    ]

    /// Compléments pour "avoir" (objets possédés)
    private static let avoirComplements = [
        "un chat", "une voiture", "un chien", "une maison", "un jardin",
        "des amis", "des jouets", "un livre", "une télévision", "un téléphone",
        "un ordinateur", "une bicyclette", "un ballon", "une poupée", "un robot",
        "des crayons", "un sac", "une montre", "des bonbons", "un gâteau"
    ]

    /// Compléments pour "être" (adjectifs)
    private static let etreComplements = [
        ComplementData(text: "content", masculine: true, singular: true),
        ComplementData(text: "contente", masculine: false, singular: true),
        ComplementData(text: "contents", masculine: true, singular: false),
        ComplementData(text: "contentes", masculine: false, singular: false),
        ComplementData(text: "grand", masculine: true, singular: true),
        ComplementData(text: "grande", masculine: false, singular: true),
        ComplementData(text: "grands", masculine: true, singular: false),
        ComplementData(text: "grandes", masculine: false, singular: false),
        ComplementData(text: "petit", masculine: true, singular: true),
        ComplementData(text: "petite", masculine: false, singular: true),
        ComplementData(text: "petits", masculine: true, singular: false),
        ComplementData(text: "petites", masculine: false, singular: false),
        ComplementData(text: "amical", masculine: true, singular: true),
        ComplementData(text: "amicale", masculine: false, singular: true),
        ComplementData(text: "amicaux", masculine: true, singular: false),
        ComplementData(text: "amicales", masculine: false, singular: false),
        ComplementData(text: "gentil", masculine: true, singular: true),
        ComplementData(text: "gentille", masculine: false, singular: true),
        ComplementData(text: "gentils", masculine: true, singular: false),
        ComplementData(text: "gentilles", masculine: false, singular: false),
        ComplementData(text: "fort", masculine: true, singular: true),
        ComplementData(text: "forte", masculine: false, singular: true),
        ComplementData(text: "forts", masculine: true, singular: false),
        ComplementData(text: "fortes", masculine: false, singular: false),
        ComplementData(text: "joli", masculine: true, singular: true),
        ComplementData(text: "jolie", masculine: false, singular: true),
        ComplementData(text: "jolis", masculine: true, singular: false),
        ComplementData(text: "jolies", masculine: false, singular: false),
        ComplementData(text: "intelligent", masculine: true, singular: true),
        ComplementData(text: "intelligente", masculine: false, singular: true),
        ComplementData(text: "intelligents", masculine: true, singular: false),
        ComplementData(text: "intelligentes", masculine: false, singular: false),
        ComplementData(text: "fatigué", masculine: true, singular: true),
        ComplementData(text: "fatiguée", masculine: false, singular: true),
        ComplementData(text: "fatigués", masculine: true, singular: false),
        ComplementData(text: "fatiguées", masculine: false, singular: false),
        ComplementData(text: "heureux", masculine: true, singular: true),
        ComplementData(text: "heureuse", masculine: false, singular: true),
        ComplementData(text: "heureux", masculine: true, singular: false),
        ComplementData(text: "heureuses", masculine: false, singular: false),
        ComplementData(text: "triste", masculine: true, singular: true),
        ComplementData(text: "triste", masculine: false, singular: true),
        ComplementData(text: "tristes", masculine: true, singular: false),
        ComplementData(text: "tristes", masculine: false, singular: false),
        ComplementData(text: "malade", masculine: true, singular: true),
        ComplementData(text: "malade", masculine: false, singular: true),
        ComplementData(text: "malades", masculine: true, singular: false),
        ComplementData(text: "malades", masculine: false, singular: false)
    ]

    /// Compléments pour "aller" (destinations)
    private static let allerComplements = [
        "à l'école", "au parc", "à la maison", "au magasin", "au cinéma",
        "au restaurant", "au musée", "au théâtre", "à la plage", "à la montagne",
        "à la bibliothèque", "au zoo", "à l'hôpital", "au marché", "à la piscine",
        "au stade", "à l'église", "au café", "à la gare", "à l'aéroport"
    ]

    /// Conjugaisons par verbe et sujet
    private static let conjugations: [Verb: [String: String]] = [
        .avoir: [
            "je": "ai",
            "tu": "as",
            "il": "a",
            "elle": "a",
            "nous": "avons",
            "vous": "avez",
            "ils": "ont",
            "elles": "ont"
        ],
        .etre: [
            "je": "suis",
            "tu": "es",
            "il": "est",
            "elle": "est",
            "nous": "sommes",
            "vous": "êtes",
            "ils": "sont",
            "elles": "sont"
        ],
        .aller: [
            "je": "vais",
            "tu": "vas",
            "il": "va",
            "elle": "va",
            "nous": "allons",
            "vous": "allez",
            "ils": "vont",
            "elles": "vont"
        ]
    ]

    /// Options incorrectes par verbe
    private static let incorrectOptions: [Verb: [String]] = [
        .avoir: ["as", "a", "avons", "avez", "ont"],
        .etre: ["es", "est", "sommes", "êtes", "sont"],
        .aller: ["vas", "va", "allons", "allez", "vont"]
    ]

    // MARK: - Structures de données

    /// Données d'un sujet
    struct SubjectData {
        let pronoun: String
        let display: String
        let isPlural: Bool
        let gender: Gender
    }

    /// Genre grammatical
    enum Gender {
        case masculine
        case feminine
    }

    /// Données d'un complément
    struct ComplementData {
        let text: String
        let masculine: Bool
        let singular: Bool
    }

    // MARK: - Génération aléatoire basée sur matrice

    /// Générer une combinaison cohérente aléatoire
    private static func generateRandomCombination() -> CoherentCombination {
        // 1. Choisir un sujet aléatoire
        let randomSubject = subjects.randomElement()!

        // 2. Choisir un verbe aléatoire
        let randomVerb = Verb.allCases.randomElement()!

        // 3. Obtenir la conjugaison correcte
        let correctAnswer = conjugations[randomVerb]![randomSubject.pronoun]!

        // 4. Choisir un complément approprié selon le verbe et les propriétés du sujet
        let complement: String
        switch randomVerb {
        case .avoir:
            complement = avoirComplements.randomElement()!
        case .etre:
            // Filtrer les compléments selon le genre et le nombre du sujet
            let matchingComplements = etreComplements.filter { complement in
                complement.masculine == (randomSubject.gender == .masculine) &&
                complement.singular == !randomSubject.isPlural
            }
            complement = matchingComplements.randomElement()!.text
        case .aller:
            complement = allerComplements.randomElement()!
        }

        // 5. Construire la phrase avec le bon format
        let sentence: String
        if randomSubject.pronoun == "je" && randomVerb == .avoir {
            // Seuls "avoir" commence par une voyelle et nécessitent "J'"
            sentence = "J'___ \(complement)"
        } else {
            sentence = "\(randomSubject.display) ___ \(complement)"
        }

        return CoherentCombination(
            subject: randomSubject.pronoun,
            verb: randomVerb,
            complement: complement,
            correctAnswer: correctAnswer,
            sentence: sentence
        )
    }

    /// Générer des options aléatoires incluant la bonne réponse
    private static func generateRandomOptions(for verb: Verb, correctAnswer: String) -> [String] {
        var options = [correctAnswer]
        let incorrectOptions = Self.incorrectOptions[verb]!

        // Ajouter 2 options incorrectes aléatoires
        while options.count < 3 {
            let randomOption = incorrectOptions.randomElement()!
            if !options.contains(randomOption) {
                options.append(randomOption)
            }
        }

        // Mélanger les options
        return options.shuffled()
    }

    /// Générer un exercice QCM aléatoire
    private static func generateRandomQCMExercise(level: Level = .beginner) -> ExerciseDataModel {
        let combination = generateRandomCombination()
        let options = generateRandomOptions(for: combination.verb, correctAnswer: combination.correctAnswer)

        return ExerciseDataModel(
            id: "random_qcm_\(combination.subject)_\(combination.verb.rawValue)_\(Date().timeIntervalSince1970)",
            type: ExerciseType.qcm.rawValue,
            verb: combination.verb.rawValue,
            level: level.rawValue,
            sentence: combination.sentence,
            correctAnswer: combination.correctAnswer,
            options: options,
            subject: combination.subject
        )
    }

    /// Créer les exercices de base dans SwiftData pour un niveau spécifique
    static func createDefaultExercises(modelContext: ModelContext, for level: Level, exerciseType: ExerciseType) {
        print("📝 Début de la création des exercices pour \(exerciseType.rawValue) - \(level.rawValue)")

        // Créer des exercices QCM aléatoires pour le niveau spécifique
        print("📚 Création de \(exercisesPerSession) exercices pour le niveau : \(level.rawValue)")
        for i in 0..<exercisesPerSession {
            let exerciseData = generateRandomQCMExercise(level: level)
            print("  - Exercice \(i+1)/\(exercisesPerSession) : \(exerciseData.sentence)")

            let exercise = Exercise(
                id: exerciseData.id,
                type: exerciseData.type,
                verb: exerciseData.verb,
                level: exerciseData.level,
                sentence: exerciseData.sentence,
                correctAnswer: exerciseData.correctAnswer,
                options: exerciseData.options,
                subject: exerciseData.subject
            )
            modelContext.insert(exercise)
        }
        print("✅ \(exercisesPerSession) exercices créés pour le niveau \(level.rawValue)")

        do {
            try modelContext.save()
            print("✅ \(exercisesPerSession) exercices QCM créés avec succès pour \(exerciseType.rawValue) - \(level.rawValue)")
        } catch {
            print("❌ Erreur lors de la création des exercices : \(error)")
        }
    }

    /// Générer des exercices à la volée (sans stockage en base)
    static func generateExercisesForLevel(_ level: Level, exerciseType: ExerciseType, count: Int) -> [ExerciseDataModel] {
        print("📚 Génération de \(count) exercices à la volée pour le niveau : \(level.rawValue)")

        var generatedExercises: [ExerciseDataModel] = []

        for i in 0..<count {
            let exerciseData = generateRandomQCMExercise(level: level)
            print("  - Exercice \(i+1)/\(count) : \(exerciseData.sentence)")
            generatedExercises.append(exerciseData)
        }

        print("✅ \(count) exercices générés à la volée pour le niveau \(level.rawValue)")
        return generatedExercises
    }
}
