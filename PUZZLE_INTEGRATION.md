# 🧩 Intégration du Système de Puzzle

## 📋 Fichiers Créés

### Models
- **Puzzle.swift** - Modèles de données pour les puzzles (Puzzle, Position, CreatePuzzleRequest, MoveTileRequest, LeaderboardEntry)

### Services
- **PuzzleService.swift** - Service API pour communiquer avec le backend NestJS

### ViewModels
- **PuzzleGameViewModel.swift** - Gestion de la logique du jeu de puzzle côté enfant
- **PuzzleAssignmentViewModel.swift** - Gestion de l'assignation des puzzles côté parent
- **ChildPuzzleListViewModel.swift** - Gestion de la liste des puzzles (intégré dans la vue)
- **PuzzleLeaderboardViewModel.swift** - Gestion du classement (intégré dans la vue)

### Views
#### Child (Enfant)
- **ChildPuzzleListView.swift** - Liste des puzzles assignés à l'enfant

#### Games
- **PuzzleGameView.swift** - Interface de jeu du puzzle
- **PuzzleLeaderboardView.swift** - Classement des meilleurs scores

#### Parent (Parent)
- **PuzzleAssignmentView.swift** - Interface d'assignation des puzzles aux enfants

## 🔌 Intégration dans l'App

### 1. Ajouter à ContentView ou MainTabView

```swift
// Pour l'enfant - Ajouter dans le tab "Games"
ChildPuzzleListView()

// Pour le parent - Ajouter dans le menu
NavigationLink(destination: PuzzleAssignmentView()) {
    Label("Assigner Puzzle", systemImage: "puzzlepiece.fill")
}

// Classement accessible depuis n'importe où
NavigationLink(destination: PuzzleLeaderboardView()) {
    Label("Classement", systemImage: "podium.fill")
}
```

### 2. Endpoints Backend Utilisés

- `POST /puzzle` - Créer un puzzle
- `GET /puzzle/:id` - Récupérer un puzzle
- `PATCH /puzzle/:id/move` - Déplacer une case
- `POST /puzzle/:id/reset` - Réinitialiser un puzzle
- `DELETE /puzzle/:id` - Supprimer un puzzle
- `GET /puzzle/leaderboard/top` - Récupérer le classement

### 3. Fonctionnalités Principales

#### Côté Parent
- ✅ Sélectionner un enfant
- ✅ Choisir la difficulté (3x3, 4x4, 5x5)
- ✅ Créer et assigner un puzzle

#### Côté Enfant
- ✅ Voir la liste des puzzles assignés
- ✅ Jouer au puzzle avec interface intuitive
- ✅ Voir le nombre de mouvements et le temps écoulé
- ✅ Recevoir une notification quand c'est complété
- ✅ Réinitialiser ou rejouer le puzzle
- ✅ Voir le classement global

## 🔄 Flux de Jeu

1. **Parent** crée un puzzle pour un enfant (3x3, 4x4, ou 5x5)
2. **Backend** génère un board mélangé aléatoirement mais résolvable
3. **Enfant** voit le puzzle dans sa liste
4. **Enfant** clique sur un puzzle pour jouer
5. **Enfant** déplace les cases adjacentes à la case vide
6. À chaque mouvement:
   - Appel API au backend
   - Backend retourne le nouvel état du board
   - UI se met à jour avec l'état actuel
7. Quand le puzzle est complété:
   - Backend calcule les stats (mouvements, temps)
   - Récompense accordée
   - Puzzle apparaît dans le classement

## 🎨 Fonctionnalités UI

### Jeu
- Grille responsive basée sur la taille (3x3, 4x4, 5x5)
- Cases adjacentes à la case vide surlignées
- Compteur de mouvements et temps en direct
- Écran de victoire avec stats
- Bouton de réinitialisation

### Classement
- Top 50 des meilleurs scores
- Filtrage par taille de grille
- Affichage des médailles (🥇 🥈 🥉)
- Votre score personnel mis en évidence
- Score calculé : points = 100 / mouvements

## ⚙️ Configuration Requise

### Backend
- Module Puzzle configuré dans `app.module.ts`
- Routes disponibles
- Authentification JWT activée

### Frontend
- AuthViewModel avec `currentUserToken` disponible
- UserDefaults avec clé `"jwt"` pour le token
- APIConfig.baseURL configuré correctement

## 📝 TODO

1. **Intégrer avec la base de données enfants** - La vue `ChildSelectionListView` utilise actuellement des données dummy. À remplacer par:
   ```swift
   // Récupérer les enfants du parent depuis le backend
   ```

2. **Persister les données localement** - Optionnel mais recommandé pour:
   - Cache des puzzles
   - Stats offline

3. **Notifications push** - Quand un enfant complète un puzzle:
   - Notifier le parent
   - Envoyer une récompense

4. **Statistiques améliorées** - Ajouter:
   - Évolution du score
   - Achievements/Badges
   - Comparaison avec autres enfants

## 🚀 Points à Améliorer

1. Ajouter une animation lors de la résolution d'un puzzle
2. Implémenter un système de retry limité
3. Ajouter des hints ou astuces
4. Support de plusieurs langues
5. Mode multijoueur/compétition

## 🔗 Liens Utiles

- Backend NestJS: Puzzle Module, Service, Controller
- Frontend Models: Puzzle.swift
- API Service: PuzzleService.swift
