# SoSchool - Application iOS d'apprentissage

## 📱 Description

Application SwiftUI moderne pour l'apprentissage de la conjugaison française. Utilise SwiftData pour la persistance des données et propose des exercices interactifs pour les utilisateurs.

## 🏗️ Architecture

- **SwiftUI** : Interface utilisateur moderne et responsive
- **SwiftData** : Persistance des données (iOS 17+)
- **@Observable** : Gestion d'état moderne
- **Testing** : Tests unitaires et UI

## 🚀 Fonctionnalités

- ✅ **Exercices de conjugaison** : QCM interactifs
- ✅ **Gestion des utilisateurs** : Profils personnalisés
- ✅ **Système de scores** : Records et progression
- ✅ **Niveaux d'apprentissage** : Débutant, Intermédiaire, Avancé
- ✅ **Interface adaptative** : iPhone et iPad
- ✅ **Timer intégré** : Mesure du temps de réponse

## 📁 Structure

```
SoSchool/
├── SoSchool/                    # Code source principal
│   ├── SoSchoolApp.swift       # Point d'entrée avec SwiftData
│   ├── Models.swift            # Modèles SwiftData (@Model)
│   ├── ScoreManager.swift      # Gestion des scores et records
│   ├── ExerciseData.swift      # Génération d'exercices
│   ├── WelcomeView.swift       # Vue d'accueil
│   ├── ExerciseView.swift      # Vue des exercices
│   ├── LevelSelectionView.swift # Sélection des niveaux
│   ├── ExerciseSelectionView.swift # Types d'exercices
│   └── ProfileView.swift       # Gestion des profils
├── SoSchoolTests/              # Tests unitaires
└── SoSchoolUITests/            # Tests d'interface
```

## 🛠️ Configuration requise

- Xcode 15.0+
- iOS 17.0+ (SwiftData)
- iPadOS 17.0+

## 🎯 Types d'exercices

### QCM (Questions à Choix Multiples)

- Compléter des phrases avec la bonne conjugaison
- 4 options de réponse
- Feedback immédiat
- Progression par niveau

### Niveaux disponibles

- **Débutant** : Verbes du 1er groupe (er)
- **Intermédiaire** : Verbes du 2ème groupe (ir)
- **Avancé** : Verbes du 3ème groupe (re, oir)

## 📊 Système de données

L'application utilise SwiftData avec trois modèles principaux :

### User (Utilisateur)

- **firstName** : Prénom de l'utilisateur
- **level** : Niveau d'apprentissage
- **createdAt** : Date de création
- **scores** : Relation vers les scores

### Exercise (Exercice)

- **type** : Type d'exercice (QCM, etc.)
- **verb** : Verbe à conjuguer
- **level** : Niveau de difficulté
- **sentence** : Phrase à compléter
- **correctAnswer** : Réponse correcte
- **options** : Options de réponse
- **subject** : Sujet grammatical

### Score (Score)

- **score** : Score obtenu
- **maxScore** : Score maximum possible
- **elapsedTime** : Temps écoulé
- **completedAt** : Date de completion
- **user** : Relation vers l'utilisateur
- **exercise** : Relation vers l'exercice

## 🧪 Tests

### Tests unitaires

```bash
xcodebuild test -scheme SoSchool -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Tests UI

```bash
xcodebuild test -scheme SoSchool -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:SoSchoolUITests
```

## 🚀 Déploiement

### Simulateur

1. Ouvrir `SoSchool.xcodeproj` dans Xcode
2. Sélectionner un simulateur iOS 17+
3. Appuyer sur `Cmd + R`

### Appareil physique

1. Connecter l'appareil iOS/iPadOS 17+
2. Configurer le certificat de développement
3. Sélectionner l'appareil dans Xcode
4. Appuyer sur `Cmd + R`

## 🔧 Développement

### Ajouter un nouveau type d'exercice

1. Créer la vue d'exercice dans `ExerciseView.swift`
2. Ajouter le type dans `ExerciseType` enum
3. Implémenter la logique de génération dans `ExerciseData.swift`
4. Tester sur simulateur et appareil

### Bonnes pratiques

- Utiliser `@Observable` au lieu de `ObservableObject`
- Préférer `@Environment(\.modelContext)` à `@EnvironmentObject`
- Gérer les erreurs SwiftData avec `do-catch`
- Tester sur différentes tailles d'écran
- Respecter les guidelines Apple

## 🎨 Interface utilisateur

- **Design moderne** : SF Symbols et couleurs iOS
- **Responsive** : Adapté iPhone et iPad
- **Accessibilité** : Support VoiceOver
- **Animations fluides** : Transitions SwiftUI

## 📈 Progression

- **Système de records** : Meilleur score par exercice
- **Historique** : Suivi des performances
- **Niveaux** : Progression automatique
- **Feedback** : Encouragements et corrections

## 🔄 Migration

L'application a été migrée de Core Data vers SwiftData pour :

- ✅ **Simplicité** : Moins de code boilerplate
- ✅ **Performance** : Plus rapide que Core Data
- ✅ **Type-safety** : Compile-time safety
- ✅ **SwiftUI intégré** : `@Query` et `@Model`
