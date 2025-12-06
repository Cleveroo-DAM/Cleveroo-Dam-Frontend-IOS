# Guide Intégration Contrôle Parental - Restrictions Temporelles

## 📅 Date: 30 Novembre 2025

## ✅ Fonctionnalités Intégrées

### 1. **Plages Horaires (Time Slots)** 🕐

L'enfant ne peut utiliser l'application **QUE pendant les plages horaires définies** par le parent.

#### Fonctionnement:
- Le parent définit des plages horaires (ex: 08:00-12:00, 14:00-18:00)
- En dehors de ces plages, l'enfant voit l'écran de restriction
- L'écran affiche le temps restant avant la prochaine plage autorisée

#### Fichiers modifiés/créés:
- ✅ `Models/ParentalControl.swift` - Modèle avec `allowedTimeSlots: [String]`
- ✅ `Utils/RestrictionChecker.swift` - Logique de vérification des plages horaires
- ✅ `Services/ParentalControlService.swift` - API pour définir les plages horaires
- ✅ `ViewModels/ParentalControlViewModel.swift` - Gestion des plages horaires
- ✅ `Views/Parent/TimeSlotsEditorView.swift` - Interface d'édition des plages horaires
- ✅ `Views/Parent/ParentalControlView.swift` - Affichage et modification des plages

### 2. **Limite de Temps d'Écran (Screen Time Limit)** ⏱️

L'enfant ne peut utiliser l'application que pour une durée maximale par jour.

#### Fonctionnement:
- Le parent définit une limite quotidienne (ex: 120 minutes = 2 heures)
- Le backend suit le temps d'utilisation de l'enfant
- Quand la limite est atteinte, l'enfant est automatiquement bloqué
- Le compteur se réinitialise à minuit

#### Fichiers modifiés/créés:
- ✅ `Models/ParentalControl.swift` - Ajout de `dailyScreenTimeLimit: Int?`
- ✅ `Models/ParentalControl.swift` - Modèles `ScreenTimeData` et `ScreenTimeHistoryEntry`
- ✅ `Utils/RestrictionChecker.swift` - Logique de vérification du temps d'écran
- ✅ `Services/ParentalControlService.swift` - API pour définir/récupérer le temps d'écran
- ✅ `ViewModels/ParentalControlViewModel.swift` - Gestion du temps d'écran
- ✅ `Views/Parent/ScreenTimeLimitEditorView.swift` - Interface d'édition de la limite
- ✅ `Views/Parent/ParentalControlView.swift` - Affichage du temps d'écran actuel

### 3. **Vérification en Temps Réel** 🔄

L'application vérifie **automatiquement toutes les 30 secondes** si l'enfant doit être restreint.

#### Fonctionnement:
- Vérification dans `MainTabView` via une boucle asynchrone
- Vérifie 3 conditions:
  1. **Blocage manuel** par le parent
  2. **Plages horaires** - Est-ce que l'heure actuelle est autorisée ?
  3. **Temps d'écran** - La limite quotidienne est-elle dépassée ?
- Si une condition est vraie → Affichage de `RestrictedAccessView`

#### Fichiers modifiés:
- ✅ `Views/MainTabView.swift` - Ajout de `checkRestrictionsLoop()`
- ✅ `Views/Child/RestrictedAccessView.swift` - Affichage des détails de restriction

### 4. **Interface Parent** 👨‍👩‍👧

Le parent peut gérer toutes les restrictions depuis `ParentalControlView`.

#### Fonctionnalités:
- ✅ Voir les plages horaires actuelles
- ✅ Modifier les plages horaires (interface avec sélection d'heures)
- ✅ Voir la limite de temps d'écran
- ✅ Modifier la limite (0 = illimité)
- ✅ Voir le temps d'écran utilisé aujourd'hui par l'enfant
- ✅ Voir l'historique du temps d'écran (7 derniers jours)

### 5. **Interface Enfant** 👶

L'enfant voit un écran de restriction avec toutes les informations.

#### Affichage sur RestrictedAccessView:
- ✅ **Raison de la restriction** (hors plage horaire / limite atteinte / bloqué)
- ✅ **Plages horaires autorisées** (affichées si configurées)
- ✅ **Temps d'écran restant** (si limite configurée)
- ✅ **Temps d'écran utilisé aujourd'hui**
- ✅ Bouton pour **demander le déblocage** au parent
- ✅ Liste des **demandes de déblocage** en cours

---

## 🔧 Architecture Technique

### Modèles de Données

```swift
struct ParentalControl {
    let childId: String
    var isBlocked: Bool                    // Blocage manuel
    var blockReason: String?
    var allowedTimeSlots: [String]         // Ex: ["08:00-12:00", "14:00-18:00"]
    var dailyScreenTimeLimit: Int?         // En minutes (0 = illimité)
}

struct ScreenTimeData {
    let childId: String
    let totalMinutes: Int    // Temps total en minutes
    let hours: Int           // Heures
    let minutes: Int         // Minutes restantes
}
```

### RestrictionChecker (Utils)

Fonctions utilitaires pour vérifier les restrictions:

```swift
// Vérifie si l'heure actuelle est dans les plages autorisées
func isWithinAllowedTimeSlots(_ timeSlots: [String]) -> Bool

// Vérifie si la limite de temps d'écran est dépassée
func isScreenTimeLimitExceeded(usedMinutes: Int, limitMinutes: Int?) -> Bool

// Calcule le temps restant
func remainingScreenTime(usedMinutes: Int, limitMinutes: Int?) -> String

// Calcule le temps avant la prochaine plage
func timeUntilNextSlot(_ timeSlots: [String]) -> String?
```

### Services API

**ParentalControlService** - Endpoints utilisés:

**Parent:**
- `PATCH /parent/parental-control/{childId}/time-slots` - Définir les plages
- `PATCH /parent/parental-control/{childId}/screen-time-limit` - Définir la limite
- `GET /parent/parental-control/{childId}` - Récupérer les paramètres
- `GET /parent/screen-time/{childId}/today` - Temps d'écran du jour
- `GET /parent/screen-time/{childId}/history` - Historique

**Enfant:**
- `GET /child/parental-control` - Ses propres paramètres
- `GET /child/restriction-status` - Son statut de restriction
- `GET /auth/screen-time/today` - Son temps d'écran du jour
- `POST /child/unblock-request` - Demander le déblocage

---

## 🎯 Flux d'Utilisation

### Scénario 1: Parent Configure les Plages Horaires

1. Parent ouvre `ParentalControlView` pour son enfant
2. Clique sur "Modifier les plages horaires"
3. `TimeSlotsEditorView` s'ouvre
4. Parent ajoute des plages (ex: 08:00-12:00, 14:00-18:00)
5. Sauvegarde → API appelée
6. L'enfant ne pourra utiliser l'app que pendant ces heures

### Scénario 2: Parent Configure la Limite de Temps

1. Parent ouvre `ParentalControlView`
2. Clique sur "Modifier la limite"
3. `ScreenTimeLimitEditorView` s'ouvre
4. Parent sélectionne 2 heures (120 minutes)
5. Sauvegarde → API appelée
6. L'enfant sera bloqué après 2h d'utilisation dans la journée

### Scénario 3: Enfant Restreint

1. **10h00** - Enfant ouvre l'app (plage autorisée: 14:00-18:00)
2. `MainTabView` vérifie les restrictions toutes les 30s
3. `RestrictionChecker` détecte qu'on est hors plage horaire
4. `RestrictedAccessView` s'affiche automatiquement
5. Affiche: "En dehors des heures autorisées. Prochaine session dans 4h"
6. Affiche les plages horaires: "14:00-18:00"
7. Enfant peut demander le déblocage au parent

### Scénario 4: Limite de Temps Atteinte

1. **16h30** - Enfant utilise l'app (dans la plage 14:00-18:00)
2. Il a déjà utilisé 120 minutes aujourd'hui (limite atteinte)
3. `RestrictionChecker` détecte le dépassement
4. `RestrictedAccessView` s'affiche
5. Affiche: "Limite de temps d'écran atteinte (120 minutes)"
6. Affiche: "Temps d'écran restant: 0 minutes"

---

## 🔄 Vérification Automatique

Dans `MainTabView.swift`:

```swift
private func checkRestrictionsLoop() async {
    while true {
        if !viewModel.isParent {
            // Charger les données
            await restrictionViewModel.loadMyParentalControl()
            await restrictionViewModel.loadMyScreenTime()
            
            // Vérifier les 3 conditions
            let (restricted, reason) = restrictionViewModel.isCurrentlyRestricted()
            
            if restricted {
                // Bloquer l'enfant
                viewModel.isChildRestricted = true
                viewModel.restrictionReason = reason
            }
        }
        
        // Revérifier dans 30 secondes
        try? await Task.sleep(nanoseconds: 30_000_000_000)
    }
}
```

---

## 📝 Points Importants

### ✅ Ce qui est fait:
1. **Modèles de données** complets
2. **Services API** pour toutes les opérations
3. **Logique de vérification** des restrictions en temps réel
4. **Interfaces parent** pour configurer les restrictions
5. **Interface enfant** pour voir les restrictions et demander le déblocage
6. **Vérification automatique** toutes les 30 secondes

### 🎨 Interfaces Créées:
- `TimeSlotsEditorView.swift` - Édition des plages horaires (avec pickers d'heures)
- `ScreenTimeLimitEditorView.swift` - Édition de la limite de temps (avec slider)
- `RestrictedAccessView.swift` - Écran de restriction côté enfant (amélioré)
- `ParentalControlView.swift` - Dashboard parent (amélioré)

### ⚙️ Configuration Backend Requise:

Le backend doit implémenter:
1. **Suivi du temps d'écran** - Enregistrer les sessions de l'enfant
2. **Reset quotidien** - Réinitialiser le compteur à minuit
3. **Vérification des restrictions** - Endpoint `/child/restriction-status`

---

## 🚀 Résultat Final

L'application dispose maintenant d'un **système complet de contrôle parental** avec:
- ✅ Plages horaires strictes
- ✅ Limites de temps d'écran quotidiennes
- ✅ Vérification en temps réel
- ✅ Interface intuitive pour les parents
- ✅ Feedback clair pour les enfants
- ✅ Système de demande de déblocage

**L'enfant est automatiquement restreint** dès qu'il sort des plages horaires ou dépasse sa limite de temps d'écran !
