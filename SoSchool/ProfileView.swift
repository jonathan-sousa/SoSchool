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

    @State private var newFirstName = ""
    @State private var showDeleteAlert = false

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

                // Message d'information
                VStack(spacing: 15) {
                    Text("Gestion des profils")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("Pour modifier ou supprimer un utilisateur, retourne à l'écran d'accueil et utilise les options disponibles.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }

                // Informations sur l'application
                VStack(spacing: 15) {
                    Text("À propos")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "graduationcap.fill")
                                .foregroundColor(.blue)
                            Text("SoSchool")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                        }

                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }

                Spacer()

                                // Bouton fermer
                VStack(spacing: 15) {
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
                    deleteCurrentUser()
                }
            } message: {
                Text("Êtes-vous sûr de vouloir supprimer ce profil ? Cette action ne peut pas être annulée.")
            }
        }
    }

    /// Supprimer l'utilisateur actuel
    private func deleteCurrentUser() {
        // Cette fonction n'est plus utilisée dans la nouvelle interface
        dismiss()
    }
}

#Preview {
    ProfileView()
}
