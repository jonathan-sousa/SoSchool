//
//  ExerciseSelectionView.swift
//  SoSchool
//
//  Created by Jonathan Sousa on 03/08/2025.
//

import SwiftUI
import SwiftData

/// Vue de sélection des exercices
struct ExerciseSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedExerciseType: ExerciseType = .qcm
    @State private var showLevelSelection = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // En-tête
                VStack(spacing: 15) {
                    Text("Choisis ton exercice")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }

                // Sélection du type d'exercice
                VStack(alignment: .leading, spacing: 15) {
                    Text("Type d'exercice")
                        .font(.headline)
                        .foregroundColor(.primary)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                        ForEach(ExerciseType.allCases, id: \.self) { exerciseType in
                            ExerciseTypeCard(
                                exerciseType: exerciseType,
                                isSelected: selectedExerciseType == exerciseType
                            ) {
                                selectedExerciseType = exerciseType
                            }
                        }
                    }
                }



                Spacer()

                // Bouton Continuer
                Button(action: {
                    showLevelSelection = true
                }) {
                    Text("Continuer")
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
            .sheet(isPresented: $showLevelSelection) {
                LevelSelectionView(selectedExerciseType: selectedExerciseType)
            }
        }
    }
}

/// Carte pour un type d'exercice
struct ExerciseTypeCard: View {
    let exerciseType: ExerciseType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: iconName)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : .blue)

                Text(exerciseType.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
            }
                                .frame(maxWidth: .infinity, minHeight: 100)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var iconName: String {
        switch exerciseType {
        case .qcm:
            return "list.bullet.circle"
        case .complete:
            return "pencil.circle"
        case .match:
            return "arrow.left.arrow.right.circle"
        case .memory:
            return "brain.head.profile"
        case .puzzle:
            return "puzzlepiece"
        }
    }
}

/// Carte pour un niveau de difficulté
struct LevelCard: View {
    let level: Level
    let isSelected: Bool
    let action: () -> Void
    let bestScore: (score: Int, maxScore: Int, time: TimeInterval)?

    var body: some View {
        Button(action: action) {
            HStack {
                // Contenu principal centré
                VStack(spacing: 8) {
                    Image(systemName: levelIcon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : levelColor)

                    Text(level.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                .frame(maxWidth: .infinity)

                // Affichage du record à droite (toujours présent)
                VStack(spacing: 4) {
                    Text("Record")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)

                    if let bestScore = bestScore {
                        Text("\(bestScore.score)/\(bestScore.maxScore)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(isSelected ? .white : .primary)

                        Text(formatTime(bestScore.time))
                            .font(.caption2)
                            .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
                    } else {
                        Text("--/--")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(isSelected ? .white.opacity(0.5) : .secondary)

                        Text("--:--")
                            .font(.caption2)
                            .foregroundColor(isSelected ? .white.opacity(0.5) : .secondary)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Color.white.opacity(0.2) : Color.gray.opacity(0.1))
                )
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(.horizontal, 12)
            .background(isSelected ? levelColor : Color.gray.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? levelColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var levelColor: Color {
        switch level {
        case .beginner:
            return .green
        case .intermediate:
            return .orange
        case .expert:
            return .red
        }
    }

    private var levelIcon: String {
        switch level {
        case .beginner:
            return "1.circle"
        case .intermediate:
            return "2.circle"
        case .expert:
            return "3.circle"
        }
    }
}

#Preview {
    ExerciseSelectionView()
}
