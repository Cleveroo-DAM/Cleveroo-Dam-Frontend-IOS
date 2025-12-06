# Guide d'intégration des Rapports AI - Cleveroo iOS

## 📋 Résumé de l'implémentation

J'ai intégré la fonctionnalité complète des **Rapports AI** dans votre application iOS Cleveroo, basée sur votre backend NestJS.

## 🎯 Ce qui a été créé

### 1. **Modèles de données** (`Models/Report.swift`)
- ✅ `Report` - Modèle principal pour les rapports
- ✅ `ActivityStats` - Statistiques par activité
- ✅ `PersonalityInsight` - Insights de personnalité
- ✅ `AIRecommendation` - Recommandations générées par AI
- ✅ `ChartData` - Données pour les graphiques

### 2. **Service API** (`Services/ReportService.swift`)
- ✅ `generateReport()` - Générer un nouveau rapport
- ✅ `getReports()` - Récupérer la liste des rapports
- ✅ `getReport()` - Récupérer un rapport spécifique

### 3. **ViewModel** (`ViewModels/Reports/AIReportViewModel.swift`)
- ✅ Gestion de l'état des rapports
- ✅ Méthodes pour générer et récupérer les rapports
- ✅ Gestion des erreurs
- ✅ Compatibilité avec l'ancien code de reporting

### 4. **Vues SwiftUI**
- ✅ `ReportsListView.swift` - Liste des rapports avec carte de génération
- ✅ `ReportDetailView.swift` - Vue détaillée d'un rapport avec analyses AI

## 🔧 Étapes d'intégration dans Xcode

### Étape 1: Ajouter les fichiers au projet

Les fichiers suivants ont été créés et doivent être ajoutés à Xcode :

1. **Ouvrez Xcode** et votre projet Cleveroo
2. **Clic droit** sur le groupe `Models` → Add Files to "Cleveroo"
   - Sélectionnez : `Cleveroo/Models/Report.swift`
   - ✅ Cochez "Copy items if needed"
   - ✅ Cochez "Add to targets: Cleveroo"

3. **Clic droit** sur le groupe `Services` → Add Files to "Cleveroo"
   - Sélectionnez : `Cleveroo/Services/ReportService.swift`

4. Les vues ont déjà été créées dans `Views/Reports/` :
   - `ReportsListView.swift`
   - `ReportDetailView.swift`

### Étape 2: Vérifier que tous les fichiers sont dans le projet

Après avoir ajouté les fichiers, dans le **Project Navigator** vous devriez voir :

```
Cleveroo/
├── Models/
│   └── Report.swift ✨ NOUVEAU
├── Services/
│   └── ReportService.swift ✨ NOUVEAU
├── ViewModels/
│   └── Reports/
│       └── AIReportViewModel.swift ✅ MIS À JOUR
└── Views/
    └── Reports/
        ├── ReportsListView.swift ✨ NOUVEAU
        └── ReportDetailView.swift ✨ NOUVEAU
```

## 🚀 Comment utiliser dans votre app

### Option 1: Ajouter dans le MainTabView (Parent)

Ajoutez un nouvel onglet pour les rapports dans votre `MainTabView.swift` :

```swift
import SwiftUI

struct ParentMainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            // ... autres tabs existants ...
            
            // NOUVEAU: Onglet Rapports
            ReportsListView(
                token: authViewModel.token ?? "",
                children: authViewModel.children ?? []
            )
            .tabItem {
                Label("Rapports", systemImage: "chart.bar.doc.horizontal")
            }
        }
    }
}
```

### Option 2: Ajouter comme bouton dans la vue Parent

Dans votre vue de profil parent ou dashboard :

```swift
NavigationLink(destination: ReportsListView(
    token: authViewModel.token ?? "",
    children: authViewModel.children ?? []
)) {
    HStack {
        Image(systemName: "chart.bar.fill")
        Text("Voir les rapports")
        Spacer()
        Image(systemName: "chevron.right")
    }
    .padding()
    .background(Color.blue.opacity(0.1))
    .cornerRadius(10)
}
```

## 📊 Fonctionnalités disponibles

### 1. **Liste des rapports**
- Affichage de tous les rapports générés
- Filtrage par enfant
- Génération de nouveaux rapports (quotidien, hebdomadaire, mensuel)

### 2. **Détail du rapport**
Affiche pour chaque rapport :
- 📈 **Performance globale** avec score moyen
- 🎮 **Statistiques par activité** (AI Games, Memory, Math, Puzzles)
- 🧠 **Insights de personnalité** avec tendances
- ⭐ **Points forts** identifiés par l'AI
- 📊 **Axes d'amélioration**
- 💡 **Recommandations personnalisées**
- 📉 **Graphiques** (scores par activité, répartition du temps)
- 🏆 **Stats de gamification** (XP, badges, séries)

## 🔌 Endpoints Backend utilisés

L'application communique avec votre backend via ces endpoints :

1. **POST** `/reports/generate/:childId?period=weekly`
   - Génère un nouveau rapport pour un enfant

2. **GET** `/reports?childId=xxx`
   - Récupère tous les rapports (optionnellement filtrés par enfant)

3. **GET** `/reports/:reportId`
   - Récupère un rapport spécifique

## ⚙️ Configuration

Le service utilise automatiquement la configuration API dans `APIConfig.swift` :

```swift
static let reportsBaseURL = "\(baseURL)/reports"
```

## 🧪 Test de l'intégration

### 1. Vérifier la compilation
```bash
cd /Users/maya_marzouki/IOSProjects/DAM/Dam-Cleveroo
xcodebuild -project Cleveroo.xcodeproj -scheme Cleveroo -sdk iphoneos -configuration Debug
```

### 2. Tester dans le simulateur
1. Lancez l'app
2. Connectez-vous en tant que parent
3. Naviguez vers "Rapports"
4. Cliquez sur "Générer un rapport"
5. Sélectionnez un enfant et une période
6. Vérifiez que le rapport est bien généré et affiché

## 🔍 Débogage

Si vous rencontrez des problèmes :

### Vérifier les logs API
Les services loggent toutes les requêtes avec le préfixe `🌐 APIConfig:`

```swift
APIConfig.log("🔄 Generating weekly report for child xxx")
```

### Vérifier le token JWT
Assurez-vous que le token est bien passé au service :

```swift
print("Token: \(authViewModel.token ?? "NO TOKEN")")
```

### Vérifier la réponse du backend
Ajoutez des breakpoints dans `ReportService.swift` pour voir les réponses :

```swift
.tryMap { data, response -> Data in
    // Ajoutez un breakpoint ici
    print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
    return data
}
```

## 📝 Notes importantes

1. **Charts Framework** : La vue utilise Swift Charts (iOS 16+)
   - Si vous ciblez iOS 15, commentez les sections de graphiques

2. **Images d'enfants** : Les avatars sont chargés via AsyncImage
   - Assurez-vous que les URLs des avatars sont accessibles

3. **Authentification** : Toutes les requêtes nécessitent un token JWT valide

4. **Décodage des dates** : Le service utilise ISO8601 pour décoder les dates
   - Assurez-vous que votre backend retourne des dates au format ISO8601

## 🎨 Personnalisation

### Modifier les couleurs
Dans `ReportDetailView.swift`, vous pouvez personnaliser :

```swift
// Couleurs de performance
private var scoreColor: Color {
    switch insight.score {
    case 80...100: return .green  // Modifier ici
    case 60...79: return .blue
    case 40...59: return .orange
    default: return .red
    }
}
```

### Ajouter des graphiques personnalisés
Dans la section `chartsSection`, ajoutez vos propres graphiques :

```swift
Chart(customData) { item in
    LineMark(
        x: .value("Date", item.date),
        y: .value("Score", item.score)
    )
}
```

## ✅ Checklist de validation

- [ ] Les fichiers sont ajoutés au projet Xcode
- [ ] Le projet compile sans erreurs
- [ ] L'app se lance correctement
- [ ] La vue des rapports est accessible
- [ ] La génération de rapport fonctionne
- [ ] Le détail du rapport s'affiche correctement
- [ ] Les graphiques s'affichent (iOS 16+)
- [ ] Les recommandations AI sont visibles
- [ ] Les insights de personnalité sont affichés

## 🆘 Support

Si vous avez besoin d'aide ou de modifications :
1. Vérifiez les logs dans la console
2. Testez les endpoints backend avec Postman
3. Vérifiez que les modèles correspondent au backend

## 🎉 Prochaines étapes

1. **Notifications** : Ajouter des notifications push quand un rapport est généré
2. **Export PDF** : Permettre l'export des rapports en PDF
3. **Partage** : Partager les rapports par email
4. **Historique** : Comparer les rapports précédents
5. **Widgets** : Créer un widget iOS pour voir les derniers rapports

---

**Bon développement ! 🚀**
