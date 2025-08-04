//
//  ProfileView.swift
//  SoSchool
//
//  Created by Jonathan Sousa on 03/08/2025.
//

import SwiftUI
import SwiftData

/// Vue de gestion des profils
struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Binding var currentChild: Child?
    @Binding var firstName: String

    @State private var newFirstName = ""
    @State private var showDeleteAlert = false
    @State private var children: [Child] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // En-tête
                VStack(spacing: 10) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Gestion des profils")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }

                // Profil actuel
                if let currentChild = currentChild {
                    VStack(spacing: 15) {
                        Text("Profil actuel")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.blue)
                            Text(currentChild.firstName)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                }

                // Modifier le nom
                VStack(spacing: 15) {
                    Text("Modifier le nom")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    TextField("Nouveau prénom", text: $newFirstName)
                        .font(.title3)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .onAppear {
                            newFirstName = firstName
                        }
                        .textFieldStyle(PlainTextFieldStyle())
                        .keyboardType(.default)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.words)
                        .textContentType(.name)

                    Button(action: {
                        updateChildName()
                    }) {
                        Text("Sauvegarder")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(newFirstName.isEmpty)
                }

                Spacer()

                // Boutons d'action
                VStack(spacing: 15) {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Text("Supprimer le profil")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        dismiss()
                    }) {
                        Text("Fermer")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
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
            .alert("Supprimer le profil", isPresented: $showDeleteAlert) {
                Button("Annuler", role: .cancel) { }
                Button("Supprimer", role: .destructive) {
                    deleteCurrentChild()
                }
            } message: {
                Text("Êtes-vous sûr de vouloir supprimer ce profil ? Cette action ne peut pas être annulée.")
            }
        }
    }

    /// Mettre à jour le nom de l'enfant
    private func updateChildName() {
        guard !newFirstName.isEmpty else { return }

        if let currentChild = currentChild {
            currentChild.firstName = newFirstName
            firstName = newFirstName
        } else {
            // Créer un nouvel enfant
            let child = Child(firstName: newFirstName, level: Level.beginner.rawValue)
            modelContext.insert(child)
            currentChild = child
            firstName = newFirstName
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Erreur lors de la mise à jour : \(error)")
        }
    }

    /// Supprimer l'enfant actuel
    private func deleteCurrentChild() {
        if let currentChild = currentChild {
            modelContext.delete(currentChild)

            do {
                try modelContext.save()
                self.currentChild = nil
                firstName = ""
                newFirstName = ""
                dismiss()
            } catch {
                print("Erreur lors de la suppression : \(error)")
            }
        }
    }
}

#Preview {
    ProfileView(currentChild: .constant(nil), firstName: .constant(""))
}
