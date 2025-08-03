# SoSchool - Application iOS de test

## 📱 Description

Application SwiftUI basique pour tester le déploiement sur iOS et iPadOS. Inclut Core Data pour la persistance des données.

## 🏗️ Architecture

- **SwiftUI** : Interface utilisateur moderne
- **Core Data** : Persistance des données
- **Testing** : Tests unitaires et UI

## 🚀 Fonctionnalités

- ✅ **Liste d'items** : Affichage avec timestamps
- ✅ **Ajout d'items** : Bouton "+" pour créer
- ✅ **Suppression** : Swipe-to-delete
- ✅ **Navigation** : Interface native iOS

## 📁 Structure

```
SoSchool/
├── SoSchool/                    # Code source principal
│   ├── SoSchoolApp.swift       # Point d'entrée
│   ├── ContentView.swift       # Vue principale
│   ├── Persistence.swift       # Gestion Core Data
│   └── SoSchool.xcdatamodeld/ # Modèle de données
├── SoSchoolTests/              # Tests unitaires
└── SoSchoolUITests/            # Tests d'interface
```

## 🛠️ Configuration requise

- Xcode 15.0+
- iOS 17.0+
- iPadOS 17.0+

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
2. Sélectionner un simulateur iOS
3. Appuyer sur `Cmd + R`

### Appareil physique

1. Connecter l'appareil iOS/iPadOS
2. Configurer le certificat de développement
3. Sélectionner l'appareil dans Xcode
4. Appuyer sur `Cmd + R`

## 📊 Données

L'application utilise Core Data avec une entité `Item` :

- **timestamp** : Date de création automatique
- **CRUD complet** : Create, Read, Update, Delete

## 🔧 Développement

### Ajouter une nouvelle fonctionnalité

1. Créer la vue SwiftUI
2. Ajouter le modèle Core Data si nécessaire
3. Implémenter les tests
4. Tester sur simulateur et appareil

### Bonnes pratiques

- Utiliser les property wrappers SwiftUI appropriés
- Gérer les erreurs Core Data
- Tester sur différentes tailles d'écran
- Respecter les guidelines Apple
