#!/bin/bash

echo "🧹 Nettoyage léger de SoSchool..."

# Arrêter le simulateur s'il tourne
echo "🛑 Arrêt du simulateur..."
xcrun simctl shutdown all 2>/dev/null || true

# Nettoyer le cache Xcode pour SoSchool uniquement
echo "🗑️ Nettoyage du cache Xcode..."
rm -rf ~/Library/Developer/Xcode/DerivedData/SoSchool-* 2>/dev/null || true
rm -rf ~/Library/Developer/Xcode/DerivedData/*/Build/Products/Debug-iphonesimulator/SoSchool.app 2>/dev/null || true

# Nettoyer uniquement les données de SoSchool dans le simulateur (sans effacer tout)
echo "🗑️ Suppression des données de l'application SoSchool..."
SIMULATOR_DEVICES=$(xcrun simctl list devices | grep "iPhone" | grep -v "unavailable" | head -1 | sed 's/.*(\([^)]*\)).*/\1/')
if [ ! -z "$SIMULATOR_DEVICES" ]; then
    # Supprimer uniquement l'app SoSchool si elle existe
    xcrun simctl uninstall "$SIMULATOR_DEVICES" JS-Consulting.SoSchool 2>/dev/null || true
    echo "✅ Données de SoSchool supprimées du simulateur"
else
    echo "⚠️ Aucun simulateur iPhone trouvé"
fi

# Build et installation
echo "🔨 Build de l'application..."
xcodebuild build -project SoSchool.xcodeproj -scheme SoSchool -destination 'platform=iOS Simulator,name=iPhone 16'

if [ $? -eq 0 ]; then
    echo "📱 Installation de l'application..."
    xcodebuild install -project SoSchool.xcodeproj -scheme SoSchool -destination "platform=iOS Simulator,name=iPhone 16"

    if [ $? -eq 0 ]; then
        echo "🎯 Lancement de l'application..."
        xcrun simctl launch booted JS-Consulting.SoSchool

        echo "✅ Rebuild terminé ! L'application devrait maintenant fonctionner sans crash."
        echo ""
        echo "💡 Si le problème persiste, essayez de :"
        echo "   1. Redémarrer Xcode"
        echo "   2. Redémarrer le Mac"
        echo "   3. Vérifier les logs dans la console Xcode"
    else
        echo "❌ Erreur lors de l'installation"
        exit 1
    fi
else
    echo "❌ Erreur lors du build"
    exit 1
fi
