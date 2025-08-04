//
//  LevelSelectionView.swift
//  SoSchool
//
//  Created by Jonathan Sousa on 03/08/2025.
//

import SwiftUI
import SwiftData

/// Vue de sélection du niveau de difficulté
struct LevelSelectionView: View {
    let selectedExerciseType: ExerciseType
    let currentUser: User

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedLevel: Level = .beginner
    @State private var showExercise = false

    // Query pour récupérer les scores
    @Query(sort: \Score.completedAt, order: .reverse) private var scores: [Score]

        /// Récupérer le meilleur score pour un niveau donné (optimisé)
    private func getBestScore(for level: Level) -> (score: Int, maxScore: Int, time: TimeInterval)? {
        print("🔍 Recherche du meilleur score pour l'utilisateur : \(currentUser.firstName)")
        print("🔍 Type d'exercice : \(selectedExerciseType.rawValue)")
        print("🔍 Niveau : \(level.rawValue)")
        print("🔍 Total des scores dans la base : \(scores.count)")

        // Utiliser les scores déjà fetchés par @Query et filtrer par utilisateur
        let levelScores = scores.filter { score in
            let matchesType = score.exercise?.type == selectedExerciseType.rawValue
            let matchesLevel = score.exercise?.level == level.rawValue
            let matchesUser = score.user?.id == currentUser.id

            print("  - Score pour \(score.user?.firstName ?? "inconnu") : \(score.score)/\(score.maxScore)")
            print("    Type: \(score.exercise?.type ?? "nil") == \(selectedExerciseType.rawValue) ? \(matchesType)")
            print("    Level: \(score.exercise?.level ?? "nil") == \(level.rawValue) ? \(matchesLevel)")
            print("    User match: \(matchesUser)")

            return matchesType && matchesLevel && matchesUser
        }

        print("🔍 Scores filtrés pour cet utilisateur : \(levelScores.count)")

        // Trier par pourcentage de réussite (score/maxScore) décroissant, puis par temps croissant
        let sortedScores = levelScores.sorted { score1, score2 in
            let percentage1 = Double(score1.score) / Double(score1.maxScore)
            let percentage2 = Double(score2.score) / Double(score2.maxScore)

            print("🔄 Tri : \(score1.score)/\(score1.maxScore) (\(String(format: "%.1f", percentage1 * 100))%) vs \(score2.score)/\(score2.maxScore) (\(String(format: "%.1f", percentage2 * 100))%)")

            if percentage1 != percentage2 {
                let result = percentage1 > percentage2
                print("  → \(result ? "score1" : "score2") en premier")
                return result // Meilleur pourcentage en premier
            } else {
                let result = score1.elapsedTime < score2.elapsedTime
                print("  → même pourcentage, \(result ? "score1" : "score2") en premier (temps)")
                return result // Temps plus court en premier
            }
        }

        print("📊 Scores triés :")
        for (index, score) in sortedScores.enumerated() {
            let percentage = Double(score.score) / Double(score.maxScore) * 100
            print("  \(index + 1). \(score.score)/\(score.maxScore) (\(String(format: "%.1f", percentage))%) en \(formatTime(score.elapsedTime))")
        }

        let bestScore = sortedScores.first.map { score in
            (score: score.score, maxScore: score.maxScore, time: score.elapsedTime)
        }

        if let bestScore = bestScore {
            print("✅ Meilleur score trouvé : \(bestScore.score)/\(bestScore.maxScore)")
        } else {
            print("❌ Aucun meilleur score trouvé pour cet utilisateur")
        }

        return bestScore
    }

    /// Formater le temps en format lisible
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }





    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // En-tête
                VStack(spacing: 15) {
                    Text("Choisis ton niveau")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Tu as choisi : \(selectedExerciseType.displayName)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Sélection du niveau
                VStack(alignment: .leading, spacing: 20) {
                    Text("Niveau de difficulté")
                        .font(.headline)
                        .foregroundColor(.primary)

                    VStack(spacing: 15) {
                        ForEach(Level.allCases, id: \.self) { level in
                            LevelCard(
                                level: level,
                                isSelected: selectedLevel == level,
                                action: {
                                    selectedLevel = level
                                },
                                bestScore: getBestScore(for: level)
                            )
                        }
                    }
                }

                Spacer()

                // Bouton pour commencer l'exercice
                VStack(spacing: 15) {
                    Button(action: {
                        showExercise = true
                    }) {
                        Text("Commencer l'exercice")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Retour") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showExercise) {
                ExerciseView(exerciseType: selectedExerciseType, level: selectedLevel, currentUser: currentUser)
            }
            .onAppear {
                // Les données SwiftData se mettent à jour automatiquement
            }

        }
    }
}

#Preview {
    // Créer un utilisateur de test pour la preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Exercise.self, Score.self, configurations: config)
    let testUser = User(firstName: "Test")

    return LevelSelectionView(selectedExerciseType: .qcm, currentUser: testUser)
        .modelContainer(container)
}
