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
    let currentUser: User

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var currentExercise: ExerciseDataModel?
    @State private var exercises: [ExerciseDataModel] = []
    @State private var currentIndex = 0
    @State private var showResult = false
    @State private var isLoading = true
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
                        .id("complete-\(currentIndex)-\(exercise.id)")
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

    /// Charger l'utilisateur actuel (maintenant passé en paramètre)
    private func loadCurrentUser() {
        print("👤 Utilisateur chargé : \(currentUser.firstName)")
    }

    /// Charger le meilleur score pour l'utilisateur actuel
    private func loadBestScore() {
        bestScore = scoreManager.getBestScore(modelContext: modelContext, exerciseType: exerciseType, level: level, user: currentUser)
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
        print("💾 Début de la sauvegarde du score pour \(currentUser.firstName)")

        // Vérifier si c'est un nouveau record pour cet utilisateur
        isNewRecord = scoreManager.isNewRecord(modelContext: modelContext, exerciseType: exerciseType, level: level, user: currentUser)

        // Sauvegarder le score
        scoreManager.saveScore(modelContext: modelContext, user: currentUser, exerciseType: exerciseType, level: level)

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
        ScrollView {
            VStack(spacing: 30) {
                // Question
                VStack(spacing: 20) {
                    Text("Complète la phrase :")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    // Encart de phrase: 2 lignes max, taille fixe, troncature
                    Text(exercise.sentence)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 60, alignment: .center)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .accessibilityLabel("Phrase à compléter")
                }

                // Options de réponse
                VStack(spacing: 15) {
                    ForEach(exercise.options, id: \.self) { option in
                        Button(action: {
                            guard !isAnswered else { return }

                            selectedAnswer = option
                            isAnswered = true
                            showFeedback = true
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

                Spacer(minLength: 0)

                // Bouton en bas
                if showFeedback {
                    Button(action: {
                        let wasCorrect = selectedAnswer == exercise.correctAnswer
                        selectedAnswer = nil
                        showFeedback = false
                        isAnswered = false
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
                }
            }
            .padding()
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            selectedAnswer = nil
            showFeedback = false
            isAnswered = false
        }
    }

    private func backgroundColor(for option: String) -> Color {
        guard isAnswered else { return Color.gray.opacity(0.1) }
        if option == selectedAnswer { return option == exercise.correctAnswer ? .green : .red }
        if option == exercise.correctAnswer { return .green.opacity(0.3) }
        return Color.gray.opacity(0.1)
    }
}

/// Vue pour l'exercice de complétion
struct CompleteExerciseView: View {
    let exercise: ExerciseDataModel
    let onAnswer: (Bool) -> Void

    @State private var userInput: String = ""
    @State private var isAnswered = false
    @State private var isCorrect: Bool? = nil

    var body: some View {
        VStack(spacing: 24) {
            // Enoncé
            VStack(spacing: 12) {
                Text("Complète par la bonne conjugaison :")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                // Indication du verbe à conjuguer
                HStack(spacing: 8) {
                    Text("Verbe à conjuguer :")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(exercise.verb)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                        .accessibilityLabel("Verbe à conjuguer \(exercise.verb)")
                }

                Text(exercise.sentence)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }

            // Saisie
            VStack(alignment: .leading, spacing: 12) {
                TextField("Ta réponse", text: $userInput)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.default)
                    .padding()
                    .background(Color.gray.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(borderColor, lineWidth: 2)
                    )
                    .cornerRadius(10)
                    .disabled(isAnswered) // verrouiller après validation

                // Feedback
                if let isCorrect = isCorrect {
                    HStack(spacing: 8) {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.octagon.fill")
                            .foregroundColor(isCorrect ? .green : .red)
                        if isCorrect {
                            Text("Bonne réponse !")
                                .foregroundColor(.green)
                                .font(.headline)
                        } else {
                            Text("Réponse attendue : \(exercise.correctAnswer)")
                                .foregroundColor(.red)
                                .font(.headline)
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            Button(action: primaryAction) {
                Text(buttonTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color.blue)
                    .cornerRadius(10)
            }

        }
        .padding()
        .onAppear(perform: reset)
        .onChange(of: exercise.id) { _ in reset() }
    }

    private var borderColor: Color {
        guard let isCorrect = isCorrect else { return .clear }
        return isCorrect ? .green : .red
    }

    private func normalize(_ s: String) -> String {
        let lowered = s.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // Supprimer les accents
        let decomposed = lowered.applyingTransform(.stripDiacritics, reverse: false) ?? lowered
        // Condenser espaces internes
        let condensed = decomposed.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return condensed
    }

    private func validate() {
        let expected = normalize(exercise.correctAnswer)
        let actual = normalize(userInput)
        isCorrect = (expected == actual)
        isAnswered = true
    }

    private func primaryAction() {
        // 1) Si pas encore validé, on valide (affiche le feedback)
        if !isAnswered {
            validate()
            return
        }
        // 2) Si déjà validé, on avance (compte uniquement si correct)
        onAnswer(isCorrect ?? false)
    }

    private var buttonTitle: String {
        if !isAnswered { return "Valider" }
        return "Exercice suivant"
    }

    private func reset() {
        userInput = ""
        isAnswered = false
        isCorrect = nil
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
    // Créer un utilisateur de test pour la preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Exercise.self, Score.self, configurations: config)
    let testUser = User(firstName: "Test")

    return ExerciseView(exerciseType: ExerciseType.qcm, level: Level.beginner, currentUser: testUser)
        .modelContainer(container)
}
