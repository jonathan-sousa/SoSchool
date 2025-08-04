//
//  ScoreManager.swift
//  SoSchool
//
//  Created by Jonathan Sousa on 03/08/2025.
//

import SwiftUI
import SwiftData

/// Gestionnaire des scores et records avec SwiftData
@Observable
class ScoreManager {
    var currentScore = 0
    var maxScore = 10
    var elapsedTime: TimeInterval = 0
    var isTimerRunning = false

    private var timer: Timer?
    private var startTime: Date?

    /// Démarrer le timer
    func startTimer() {
        startTime = Date()
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let startTime = self.startTime {
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }

    /// Arrêter le timer
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }

    /// Réinitialiser le score
    func resetScore() {
        currentScore = 0
        elapsedTime = 0
        stopTimer()
    }

    /// Incrémenter le score
    func incrementScore() {
        currentScore += 1
    }

    /// Formater le temps écoulé
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Sauvegarder le score final
    func saveScore(modelContext: ModelContext, child: Child, exerciseType: ExerciseType, level: Level) {
        print("💾 === DÉBUT SAUVEGARDE SCORE SWIFTDATA ===")
        print("💾 Type: \(exerciseType.rawValue), Niveau: \(level.rawValue)")
        print("💾 Enfant: \(child.firstName)")
        print("📊 Score réel obtenu : \(currentScore)/\(maxScore)")

        // Vérifier si c'est un nouveau record
        let isNewRecord = self.isNewRecord(modelContext: modelContext, exerciseType: exerciseType, level: level)

        if isNewRecord {
            print("🏆 Nouveau record détecté !")

            // Supprimer l'ancien record s'il existe
            deleteOldScore(modelContext: modelContext, exerciseType: exerciseType, level: level)

            // Créer le nouveau record
            createNewScore(modelContext: modelContext, child: child, exerciseType: exerciseType, level: level, score: currentScore)
        } else {
            print("🏆 Premier record !")
            createNewScore(modelContext: modelContext, child: child, exerciseType: exerciseType, level: level, score: currentScore)
        }

        print("💾 === FIN SAUVEGARDE SCORE SWIFTDATA ===")
    }

    /// Créer un nouveau score
    private func createNewScore(modelContext: ModelContext, child: Child, exerciseType: ExerciseType, level: Level, score: Int) {
        print("💾 Création du nouveau score...")

        // Récupérer ou créer l'exercice
        let exercise = getOrCreateExercise(modelContext: modelContext, exerciseType: exerciseType, level: level)
        print("🏃 Exercice trouvé : \(exercise.displayName)")

        // Créer le nouveau score
        let newScore = Score(score: score, maxScore: maxScore, elapsedTime: elapsedTime)
        newScore.child = child
        newScore.exercise = exercise

        // Ajouter à la base de données
        modelContext.insert(newScore)

        print("💾 Nouveau record créé : \(score)/\(maxScore)")
        print("💾 Exercice assigné : \(exercise.displayName)")
        print("💾 Enfant assigné : \(child.firstName)")

        do {
            try modelContext.save()
            print("✅ ModelContext.save() réussi")
            print("🏆 Nouveau record sauvegardé : \(score)/\(maxScore) en \(formatTime(elapsedTime))")
        } catch {
            print("❌ Erreur lors de la sauvegarde : \(error)")
        }
    }

    /// Récupérer le meilleur score pour un exercice et niveau
    func getBestScore(modelContext: ModelContext, exerciseType: ExerciseType, level: Level) -> (score: Int, maxScore: Int, time: TimeInterval)? {
        // Debug: Vérifier tous les scores dans la base
        let allScoresDescriptor = FetchDescriptor<Score>()

        do {
            let allScores = try modelContext.fetch(allScoresDescriptor)
            print("🔍 Total des scores dans la base : \(allScores.count)")

            for score in allScores {
                print("📊 Score : \(score.score)/\(score.maxScore) - Exercice: \(score.exercise?.displayName ?? "nil")")
            }
        } catch {
            print("❌ Erreur lors de la récupération de tous les scores : \(error)")
        }

        // Chercher les records spécifiques pour ce type et niveau
        let fetchDescriptor = FetchDescriptor<Score>(
            sortBy: [SortDescriptor(\.score, order: .reverse), SortDescriptor(\.completedAt, order: .forward)]
        )

        do {
            let allScores = try modelContext.fetch(fetchDescriptor)

            // Filtrer manuellement par type et niveau
            let filteredScores = allScores.filter { score in
                score.exercise?.type == exerciseType.rawValue && score.exercise?.level == level.rawValue
            }

            print("🔍 Recherche de records pour \(exerciseType.displayName) - \(level.displayName)")
            print("🔍 Scores trouvés : \(filteredScores.count)")

            if let bestScore = filteredScores.first {
                print("🏆 Record trouvé : \(bestScore.score)/\(bestScore.maxScore) en \(formatTime(bestScore.elapsedTime))")
                return (score: bestScore.score, maxScore: bestScore.maxScore, time: bestScore.elapsedTime)
            } else {
                print("❌ Aucun record trouvé")
            }
        } catch {
            print("❌ Erreur lors de la récupération du meilleur score : \(error)")
        }
        return nil
    }

    /// Vérifier si le score actuel bat le record
    func isNewRecord(modelContext: ModelContext, exerciseType: ExerciseType, level: Level) -> Bool {
        guard let bestScore = getBestScore(modelContext: modelContext, exerciseType: exerciseType, level: level) else {
            return true // Premier score
        }

        return currentScore > bestScore.score || (currentScore == bestScore.score && elapsedTime < bestScore.time)
    }

    /// Récupérer ou créer un exercice
    private func getOrCreateExercise(modelContext: ModelContext, exerciseType: ExerciseType, level: Level) -> Exercise {
        print("🏃 Recherche d'exercice existant : \(exerciseType.rawValue) - \(level.rawValue)")

        let fetchDescriptor = FetchDescriptor<Exercise>()

        do {
            let existingExercises = try modelContext.fetch(fetchDescriptor)

            // Filtrer par type et niveau
            let filteredExercises = existingExercises.filter { exercise in
                exercise.type == exerciseType.rawValue && exercise.level == level.rawValue
            }

            if let existingExercise = filteredExercises.first {
                print("🏃 Exercice existant trouvé : \(existingExercise.displayName)")
                return existingExercise
            }
        } catch {
            print("❌ Erreur lors de la recherche d'exercice : \(error)")
        }

        // Créer un nouvel exercice de référence
        print("🏃 Création d'un nouvel exercice de référence")
        let newExercise = Exercise(
            type: exerciseType.rawValue,
            verb: "",
            level: level.rawValue,
            sentence: "",
            correctAnswer: "",
            subject: ""
        )

        modelContext.insert(newExercise)

        do {
            try modelContext.save()
            print("✅ Nouvel exercice de référence créé : \(exerciseType.rawValue) - \(level.rawValue)")
        } catch {
            print("❌ Erreur lors de la création de l'exercice : \(error)")
        }

        return newExercise
    }

    /// Supprimer l'ancien record
    private func deleteOldScore(modelContext: ModelContext, exerciseType: ExerciseType, level: Level) {
        print("🗑️ === DÉBUT SUPPRESSION ANCIEN RECORD ===")

        let fetchDescriptor = FetchDescriptor<Score>()

        do {
            let allScores = try modelContext.fetch(fetchDescriptor)

            // Filtrer par type et niveau
            let scoresToDelete = allScores.filter { score in
                score.exercise?.type == exerciseType.rawValue && score.exercise?.level == level.rawValue
            }

            print("🗑️ Suppression de \(scoresToDelete.count) ancien(s) record(s)")

            for score in scoresToDelete {
                print("🗑️ Suppression du score : \(score.score)/\(score.maxScore)")
                modelContext.delete(score)
                print("🗑️ Ancien record supprimé : \(score.score)/\(score.maxScore)")
            }

            try modelContext.save()
            print("✅ Suppression des anciens records sauvegardée")

        } catch {
            print("❌ Erreur lors de la suppression de l'ancien record : \(error)")
        }

        print("🗑️ === FIN SUPPRESSION ANCIEN RECORD ===")
    }
}

/// Extension pour les propriétés d'affichage
extension ScoreManager {
    var formattedElapsedTime: String {
        formatTime(elapsedTime)
    }

    var scorePercentage: Double {
        guard maxScore > 0 else { return 0 }
        return Double(currentScore) / Double(maxScore)
    }
}
