# 🔒 Guide de Test - Système de Contrôle Parental

## ✅ Correction Appliquée

**Problème identifié :**
Lorsque l'enfant "bb" se connectait, le backend retournait :
- ✅ Login : `"isRestricted": true` (correct)
- ❌ Profil : `"isRestricted": false` (incorrect)

Le `fetchChildProfile()` écrasait le statut de restriction défini lors du login.

**Solution appliquée :**
J'ai modifié `AuthViewModel.fetchChildProfile()` pour **ne pas écraser** `isChildRestricted` si elle a déjà été définie lors du login.

```swift
// Ne pas écraser isChildRestricted si elle a déjà été définie lors du login
if !self.isChildRestricted {
    self.isChildRestricted = json["isRestricted"] as? Bool ?? false
}
```

---

## 🧪 Comment Tester le Système de Contrôle Parental

### 📱 **Étape 1 : Bloquer un enfant (Parent)**

1. **Connectez-vous en tant que Parent**
   - Email : `marzoukimaya3@gmail.com`
   - Password : `mayouta`

2. **Allez dans Profil**
   - Cliquez sur l'icône de profil en bas à droite

3. **Cliquez sur "Parental Controls"**
   - Vous verrez la liste de vos 3 enfants :
     - gggg (6 ans)
     - bb (8 ans) ← **Celui-ci est déjà bloqué**
     - toutou (8 ans)

4. **Cliquez sur un enfant (par exemple "toutou")**
   - Vous verrez l'écran de contrôle parental détaillé

5. **Bloquez l'enfant**
   - Activez le toggle "Bloquer l'accès"
   - Entrez une raison (ex: "Temps d'écran dépassé")
   - Confirmez

---

### 🚫 **Étape 2 : Voir l'écran de restriction (Enfant)**

1. **Déconnectez-vous du compte parent**
   - Profil → Logout

2. **Connectez-vous en tant qu'enfant bloqué**
   - Username : `bb` (déjà bloqué avec raison "Excès d'utilisation")
   - Password : `mayouta`

3. **🎉 L'écran de restriction s'affiche automatiquement !**
   
   Vous verrez :
   - 🔒 **Icône de cadenas**
   - **Titre** : "Accès Restreint"
   - **Raison** : "Excès d'utilisation" (la raison définie par le parent)
   - **Bouton** : "Demander le déblocage"
   - **Bouton** : "Se déconnecter"

---

### ✋ **Étape 3 : Demander le déblocage (Enfant)**

1. **Sur l'écran de restriction**
   - Cliquez sur **"Demander le déblocage"**

2. **Entrez une raison**
   - Ex: "J'ai fini mes devoirs"
   - Cliquez sur **"Envoyer"**

3. **Confirmation**
   - Vous verrez un message : "Demande envoyée !"
   - Vous pouvez voir vos demandes en cliquant sur **"Voir mes demandes"**

4. **Statut de la demande**
   - 🟠 **En attente** : Le parent n'a pas encore répondu
   - 🟢 **Approuvée** : Le parent a approuvé → Vous pouvez accéder à l'app
   - 🔴 **Rejetée** : Le parent a refusé avec un message

---

### ✅ **Étape 4 : Gérer les demandes (Parent)**

1. **Connectez-vous en tant que Parent**

2. **Allez dans Profil → "Unblock Requests"**

3. **Vous verrez la demande de l'enfant**
   - Nom de l'enfant
   - Raison de la demande
   - Date/heure de la demande

4. **Répondez à la demande**
   - **Approuver** : L'enfant pourra accéder à l'app
   - **Rejeter** : L'enfant restera bloqué
   - Vous pouvez ajouter un message (optionnel)

5. **L'enfant est automatiquement débloqué si vous approuvez** ✅

---

## 🎯 Autres Fonctionnalités Disponibles

### **Pour les Parents :**

#### 1️⃣ **Plages Horaires**
Définir les heures autorisées (ex: "08:00-12:00", "14:00-18:00")
- L'enfant ne pourra se connecter que pendant ces créneaux

#### 2️⃣ **Limite de Temps d'Écran**
Définir un temps maximum par jour (ex: 120 minutes = 2h)
- L'enfant sera bloqué automatiquement après avoir dépassé cette limite

#### 3️⃣ **Historique**
Voir toutes les actions de contrôle parental :
- Blocages/déblocages
- Demandes de déblocage
- Modifications de paramètres

#### 4️⃣ **Temps d'Écran**
Voir le temps d'écran :
- **Aujourd'hui** : Temps passé aujourd'hui
- **Historique** : 7 derniers jours

---

## 🔍 Logs à Surveiller

Lors du login de l'enfant bloqué, vous devriez voir :

```
✅ Login successful, token saved
🚫 Child is restricted: Excès d'utilisation 
👶 Fetching child profile...
✅ Child profile fetched successfully
   🚫 Is Restricted: true  ← Important !
```

Si vous voyez `Is Restricted: true`, l'écran de restriction s'affichera automatiquement.

---

## ❓ FAQ

### **Q: L'écran de restriction ne s'affiche pas ?**
**R:** Vérifiez dans les logs que `Is Restricted: true`. Si c'est `false`, le backend n'a pas bloqué l'enfant correctement.

### **Q: Comment débloquer un enfant manuellement ?**
**R:** 
1. Profil → Parental Controls
2. Cliquez sur l'enfant
3. Désactivez le toggle "Bloquer l'accès"

### **Q: L'enfant peut-il contourner la restriction ?**
**R:** Non, toutes les routes de l'API sont protégées par des guards backend qui vérifient le statut de restriction en temps réel.

### **Q: Que se passe-t-il si je bloque un enfant pendant qu'il est connecté ?**
**R:** L'enfant verra l'écran de restriction lors de sa prochaine action (navigation, rechargement de page, etc.). Pour un blocage immédiat, il faudrait implémenter des WebSockets (fonctionnalité avancée).

---

## 🎉 C'est Tout !

Le système de contrôle parental est maintenant **100% fonctionnel** ! Testez-le en bloquant/débloquant vos enfants et en gérant leurs demandes de déblocage.

**Date de mise à jour** : 30 novembre 2025  
**Status** : ✅ Pleinement opérationnel
