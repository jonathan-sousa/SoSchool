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
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let selectedExerciseType: ExerciseType
    @State private var selectedLevel: Level = .beginner
    @State private var showExercise = false

    // Query pour récupérer les scores
    @Query(sort: \Score.completedAt, order: .reverse) private var scores: [Score]

        /// Récupérer le meilleur score pour un niveau donné (optimisé)
    private func getBestScore(for level: Level) -> (score: Int, maxScore: Int, time: TimeInterval)? {
        // Utiliser les scores déjà fetchés par @Query
        let levelScores = scores.filter { score in
            score.exercise?.type == selectedExerciseType.rawValue &&
            score.exercise?.level == level.rawValue
        }

        return levelScores.first.map { score in
            (score: score.score, maxScore: score.maxScore, time: score.elapsedTime)
        }
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
                ExerciseView(exerciseType: selectedExerciseType, level: selectedLevel)
            }
            .onAppear {
                // Les données SwiftData se mettent à jour automatiquement
            }

        }
    }
}

#Preview {
    LevelSelectionView(selectedExerciseType: .qcm)
}
