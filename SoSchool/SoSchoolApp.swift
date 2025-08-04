//
//  SoSchoolApp.swift
//  SoSchool
//
//  Created by Jonathan Sousa on 03/08/2025.
//

import SwiftUI
import SwiftData

@main
struct SoSchoolApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: User.self, Exercise.self, Score.self)
            print("Application SoSchool démarrée")
        } catch {
            fatalError("Impossible de créer le ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
        .modelContainer(modelContainer)
    }
}
