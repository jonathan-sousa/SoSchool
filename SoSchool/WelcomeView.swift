//
//  WelcomeView.swift
//  SoSchool
//
//  Created by Jonathan Sousa on 03/08/2025.
//

import SwiftUI
import SwiftData

/// Vue d'accueil pour sélectionner un utilisateur
struct WelcomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \User.createdAt, order: .reverse) private var users: [User]

    @State private var selectedUser: User?
    @State private var showCreateUser = false
    @State private var showExerciseSelection = false

        var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // En-tête
                VStack(spacing: 15) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("SoSchool")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Choisis ton profil pour commencer")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Liste des utilisateurs ou message si aucun
                if users.isEmpty {
                    // Aucun utilisateur - gros bouton de création
                    VStack(spacing: 30) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 80))
                            .foregroundColor(.blue.opacity(0.6))

                        Text("Aucun utilisateur")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        Button(action: {
                            showCreateUser = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Créer un utilisateur")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                        }
                        .padding(.horizontal, 40)
                    }
                } else {
                    // Liste des utilisateurs
                    VStack(spacing: 15) {
                        Text("Utilisateurs")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        List {
                            ForEach(users) { user in
                                UserCardView(
                                    user: user,
                                    isSelected: selectedUser?.id == user.id
                                ) {
                                    selectedUser = user
                                }
                            }
                            .onDelete(perform: deleteUser)
                        }
                        .listStyle(PlainListStyle())
                        .frame(maxHeight: 300)
                    }
                }

                Spacer()

                // Bouton commencer (seulement si un utilisateur est sélectionné)
                if let selectedUser = selectedUser {
                    Button(action: {
                        showExerciseSelection = true
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                            Text("Commencer avec \(selectedUser.firstName)")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(15)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !users.isEmpty {
                        Button(action: {
                            showCreateUser = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreateUser) {
                CreateUserView()
            }
            .sheet(isPresented: $showExerciseSelection) {
                if let selectedUser = selectedUser {
                    ExerciseSelectionView(currentUser: selectedUser)
                }
            }
        }
    }

    /// Supprimer un utilisateur
    private func deleteUser(offsets: IndexSet) {
        for index in offsets {
            let user = users[index]
            modelContext.delete(user)
        }

        do {
            try modelContext.save()
            // Si l'utilisateur supprimé était sélectionné, déselectionner
            if let deletedUser = selectedUser, !users.contains(where: { $0.id == deletedUser.id }) {
                selectedUser = nil
            }
        } catch {
            print("❌ Erreur lors de la suppression de l'utilisateur : \(error)")
        }
    }
}

/// Carte pour afficher un utilisateur
struct UserCardView: View {
    let user: User
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(user.firstName)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

/// Vue pour créer un nouvel utilisateur
struct CreateUserView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var firstName = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Icône
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                // Formulaire
                VStack(spacing: 20) {
                    Text("Nouvel utilisateur")
                        .font(.title2)
                        .fontWeight(.bold)

                    TextField("Prénom", text: $firstName)
                        .font(.title3)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .textFieldStyle(PlainTextFieldStyle())
                        .keyboardType(.default)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.words)
                        .textContentType(.name)
                }

                Spacer()

                // Bouton créer
                Button(action: createUser) {
                    Text("Créer")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .disabled(firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 40)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }

        private func createUser() {
        let trimmedName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let user = User(firstName: trimmedName)
        modelContext.insert(user)

        do {
            try modelContext.save()
            print("✅ Nouvel utilisateur créé : \(user.firstName)")
            dismiss()
        } catch {
            print("❌ Erreur lors de la création de l'utilisateur : \(error)")
        }
    }
}

#Preview {
    WelcomeView()
}
