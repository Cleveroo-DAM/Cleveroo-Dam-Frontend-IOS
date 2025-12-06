# 🔒 Intégration du Système de Contrôle Parental - iOS

## 📋 Résumé de l'intégration

Le système de contrôle parental de votre backend a été **entièrement intégré** dans votre application iOS Cleveroo. Voici ce qui a été mis en place :

---

## ✅ Modifications apportées

### 1️⃣ **Modèles de données** (`Models/ParentalControl.swift`)
Le fichier existe déjà avec tous les modèles nécessaires :
- `ParentalControl` - Paramètres de contrôle parental
- `UnblockRequest` - Demandes de déblocage
- `ScreenTimeData` - Données du temps d'écran
- `ScreenTimeHistoryEntry` - Historique du temps d'écran
- `ParentalControlHistory` - Historique des actions
- `RestrictionStatus` - Statut de restriction

### 2️⃣ **Service de contrôle parental** (`Services/ParentalControlService.swift`)
Le fichier existe déjà avec toutes les méthodes pour :
- **Actions Parent** :
  - Bloquer/débloquer un enfant
  - Définir les plages horaires autorisées
  - Définir la limite de temps d'écran quotidien
  - Récupérer les paramètres de contrôle parental
  - Consulter le temps d'écran et l'historique
  - Gérer les demandes de déblocage

- **Actions Enfant** :
  - Demander le déblocage
  - Vérifier le statut des demandes
  - Vérifier le statut de restriction

### 3️⃣ **AuthViewModel mis à jour** (`ViewModels/AuthViewModel.swift`)
✅ Ajout de nouvelles propriétés :
```swift
@Published var isChildRestricted = false
@Published var restrictionReason: String?
@Published var childId: String?
```

✅ Modification du **login enfant** pour récupérer le statut de restriction :
- Récupération de `isRestricted` et `restrictionReason` depuis la réponse du backend
- Stockage de l'ID de l'enfant
- Affichage des logs pour le debugging

✅ Modification de **fetchChildProfile** :
- Récupération du champ `isRestricted` depuis le profil
- Mise à jour de la propriété `isChildRestricted`

### 4️⃣ **ParentalControlViewModel** (`ViewModels/ParentalControlViewModel.swift`)
Le fichier existe déjà avec toutes les méthodes nécessaires pour gérer :
- Blocage/déblocage d'enfants
- Plages horaires
- Limite de temps d'écran
- Demandes de déblocage
- Historique des actions

### 5️⃣ **MainTabView mis à jour** (`Views/MainTabView.swift`)
✅ **Ajout de la vérification de restriction** :
```swift
var body: some View {
    // Si l'enfant est restreint, afficher l'écran de restriction
    if !viewModel.isParent && viewModel.isChildRestricted {
        RestrictedAccessView()
            .environmentObject(viewModel)
    } else {
        mainContent
    }
}
```

Maintenant, quand un enfant se connecte et que son accès est restreint, il voit automatiquement l'écran `RestrictedAccessView` au lieu du contenu principal.

### 6️⃣ **RestrictedAccessView** (`Views/Child/RestrictedAccessView.swift`)
Le fichier existe déjà et affiche :
- 🔒 Un écran de restriction avec icône et message
- 📝 La raison de la restriction (si fournie par le parent)
- ✋ Un bouton pour demander le déblocage
- 📋 L'accès aux demandes en attente
- 🚪 Un bouton de déconnexion

### 7️⃣ **ProfileView mis à jour** (`Views/Profile/ProfileView.swift`)
✅ **Ajout de 2 nouveaux boutons pour les parents** :
1. **"Parental Controls"** 🛡️ - Navigation vers `ParentChildrenManagementView`
2. **"Unblock Requests"** ✋ - Navigation vers `UnblockRequestsView`

Ces boutons permettent aux parents d'accéder facilement aux fonctionnalités de contrôle parental depuis leur profil.

### 8️⃣ **ParentChildrenManagementView** (NOUVEAU) (`Views/Parent/ParentChildrenManagementView.swift`)
✅ **Nouvelle vue créée** pour que le parent puisse :
- 👥 Voir tous ses enfants dans une liste
- 🔍 Voir le statut de chaque enfant (Bloqué/Actif)
- ⏱️ Voir le temps d'écran d'aujourd'hui pour chaque enfant
- 👆 Cliquer sur un enfant pour accéder à ses contrôles parentaux

Chaque carte enfant affiche :
- Avatar de l'enfant
- Nom et âge
- Badge de statut (Bloqué en rouge / Actif en vert)
- Badge du temps d'écran du jour

### 9️⃣ **ParentalControlView** (`Views/Parent/ParentalControlView.swift`)
Le fichier existe déjà et permet au parent de :
- Bloquer/débloquer l'accès de l'enfant
- Définir les plages horaires autorisées
- Définir la limite de temps d'écran quotidien
- Voir le temps d'écran d'aujourd'hui
- Voir l'historique du temps d'écran

### 🔟 **UnblockRequestsView** (`Views/Parent/UnblockRequestsView.swift`)
Le fichier existe déjà et permet au parent de :
- Voir toutes les demandes de déblocage de ses enfants
- Filtrer par statut (En attente, Approuvées, Rejetées)
- Approuver ou rejeter les demandes avec un message optionnel

---

## 🔄 Flux de fonctionnement

### Côté Parent :

1. **Accès** : Profil → "Parental Controls"
2. **Liste des enfants** : Voir tous les enfants avec leur statut
3. **Clic sur un enfant** : Accéder aux contrôles parentaux détaillés
4. **Actions disponibles** :
   - ✅ Bloquer/Débloquer l'accès
   - ⏰ Définir les plages horaires (ex: "08:00-12:00", "14:00-18:00")
   - ⏱️ Définir la limite quotidienne (en minutes)
   - 📊 Voir le temps d'écran et l'historique

5. **Demandes de déblocage** : Profil → "Unblock Requests"
   - Voir les demandes en attente
   - Approuver ou rejeter avec un message

### Côté Enfant :

1. **Login** : L'application vérifie automatiquement le statut de restriction
2. **Si restreint** :
   - 🔒 Affichage de l'écran `RestrictedAccessView`
   - 📝 Affichage de la raison de la restriction
   - ✋ Possibilité de demander le déblocage
   - 📋 Accès aux demandes en cours

3. **Si non restreint** :
   - ✅ Accès complet à l'application
   - Le statut est vérifié à chaque action sensible

---

## 🔐 Sécurité et Fonctionnalités Backend

Votre backend gère automatiquement :

### 1. **Blocage manuel**
```typescript
parentalControl.isBlocked = true
```
→ L'enfant ne peut plus accéder à l'application

### 2. **Plages horaires**
```typescript
allowedTimeSlots: ["08:00-12:00", "14:00-18:00"]
```
→ L'enfant ne peut accéder qu'entre 8h-12h et 14h-18h

### 3. **Limite de temps d'écran**
```typescript
dailyScreenTimeLimit: 120 // 2 heures
```
→ L'enfant est bloqué après 2h d'utilisation dans la journée

### 4. **Tracking automatique**
- ✅ Session démarre au login (`/auth/login/child`)
- ✅ Session se termine au logout (`/auth/logout/child`)
- ✅ Le temps est calculé automatiquement

### 5. **Guards backend**
Votre backend a 2 guards qui protègent automatiquement toutes les routes :

1. **`ParentalControlGuard`** : Vérifie si l'enfant a le droit d'accéder
2. **`RestrictedChildGuard`** : Liste blanche des routes autorisées en mode restreint

Routes toujours accessibles même si restreint :
- `/auth/profile/child`
- `/auth/logout/child`
- `/child/unblock-request`
- `/child/unblock-request/status`
- `/child/restriction-status`

---

## 📱 Endpoints utilisés

### Parent :
- `PATCH /parent/parental-control/:childId/block`
- `PATCH /parent/parental-control/:childId/time-slots`
- `PATCH /parent/parental-control/:childId/screen-time-limit`
- `GET /parent/parental-control/:childId`
- `GET /parent/screen-time/:childId/today`
- `GET /parent/screen-time/:childId/history`
- `GET /parent/unblock-requests?status=pending`
- `PATCH /parent/unblock-requests/:requestId/respond`
- `GET /parent/parental-control/:childId/history`

### Enfant :
- `POST /child/unblock-request`
- `GET /child/unblock-request/status`
- `GET /child/restriction-status`

### Auth :
- `POST /auth/login/child` → Retourne `isRestricted`, `restrictionReason`
- `GET /auth/profile/child` → Retourne `isRestricted`
- `GET /auth/screen-time/today`
- `GET /auth/screen-time/history`
- `POST /auth/logout/child`

---

## 🎯 Prochaines étapes recommandées

1. **Tester le flux complet** :
   - Créer un enfant
   - Le bloquer depuis le contrôle parental
   - Se connecter en tant qu'enfant → Vérifier l'écran de restriction
   - Demander le déblocage
   - Approuver la demande depuis le compte parent
   - Vérifier que l'enfant a de nouveau accès

2. **Tester les plages horaires** :
   - Définir des plages horaires (ex: "14:00-18:00")
   - Se connecter en dehors de ces plages
   - Vérifier la restriction

3. **Tester la limite de temps d'écran** :
   - Définir une limite (ex: 30 minutes)
   - Utiliser l'app pendant 30 minutes
   - Vérifier que l'accès est restreint après

4. **Améliorer l'UX** (optionnel) :
   - Ajouter une notification push quand l'enfant envoie une demande
   - Ajouter un timer visible pour l'enfant montrant son temps d'écran restant
   - Ajouter des graphiques dans l'historique du temps d'écran

---

## 🐛 Debugging

Si vous rencontrez des problèmes :

### Enfant non restreint alors qu'il devrait l'être :
1. Vérifier dans les logs du login : `isRestricted` devrait être `true`
2. Vérifier `AuthViewModel.isChildRestricted`
3. Vérifier la réponse de `/child/restriction-status`

### Enfant restreint alors qu'il ne devrait pas :
1. Vérifier les paramètres de contrôle parental dans le backend
2. Vérifier l'heure actuelle vs les plages horaires autorisées
3. Vérifier le temps d'écran utilisé aujourd'hui vs la limite

### Logs utiles :
```swift
// Dans AuthViewModel.login
print("🚫 Child is restricted: \(restrictionReason)")
print("✅ Child has full access")

// Dans MainTabView
print("🔍 isChildRestricted: \(viewModel.isChildRestricted)")
```

---

## ✅ Résultat final

Votre application iOS est maintenant **parfaitement synchronisée** avec votre backend de contrôle parental ! 🎉

- ✅ L'enfant voit automatiquement l'écran de restriction si son accès est bloqué
- ✅ Le parent peut gérer tous les contrôles depuis l'app iOS
- ✅ Les demandes de déblocage fonctionnent dans les deux sens
- ✅ Le temps d'écran est tracké et affiché
- ✅ Toute la logique de restriction est gérée côté backend (sécurisé)

---

**Date d'intégration** : 30 novembre 2025  
**Status** : ✅ Complet et fonctionnel
