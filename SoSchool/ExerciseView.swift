//
//  ExerciseView.swift
//  SoSchool
//
//  Created by Jonathan Sousa on 03/08/2025.
//

import SwiftUI
import SwiftData

/// Vue générique pour les exercices de conjugaison
struct ExerciseView: View {
    let exerciseType: ExerciseType
    let level: Level

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var currentExercise: ExerciseDataModel?
    @State private var exercises: [ExerciseDataModel] = []
    @State private var currentIndex = 0
    @State private var showResult = false
    @State private var isLoading = true
    @State private var currentUser: User?
    @State private var scoreManager = ScoreManager()
    @State private var bestScore: (score: Int, maxScore: Int, time: TimeInterval)?
    @State private var isNewRecord = false

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Chargement des exercices...")
                        .font(.title2)
                } else if let exercise = currentExercise {
                    // En-tête avec progression, timer et scores
                    VStack(spacing: 15) {
                        HStack {
                            Text("Exercice \(currentIndex + 1) sur \(exercises.count)")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 5) {
                                Text("Score: \(scoreManager.currentScore)/\(scoreManager.maxScore)")
                                    .font(.headline)
                                    .foregroundColor(.blue)

                                Text(scoreManager.formattedElapsedTime)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        ProgressView(value: Double(currentIndex + 1), total: Double(exercises.count))
                            .progressViewStyle(LinearProgressViewStyle())

                        // Meilleur score
                        if let bestScore = bestScore {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.yellow)
                                Text("Meilleur: \(bestScore.score)/\(bestScore.maxScore)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                    }
                    .padding()

                    // Contenu de l'exercice selon le type
                    switch exerciseType {
                    case .qcm:
                        QCMExerciseView(exercise: exercise) { isCorrect in
                            handleAnswer(isCorrect: isCorrect)
                        }
                        .id("qcm-\(currentIndex)-\(exercise.id)")
                    case .complete:
                        CompleteExerciseView(exercise: exercise) { isCorrect in
                            handleAnswer(isCorrect: isCorrect)
                        }
                    case .match:
                        MatchExerciseView(exercise: exercise) { isCorrect in
                            handleAnswer(isCorrect: isCorrect)
                        }
                    case .memory:
                        MemoryExerciseView(exercise: exercise) { isCorrect in
                            handleAnswer(isCorrect: isCorrect)
                        }
                    case .puzzle:
                        PuzzleExerciseView(exercise: exercise) { isCorrect in
                            handleAnswer(isCorrect: isCorrect)
                        }
                    }

                    Spacer()
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)

                        Text("Aucun exercice disponible")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Aucun exercice n'a été trouvé pour ce type et ce niveau.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Button("Retour") {
                            dismiss()
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Quitter") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showResult) {
                ExerciseResultView(
                    score: scoreManager.currentScore,
                    total: scoreManager.maxScore,
                    time: scoreManager.elapsedTime,
                    isNewRecord: isNewRecord,
                    bestScore: bestScore
                ) {
                    dismiss()
                }
            }
        }
        .onAppear {
            loadExercises()
            loadCurrentUser()
            loadBestScore()
            startExercise()
        }
    }

    /// Charger les exercices depuis SwiftData
    private func loadExercises() {
        print("🔄 Début du chargement des exercices pour \(exerciseType.rawValue) - \(level.rawValue)")

        // Générer les exercices à la volée (pas de stockage en base)
        print("📝 Génération de \(ExerciseData.exercisesPerSession) exercices à la volée...")
        exercises = ExerciseData.generateExercisesForLevel(level, exerciseType: exerciseType, count: ExerciseData.exercisesPerSession)

        print("✅ \(exercises.count) exercices générés à la volée")

        if !exercises.isEmpty {
            currentExercise = exercises[0]
            print("🎯 Premier exercice chargé : \(currentExercise?.sentence ?? "nil")")
        } else {
            print("❌ Aucun exercice généré")
        }

        isLoading = false
    }

    /// Gérer la réponse de l'utilisateur
    @MainActor
    private func handleAnswer(isCorrect: Bool) {
        if isCorrect {
            scoreManager.incrementScore()
        }

        // Passer à l'exercice suivant
        if currentIndex < exercises.count - 1 {
            currentIndex += 1
            currentExercise = exercises[currentIndex]
        } else {
            // Fin de l'exercice
            scoreManager.stopTimer()
            saveScore()
            showResult = true
        }
    }

    /// Charger l'utilisateur actuel depuis SwiftData
    private func loadCurrentUser() {
        // Récupérer le premier utilisateur disponible
        let fetchDescriptor = FetchDescriptor<User>()

        do {
            let users = try modelContext.fetch(fetchDescriptor)
            currentUser = users.first
            print("👤 Utilisateur chargé : \(currentUser?.firstName ?? "Aucun")")
        } catch {
            print("❌ Erreur lors du chargement de l'utilisateur : \(error)")
        }
    }

    /// Charger le meilleur score pour l'utilisateur actuel
    private func loadBestScore() {
        guard let user = currentUser else { return }
        bestScore = scoreManager.getBestScore(modelContext: modelContext, exerciseType: exerciseType, level: level, user: user)
    }

    /// Démarrer l'exercice
    private func startExercise() {
        scoreManager.maxScore = exercises.count
        scoreManager.resetScore()
        scoreManager.startTimer()
    }

    /// Sauvegarder le score
    @MainActor
    private func saveScore() {
        guard let user = currentUser else {
            print("❌ Erreur : Aucun utilisateur trouvé")
            return
        }

        print("💾 Début de la sauvegarde du score pour \(user.firstName)")

        // Vérifier si c'est un nouveau record pour cet utilisateur
        isNewRecord = scoreManager.isNewRecord(modelContext: modelContext, exerciseType: exerciseType, level: level, user: user)

        // Sauvegarder le score
        scoreManager.saveScore(modelContext: modelContext, user: user, exerciseType: exerciseType, level: level)

        // Les données SwiftData se mettent à jour automatiquement
    }
}

/// Vue pour l'exercice QCM
struct QCMExerciseView: View {
    let exercise: ExerciseDataModel
    let onAnswer: (Bool) -> Void

    @State private var selectedAnswer: String?
    @State private var showFeedback = false
    @State private var isAnswered = false

    var body: some View {
        VStack(spacing: 30) {
            // Question
            VStack(spacing: 20) {
                Text("Complète la phrase :")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(exercise.sentence)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }

            // Options de réponse
            VStack(spacing: 15) {
                ForEach(exercise.options, id: \.self) { option in
                    Button(action: {
                        guard !isAnswered else { return }

                        selectedAnswer = option
                        isAnswered = true
                        showFeedback = true

                        // Ne pas appeler onAnswer ici, attendre le bouton "Exercice suivant"
                    }) {
                        Text(option)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedAnswer == option ? .white : .primary)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .padding()
                            .background(backgroundColor(for: option))
                            .cornerRadius(10)
                    }
                    .disabled(isAnswered)
                }
            }
            .padding(.horizontal)

            // Zone de feedback simplifiée
            VStack(spacing: 15) {
                if showFeedback {
                    // Bouton suivant seulement
                    Button(action: {
                        // Passer à l'exercice suivant avec la réponse actuelle
                        let wasCorrect = selectedAnswer == exercise.correctAnswer

                        // Réinitialiser l'état pour le prochain exercice
                        selectedAnswer = nil
                        showFeedback = false
                        isAnswered = false

                        // Passer à l'exercice suivant
                        onAnswer(wasCorrect)
                    }) {
                        Text("Exercice suivant")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                } else {
                    // Espace réservé pour maintenir la hauteur
                    Spacer()
                        .frame(height: 60)
                }
            }
            .frame(minHeight: 80) // Hauteur minimale fixe réduite
        }
        .padding()
        .padding(.bottom, 20) // Ajouter plus d'espace en bas
        .onAppear {
            // Réinitialiser l'état à chaque nouvel exercice
            selectedAnswer = nil
            showFeedback = false
            isAnswered = false
        }
    }

    private func backgroundColor(for option: String) -> Color {
        guard isAnswered else {
            return Color.gray.opacity(0.1)
        }

        if option == selectedAnswer {
            return option == exercise.correctAnswer ? .green : .red
        } else if option == exercise.correctAnswer {
            return .green.opacity(0.3)
        } else {
            return Color.gray.opacity(0.1)
        }
    }
}

/// Vue pour l'exercice de complétion (placeholder)
struct CompleteExerciseView: View {
    let exercise: ExerciseDataModel
    let onAnswer: (Bool) -> Void

    var body: some View {
        VStack {
            Text("Exercice de complétion")
                .font(.title)

            Text("À implémenter")
                .foregroundColor(.secondary)
        }
    }
}

/// Vue pour l'exercice d'association (placeholder)
struct MatchExerciseView: View {
    let exercise: ExerciseDataModel
    let onAnswer: (Bool) -> Void

    var body: some View {
        VStack {
            Text("Exercice d'association")
                .font(.title)

            Text("À implémenter")
                .foregroundColor(.secondary)
        }
    }
}

/// Vue pour l'exercice de memory (placeholder)
struct MemoryExerciseView: View {
    let exercise: ExerciseDataModel
    let onAnswer: (Bool) -> Void

    var body: some View {
        VStack {
            Text("Exercice de memory")
                .font(.title)

            Text("À implémenter")
                .foregroundColor(.secondary)
        }
    }
}

/// Vue pour l'exercice de puzzle (placeholder)
struct PuzzleExerciseView: View {
    let exercise: ExerciseDataModel
    let onAnswer: (Bool) -> Void

    var body: some View {
        VStack {
            Text("Exercice de puzzle")
                .font(.title)

            Text("À implémenter")
                .foregroundColor(.secondary)
        }
    }
}

/// Vue de résultat d'exercice
struct ExerciseResultView: View {
    let score: Int
    let total: Int
    let time: TimeInterval
    let isNewRecord: Bool
    let bestScore: (score: Int, maxScore: Int, time: TimeInterval)?
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            // Résultat
            VStack(spacing: 20) {
                if isNewRecord {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)

                    Text("Nouveau record ! 🏆")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                } else {
                    Image(systemName: score == total ? "star.fill" : "star")
                        .font(.system(size: 80))
                        .foregroundColor(score == total ? .yellow : .gray)

                    Text(score == total ? "Parfait !" : "Bien joué !")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }

                Text("Tu as obtenu \(score) sur \(total) points")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text("Temps : \(formatTime(time))")
                    .font(.title3)
                    .foregroundColor(.blue)

                if let bestScore = bestScore {
                    Text("Meilleur score : \(bestScore.score)/\(bestScore.maxScore)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Message d'encouragement
            VStack(spacing: 10) {
                Text(encouragementMessage)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
            }

            Spacer()

            // Bouton pour continuer
            Button(action: onDismiss) {
                Text("Continuer")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var encouragementMessage: String {
        let percentage = Double(score) / Double(total)

        switch percentage {
        case 1.0:
            return "Tu es un champion de la conjugaison ! 🏆"
        case 0.8...:
            return "Excellent travail ! Continue comme ça ! 🌟"
        case 0.6...:
            return "Bien joué ! Tu progresses ! 👍"
        case 0.4...:
            return "Pas mal ! Continue à t'entraîner ! 💪"
        default:
            return "Ne te décourage pas, l'entraînement fait le maître ! 📚"
        }
    }
}

#Preview {
    ExerciseView(exerciseType: ExerciseType.qcm, level: Level.beginner)
}
