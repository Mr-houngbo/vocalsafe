# VocaSafe Flutter 🎤

Application Mobile Money avec interface vocale pour les populations analphabètes au Sénégal.

## 📱 Description

VocaSafe est une application de transfert d'argent mobile conçue spécifiquement pour les populations analphabètes du Sénégal. L'interface entièrement vocale permet d'effectuer des transactions simples et sécurisées sans avoir besoin de lire ou écrire.

## 🎯 Fonctionnalités principales

### 🗣️ Interface Vocale Complète
- **Reconnaissance vocale** en français sénégalais
- **Synthèse vocale** pour la lecture des informations
- **Confirmation audio** après chaque commande
- **Navigation vocale** intuitive

### 💸 Transactions Mobile Money
- Envoi d'argent par commande vocale
- Réception et consultation du solde
- Recharge de crédit mobile
- Paiement de factures

### 🛡️ Sécurité IA
- **Détection anti-fraude** par intelligence artificielle
- **Confirmation vocale** obligatoire
- **Alertes de sécurité** en temps réel
- **Transactions sécurisées** avec vérification

### 📊 Gestion Complète
- **Historique détaillé** avec recherche vocale
- **Alertes et notifications** personnalisées
- **Support client 24/7** par voix
- **Tutoriels vocaux** intégrés

## 🏗️ Architecture Technique

### Structure du Projet
```
lib/
├── core/
│   ├── theme/           # Thème et couleurs
│   ├── router/          # Navigation GoRouter
│   └── services/        # Services vocaux
├── features/
│   ├── home/           # Écran d'accueil
│   ├── voice/          # Reconnaissance et confirmation vocale
│   ├── transaction/    # Gestion des transactions
│   ├── history/        # Historique des transactions
│   ├── alerts/         # Alertes et notifications
│   ├── profile/        # Profil utilisateur
│   └── navigation/     # Navigation principale
└── main.dart
```

### Technologies Utilisées
- **Flutter 3.10+** - Framework cross-platform
- **Riverpod** - Gestion d'état
- **GoRouter** - Navigation déclarative
- **speech_to_text** - Reconnaissance vocale
- **flutter_tts** - Synthèse vocale
- **Google Fonts** - Typographie Inter

## 🎨 Design System

### Palette de Couleurs
- **Vert Primaire** : `#059669` (Sécurité, confiance)
- **Orange Primaire** : `#D97706` (Actions, interactions)
- **Fond Clair** : `#F9FAFB` (Interface épurée)
- **Fond Chaud** : `#FFF7ED` (Ambiance accueillante)

### Typographie
- **Police** : Inter (Google Fonts)
- **Tailles** : Hiérarchie claire pour l'accessibilité
- **Épaisseurs** : Optimisées pour la lisibilité

### Composants UI
- **Boutons vocaux** : 150px pour l'accessibilité
- **Cartes** : Coins arrondis 16px, ombres subtiles
- **Animations** : Fluides et naturelles
- **Feedback** : Visuel et audio systématique

## 🚀 Installation et Démarrage

### Prérequis
- Flutter SDK 3.10 ou supérieur
- Dart SDK compatible
- Android Studio / VS Code
- Émulateur Android ou appareil physique

### Installation
1. Cloner le projet :
```bash
git clone [repository-url]
cd flutter_vocasafe
```

2. Installer les dépendances :
```bash
flutter pub get
```

3. Configurer les permissions (Android) :
Ajouter dans `android/app/src/main/AndroidManifest.xml` :
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

4. Lancer l'application :
```bash
flutter run
```

## 📱 Écrans de l'Application

### 1. Accueil 🏠
- Bouton vocal géant (150px)
- Exemples de commandes
- Badge de sécurité IA
- Navigation à 4 onglets

### 2. Écoute Vocale 🎤
- Animation d'ondes sonores
- Microphone pulsant
- Transcription en temps réel
- Bouton d'annulation

### 3. Confirmation Audio 🔊
- Lecture automatique de la commande
- Bulle de dialogue avec transcription
- Indicateur de lecture audio
- Boutons Oui/Non

### 4. Récapitulatif Transaction 📄
- Détails complets de la transaction
- Lecture automatique du récapitulatif
- Bouton de confirmation vocale
- Badge de sécurité

### 5. Succès ✅
- Animation de checkmark
- Reçu de transaction
- Options de partage
- Retour à l'accueil

### 6. Historique 📊
- Liste des transactions
- Recherche vocale
- Filtres par catégorie
- Statuts visuels

### 7. Alertes 🔔
- Centre de notifications
- Catégories (Sécurité, Transaction, Promotion)
- Badges de non-lecture
- Support 24/7

### 8. Profil 👤
- Informations utilisateur
- Support vocal intégré
- Tutoriels et paramètres
- Options multilingues

## 🔧 Développement

### Commandes Utiles
```bash
# Analyser le code
flutter analyze

# Exécuter les tests
flutter test

# Build pour production
flutter build apk --release
flutter build ios --release
```

### Architecture Clean
- **Séparation des responsabilités**
- **Services injectables**
- **Widgets réutilisables**
- **Gestion d'état centralisée**

### Bonnes Pratiques
- Code commenté en français
- Noms de variables explicites
- Tests unitaires pour les services critiques
- Documentation des API

## 🌍 Accessibilité

### Conception Inclusive
- **Contraste WCAG AA** minimum
- **Taille de police** adaptable
- **Navigation vocale** complète
- **Feedback audio** systématique

### Support des Langues
- Français (principal)
- Wolof (à implémenter)
- Autres langues locales (futures)

## 🔒 Sécurité

### Protection des Données
- **Chiffrement** des transactions
- **Authentification** vocale
- **Détection d'anomalies** IA
- **Conformité** RGPD

### Anti-Fraude
- **Analyse comportementale**
- **Limites de transaction**
- **Alertes en temps réel**
- **Vérification multi-facteurs**

## 📈 Feuille de Route

### Version 1.0 (Actuelle)
- ✅ Interface vocale complète
- ✅ Transactions de base
- ✅ Sécurité IA
- ✅ Navigation intuitive

### Version 1.1 (Prochaine)
- 🔄 Support multilingue complet
- 🔄 Paiement de factures
- 🔄 Portefeuille virtuel
- 🔄 Analytics avancés

### Version 2.0 (Future)
- 📋 Intégration bancaire
- 📋 Cartes de crédit virtuelles
- 📋 IA prédictive
- 📋 Blockchain optionnelle

## 🤝 Contribution

### Guide pour les Développeurs
1. Forker le projet
2. Créer une branche feature
3. Implémenter avec tests
4. Soumettre une Pull Request

### Standards de Code
- Flutter/Dart conventions
- Commentaires en français
- Tests > 80% couverture
- Documentation complète

## 📞 Support

### Contact
- **Email** : support@vocasafe.sn
- **Téléphone** : +221 77 123 45 67
- **Support vocal** : Disponible 24/7 dans l'app

### Documentation
- [Guide utilisateur](docs/user-guide.md)
- [Documentation API](docs/api.md)
- [Tutoriels vidéo](docs/tutorials.md)

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🙏 Remerciements

- **Ministère du Numérique** du Sénégal
- **Incubateurs locaux** pour l'accompagnement
- **Communauté Flutter** Sénégal
- **Testeurs bêta** des régions rurales

---

**Made with 💚 pour le Sénégal • VocaSafe 2025**
