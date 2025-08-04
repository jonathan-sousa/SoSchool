//
//  WelcomeView.swift
//  SoSchool
//
//  Created by Jonathan Sousa on 03/08/2025.
//

import SwiftUI
import SwiftData

/// Vue d'accueil pour demander le prénom de l'utilisateur
struct WelcomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    @State private var firstName = ""
    @State private var isEditing = false
    @State private var showExerciseSelection = false
    @State private var showProfileSheet = false
    @State private var currentUser: User?

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // En-tête avec logo/icône
                VStack(spacing: 20) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding()

                    Text("SoSchool")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Apprenons la conjugaison ensemble !")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Section de saisie du prénom
                VStack(spacing: 20) {
                    Text("Comment t'appelles-tu ?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    TextField("Ton prénom", text: $firstName)
                        .font(.title3)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal, 40)
                        .onTapGesture {
                            isEditing = true
                        }
                        .textFieldStyle(PlainTextFieldStyle())
                        .keyboardType(.default)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.words)
                        .textContentType(.name)

                    // Bouton toujours présent mais invisible si pas de prénom
                    Button(action: {
                        saveUser()
                        showExerciseSelection = true
                    }) {
                        Text("Commencer les exercices")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .opacity(firstName.isEmpty ? 0 : 1)
                    .disabled(firstName.isEmpty)
                    .animation(.easeInOut(duration: 0.3), value: firstName.isEmpty)
                }

                Spacer()

                // Message d'encouragement
                VStack(spacing: 10) {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)

                    Text("Tu vas apprendre à conjuguer :")
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack(spacing: 20) {
                        VerbCard(verb: "avoir", color: .green)
                        VerbCard(verb: "être", color: .blue)
                        VerbCard(verb: "aller", color: .orange)
                    }
                }

                Spacer()

                // Version info
                VStack(spacing: 5) {
                    Text("Version 1.0.0")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("Build 2025.08.04")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)
            }
            .padding()
            .navigationBarHidden(false)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showProfileSheet = true
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                            Text(currentUser?.firstName ?? "Profil")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showExerciseSelection) {
                ExerciseSelectionView()
            }
            .sheet(isPresented: $showProfileSheet) {
                                        ProfileView(currentUser: $currentUser, firstName: $firstName)
            }
            .onAppear {
                loadCurrentUser()
            }
        }
    }

    /// Charger l'utilisateur actuel depuis SwiftData
    private func loadCurrentUser() {
        if let existingUser = users.first {
            currentUser = existingUser
            firstName = existingUser.firstName
        }
    }

    /// Sauvegarder l'utilisateur dans SwiftData
    private func saveUser() {
        if let existingUser = users.first {
            // Mettre à jour l'utilisateur existant
            existingUser.firstName = firstName
            currentUser = existingUser
        } else {
            // Créer un nouvel utilisateur
            let user = User(firstName: firstName, level: Level.beginner.rawValue)
            modelContext.insert(user)
            currentUser = user
        }

        do {
            try modelContext.save()
        } catch {
            print("Erreur lors de la sauvegarde de l'utilisateur : \(error)")
        }
    }
}

/// Carte pour afficher un verbe
struct VerbCard: View {
    let verb: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Text(verb)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(width: 60, height: 40)
        .background(color)
        .cornerRadius(8)
    }
}

#Preview {
    WelcomeView()
}
