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

/// Types d'exercices complexes
enum ComplexExerciseType {
    case simple // Niveau débutant actuel
    case withContext // Niveau intermédiaire
    case withNegation // Niveau intermédiaire
    case withAdverbs // Niveau intermédiaire
    case withSubordinate // Niveau expert
    case multiVerb // Niveau expert
    case compoundTense // Niveau expert
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

    // MARK: - Nouvelles données pour niveaux avancés

    /// Contextes temporels pour niveau intermédiaire (raccourcis)
    private static let intermediateContexts = [
        "Aujourd'hui, ",
        "Maintenant, ",
        "Ce matin, ",
        "Ce soir, "
    ]

    /// Phrases subordonnées pour niveau expert (raccourcies)
    private static let expertSubordinateClauses = [
        "Quand il fait beau, ",
        "Si tu veux, ",
        "Avant de partir, ",
        "Après le travail, ",
        "Pendant le cours, "
    ]

    /// Adverbes pour niveau intermédiaire (raccourcis)
    private static let adverbs = [
        "toujours",
        "souvent",
        "maintenant",
        "ici",
        "là"
    ]

    /// Compléments complexes pour niveau expert (raccourcis)
    private static let expertComplements = [
        "une analyse",
        "une réflexion",
        "une expérience",
        "une discussion",
        "une décision",
        "une observation",
        "une étude",
        "une recherche",
        "une évaluation"
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

    /// Donnée pour un prénom (nom propre)
    struct NameSubject {
        let display: String      // ex: "Emma", "Lucas et Inès"
        let pronoun: String      // ex: "il", "elle", "ils", "elles"
        let gender: Gender
        let isPlural: Bool
    }

    /// Prénoms disponibles
    private static let singleNames: [NameSubject] = [
        NameSubject(display: "Emma", pronoun: "elle", gender: .feminine, isPlural: false),
        NameSubject(display: "Léa", pronoun: "elle", gender: .feminine, isPlural: false),
        NameSubject(display: "Chloé", pronoun: "elle", gender: .feminine, isPlural: false),
        NameSubject(display: "Inès", pronoun: "elle", gender: .feminine, isPlural: false),
        NameSubject(display: "Lucas", pronoun: "il", gender: .masculine, isPlural: false),
        NameSubject(display: "Noah", pronoun: "il", gender: .masculine, isPlural: false),
        NameSubject(display: "Hugo", pronoun: "il", gender: .masculine, isPlural: false),
        NameSubject(display: "Adam", pronoun: "il", gender: .masculine, isPlural: false)
    ]

    /// Retourne un duo de prénoms et le bon pronom (ils/elles) selon le genre
    private static func randomNameGroup() -> NameSubject {
        let name1 = singleNames.randomElement()!
        var name2 = singleNames.randomElement()!
        // éviter doublon exact pour un peu de variété
        var attempts = 0
        while name2.display == name1.display && attempts < 3 {
            name2 = singleNames.randomElement()!
            attempts += 1
        }
        let bothFeminine = (name1.gender == .feminine && name2.gender == .feminine)
        let pronoun = bothFeminine ? "elles" : "ils"
        let gender: Gender = bothFeminine ? .feminine : .masculine
        return NameSubject(
            display: "\(name1.display) et \(name2.display)",
            pronoun: pronoun,
            gender: gender,
            isPlural: true
        )
    }

    /// Construire un SubjectData éphémère depuis NameSubject pour réutiliser les helpers
    private static func subjectData(from name: NameSubject) -> SubjectData {
        // map pronoun déjà compatible avec les clés de conjugaison
        return SubjectData(pronoun: name.pronoun, display: name.display, isPlural: name.isPlural, gender: name.gender)
    }

    /// Retourne un adjectif compatible avec le sujet pour "être"
    private static func randomEtreAdjective(for subject: SubjectData) -> String {
        let matches = etreComplements.filter { comp in
            comp.masculine == (subject.gender == .masculine) && comp.singular == !subject.isPlural
        }
        return matches.randomElement()?.text ?? (subject.isPlural ? (subject.gender == .feminine ? "contentes" : "contents") : (subject.gender == .feminine ? "contente" : "content"))
    }

    /// Génère un complément adapté au verbe et au sujet
    private static func randomComplement(for verb: Verb, subject: SubjectData) -> String {
        switch verb {
        case .etre:
            return randomEtreAdjective(for: subject)
        case .avoir:
            return avoirComplements.randomElement()!
        case .aller:
            return allerComplements.randomElement()!
        }
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

    // MARK: - Nouvelles fonctions de génération par niveau

    /// Générer un exercice QCM aléatoire selon le niveau
    private static func generateRandomQCMExercise(level: Level = .beginner) -> ExerciseDataModel {
        switch level {
        case .beginner:
            return generateBeginnerExercise()
        case .intermediate:
            return generateIntermediateExercise()
        case .expert:
            return generateExpertExercise()
        }
    }

    /// Générer un exercice de niveau débutant (logique actuelle)
    private static func generateBeginnerExercise() -> ExerciseDataModel {
        let combination = generateRandomCombination()
        let options = generateRandomOptions(for: combination.verb, correctAnswer: combination.correctAnswer)

        return ExerciseDataModel(
            id: "beginner_\(combination.subject)_\(combination.verb.rawValue)_\(Date().timeIntervalSince1970)",
            type: ExerciseType.qcm.rawValue,
            verb: combination.verb.rawValue,
            level: Level.beginner.rawValue,
            sentence: combination.sentence,
            correctAnswer: combination.correctAnswer,
            options: options,
            subject: combination.subject
        )
    }

    /// Générer un exercice de niveau intermédiaire
    private static func generateIntermediateExercise() -> ExerciseDataModel {
        let exerciseType = [ComplexExerciseType.withContext,
                           ComplexExerciseType.withNegation,
                           ComplexExerciseType.withAdverbs].randomElement()!

        switch exerciseType {
        case .withContext:
            return generateContextExercise()
        case .withNegation:
            return generateNegationExercise()
        case .withAdverbs:
            return generateAdverbExercise()
        default:
            return generateBeginnerExercise() // Fallback
        }
    }

    /// Générer un exercice de niveau expert
    private static func generateExpertExercise() -> ExerciseDataModel {
        // Variantes simples mais plus riches (multi‑verbes supprimé)
        enum ExpertVariant { case nameSimple, nameWithAdverb, nameGroup }
        let variant: ExpertVariant = [ .nameSimple, .nameWithAdverb, .nameGroup ].randomElement()!

        switch variant {
        case .nameSimple:
            return generateExpertNameSimple()
        case .nameWithAdverb:
            return generateExpertNameWithAdverb()
        case .nameGroup:
            return generateExpertNameGroup()
        }
    }

    /// Expert: prénom simple + verbe + complément
    private static func generateExpertNameSimple() -> ExerciseDataModel {
        let name = singleNames.randomElement()!
        let subject = subjectData(from: name)
        let verb = Verb.allCases.randomElement()!
        let correctAnswer = conjugations[verb]![subject.pronoun]!
        let complement = randomComplement(for: verb, subject: subject)

        let sentence = "\(name.display) ___ \(complement)"
        let options = generateRandomOptions(for: verb, correctAnswer: correctAnswer)

        return ExerciseDataModel(
            id: "expert_name_\(Date().timeIntervalSince1970)",
            type: ExerciseType.qcm.rawValue,
            verb: verb.rawValue,
            level: Level.expert.rawValue,
            sentence: sentence,
            correctAnswer: correctAnswer,
            options: options,
            subject: subject.pronoun
        )
    }

    /// Expert: prénom + adverbe de fréquence
    private static func generateExpertNameWithAdverb() -> ExerciseDataModel {
        let name = singleNames.randomElement()!
        let subject = subjectData(from: name)
        let verb = Verb.allCases.randomElement()!
        let correctAnswer = conjugations[verb]![subject.pronoun]!
        let adverb = adverbs.randomElement()!
        let complement = randomComplement(for: verb, subject: subject)

        let sentence = "\(name.display) ___ \(adverb) \(complement)"
        let options = generateRandomOptions(for: verb, correctAnswer: correctAnswer)

        return ExerciseDataModel(
            id: "expert_name_adverb_\(Date().timeIntervalSince1970)",
            type: ExerciseType.qcm.rawValue,
            verb: verb.rawValue,
            level: Level.expert.rawValue,
            sentence: sentence,
            correctAnswer: correctAnswer,
            options: options,
            subject: subject.pronoun
        )
    }

    /// Expert: deux prénoms coordonnés
    private static func generateExpertNameGroup() -> ExerciseDataModel {
        let group = randomNameGroup()
        let subject = subjectData(from: group)
        let verb = Verb.allCases.randomElement()!
        let correctAnswer = conjugations[verb]![subject.pronoun]!
        let complement = randomComplement(for: verb, subject: subject)

        let sentence = "\(group.display) ___ \(complement)"
        let options = generateRandomOptions(for: verb, correctAnswer: correctAnswer)

        return ExerciseDataModel(
            id: "expert_group_\(Date().timeIntervalSince1970)",
            type: ExerciseType.qcm.rawValue,
            verb: verb.rawValue,
            level: Level.expert.rawValue,
            sentence: sentence,
            correctAnswer: correctAnswer,
            options: options,
            subject: subject.pronoun
        )
    }

    // MARK: - Fonctions de génération intermédiaire

    /// Fonction helper pour gérer la négation selon le verbe
    private static func getNegationPrefix(for verb: Verb, subject: String) -> String {
        // Récupérer la conjugaison pour ce verbe et ce sujet
        let conjugation = conjugations[verb]![subject]!

        // Vérifier si la conjugaison commence par une voyelle
        let firstLetter = conjugation.first?.lowercased() ?? ""
        let vowels = ["a", "e", "i", "o", "u", "é", "è", "ê", "à", "â", "ô", "ù", "û", "y"]

        if vowels.contains(firstLetter) {
            return "n'"
        } else {
            return "ne "
        }
    }

    /// Adapter le complément en cas de négation (ex.: des → de, un/une → de, d' devant voyelle)
    private static func complementForNegation(verb: Verb, complement: String) -> String {
        guard verb == .avoir else { return complement }
        return transformIndefiniteToDe(complement)
    }

    /// Transformer un groupe nominal indéfini en "de/d'" pour la négation
    private static func transformIndefiniteToDe(_ complement: String) -> String {
        let lower = complement.lowercased()
        let vowels = ["a", "e", "i", "o", "u", "é", "è", "ê", "à", "â", "ô", "ù", "û", "y", "h"]
        func startsWithVowel(_ s: String) -> Bool {
            guard let first = s.first else { return false }
            return vowels.contains(String(first))
        }

        if lower.hasPrefix("un ") {
            let rest = String(complement.dropFirst(3))
            return (startsWithVowel(rest) ? "d'" : "de ") + rest
        } else if lower.hasPrefix("une ") {
            let rest = String(complement.dropFirst(4))
            return (startsWithVowel(rest) ? "d'" : "de ") + rest
        } else if lower.hasPrefix("des ") {
            let rest = String(complement.dropFirst(4))
            return (startsWithVowel(rest) ? "d'" : "de ") + rest
        } else {
            return complement
        }
    }

    /// Fonction helper pour formater le sujet selon le contexte
    private static func formatSubject(_ subject: String, isStartOfSentence: Bool) -> String {
        if isStartOfSentence {
            return subject.capitalized
        } else {
            return subject.lowercased()
        }
    }

    /// Exercice avec contexte temporel
    private static func generateContextExercise() -> ExerciseDataModel {
        let combination = generateRandomCombination()
        let context = intermediateContexts.randomElement()!

        let sentence: String
        if combination.subject == "je" && combination.verb == .avoir {
            sentence = "\(context)j'___ \(combination.complement)"
        } else {
            sentence = "\(context)\(formatSubject(combination.subject, isStartOfSentence: false)) ___ \(combination.complement)"
        }

        let options = generateRandomOptions(for: combination.verb, correctAnswer: combination.correctAnswer)

        return ExerciseDataModel(
            id: "intermediate_context_\(Date().timeIntervalSince1970)",
            type: ExerciseType.qcm.rawValue,
            verb: combination.verb.rawValue,
            level: Level.intermediate.rawValue,
            sentence: sentence,
            correctAnswer: combination.correctAnswer,
            options: options,
            subject: combination.subject
        )
    }

    /// Exercice avec négation
    private static func generateNegationExercise() -> ExerciseDataModel {
        let combination = generateRandomCombination()
        let negationPrefix = getNegationPrefix(for: combination.verb, subject: combination.subject)
        let adjustedComplement = complementForNegation(verb: combination.verb, complement: combination.complement)

        let sentence: String
        // En négation, on n'élide pas "je" → toujours "Je" puis "ne/n'"
        if combination.subject == "je" {
            sentence = "Je \(negationPrefix)___ pas \(adjustedComplement)"
        } else {
            sentence = "\(combination.subject.capitalized) \(negationPrefix)___ pas \(adjustedComplement)"
        }

        let options = generateRandomOptions(for: combination.verb, correctAnswer: combination.correctAnswer)

        return ExerciseDataModel(
            id: "intermediate_negation_\(Date().timeIntervalSince1970)",
            type: ExerciseType.qcm.rawValue,
            verb: combination.verb.rawValue,
            level: Level.intermediate.rawValue,
            sentence: sentence,
            correctAnswer: combination.correctAnswer,
            options: options,
            subject: combination.subject
        )
    }

    /// Exercice avec adverbes
    private static func generateAdverbExercise() -> ExerciseDataModel {
        let combination = generateRandomCombination()
        let adverb = adverbs.randomElement()!

        let sentence: String
        if combination.subject == "je" && combination.verb == .avoir {
            sentence = "J'___ \(adverb) \(combination.complement)"
        } else {
            sentence = "\(combination.subject.capitalized) ___ \(adverb) \(combination.complement)"
        }

        let options = generateRandomOptions(for: combination.verb, correctAnswer: combination.correctAnswer)

        return ExerciseDataModel(
            id: "intermediate_adverb_\(Date().timeIntervalSince1970)",
            type: ExerciseType.qcm.rawValue,
            verb: combination.verb.rawValue,
            level: Level.intermediate.rawValue,
            sentence: sentence,
            correctAnswer: combination.correctAnswer,
            options: options,
            subject: combination.subject
        )
    }

    // MARK: - Fonctions de génération expert

    /// Exercice avec phrase subordonnée
    private static func generateSubordinateExercise() -> ExerciseDataModel {
        let combination = generateRandomCombination()
        let subordinate = expertSubordinateClauses.randomElement()!

        let sentence: String
        if combination.subject == "je" && combination.verb == .avoir {
            sentence = "\(subordinate)j'___ \(combination.complement)"
        } else {
            sentence = "\(subordinate)\(formatSubject(combination.subject, isStartOfSentence: false)) ___ \(combination.complement)"
        }

        let options = generateRandomOptions(for: combination.verb, correctAnswer: combination.correctAnswer)

        return ExerciseDataModel(
            id: "expert_subordinate_\(Date().timeIntervalSince1970)",
            type: ExerciseType.qcm.rawValue,
            verb: combination.verb.rawValue,
            level: Level.expert.rawValue,
            sentence: sentence,
            correctAnswer: combination.correctAnswer,
            options: options,
            subject: combination.subject
        )
    }

    /// Exercice avec temps composé
    private static func generateCompoundTenseExercise() -> ExerciseDataModel {
        let combination = generateRandomCombination()

        let sentence: String
        if combination.subject == "je" && combination.verb == .avoir {
            sentence = "J'___ été \(combination.complement)"
        } else {
            sentence = "\(combination.subject.capitalized) ___ été \(combination.complement)"
        }

        let options = generateRandomOptions(for: combination.verb, correctAnswer: combination.correctAnswer)

        return ExerciseDataModel(
            id: "expert_compound_\(Date().timeIntervalSince1970)",
            type: ExerciseType.qcm.rawValue,
            verb: combination.verb.rawValue,
            level: Level.expert.rawValue,
            sentence: sentence,
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
