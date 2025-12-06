# QR Code Implementation Guide

## 📋 Overview
Cette implémentation ajoute la génération et l'affichage automatique de codes QR pour chaque enfant créé. Lorsqu'un parent crée un nouvel enfant, un code QR unique est généré et peut être visualisé dans la page de détail de l'enfant.

## 🔧 Components Created

### 1. **QRCodeService.swift** (Services)
Service responsable de la génération des codes QR.

**Fonctionnalités:**
- `generateQRCode(from:size:)` - Génère un code QR à partir d'une chaîne de caractères et le retourne en Base64
- `generateChildQRData(childId:username:parentId:)` - Crée le contenu du QR code avec les données d'authentification

**Format des données QR:**
```
childId|username|parentId
Exemple: "507f1f77bcf86cd799439011|johnny|507f1f77bcf86cd799439010"
```

### 2. **QRCodeImageView.swift** (Utils)
Composant SwiftUI pour afficher le code QR généré.

**Fonctionnalités:**
- Affiche le code QR depuis une chaîne Base64
- Gère les cas où le QR code n'est pas disponible
- Design cohérent avec l'interface Cleveroo

### 3. **Model Updates** (Child.swift)
Ajout du champ `qrCode` au modèle `Child`:
```swift
var qrCode: String?  // Base64 encoded QR code image
```

### 4. **AuthViewModel Updates**
Deux nouvelles méthodes:

#### a) `addChild()` - Modifiée
Après la création d'un enfant, génère automatiquement un QR code:
- Récupère l'ID de l'enfant créé
- Génère les données QR (childId|username|parentId)
- Crée l'image QR en Base64
- Envoie le QR code au backend pour le stocker

#### b) `updateChildQRCode()` - Nouvelle
Enregistre le QR code généré sur le backend:
```
PUT /parent/children/{childId}/qrcode
Body: { "qrCode": "base64EncodedImage" }
```

### 5. **ChildDetailView Updates**
Ajout de la section QR Code dans la vue de détail de l'enfant:
- Affichage du code QR généré
- Position: Entre "Account Information" et "Assigned Activities"
- Design avec la même esthétique que le reste de l'app
- Animation d'apparition avec délai

## 🔄 Flux Complet

### 1. Création d'un enfant
```
Parent crée un child
     ↓
Backend crée l'enfant et retourne l'ID
     ↓
AuthViewModel génère le QR code
     ↓
QR code est encodé en Base64
     ↓
QR code est envoyé au backend (PUT)
     ↓
Succès affiché à l'utilisateur
```

### 2. Affichage du QR code
```
Parent accède à la vue ChildDetailView
     ↓
Les données enfant sont chargées (incluant qrCode)
     ↓
QRCodeImageView décide le QR code en Base64
     ↓
QR code s'affiche à l'écran
```

## 📱 Interface Utilisateur

### Vue ChildDetailView
Le QR code apparaît dans une section dédiée:
- **Titre:** "Login QR Code" avec icône 🔐
- **Position:** Entre "Account Information" et "Assigned Activities"
- **Taille:** 250x250 pixels
- **Format:** PNG avec correction d'erreur haute (H)

### États possibles
1. **QR code disponible:** Affichage normal du code QR
2. **QR code non disponible:** Placeholder avec message "QR Code not available"

## 🔐 Données du QR Code

Le QR code encode:
```
{childId}|{username}|{parentId}
```

**Exemple décodé:**
```
507f1f77bcf86cd799439011|johnny|507f1f77bcf86cd799439010
```

Cela permet à l'enfant de se connecter en scannant le QR code avec la caméra.

## 🛠️ Backend Requirements

### Endpoint pour sauvegarder le QR code
```
PUT /parent/children/{childId}/qrcode
Authorization: Bearer {token}
Content-Type: application/json

{
  "qrCode": "iVBORw0KGgoAAAANSUhEUgAA..."
}
```

### Response
```json
{
  "message": "QR code updated successfully",
  "qrCode": "iVBORw0KGgoAAAANSUhEUgAA..."
}
```

### Endpoint pour récupérer les enfants
```
GET /parent/children
Authorization: Bearer {token}
```

La réponse doit inclure le champ `qrCode` pour chaque enfant:
```json
{
  "children": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "username": "johnny",
      "age": 8,
      "gender": "male",
      "qrCode": "iVBORw0KGgoAAAANSUhEUgAA...",
      "createdAt": "2025-11-21T10:30:00.000Z"
    }
  ]
}
```

## 📊 API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/parent/children` | Créer un enfant (génère QR code) |
| GET | `/parent/children` | Récupérer la liste des enfants avec QR codes |
| PUT | `/parent/children/{id}/qrcode` | Sauvegarder le QR code |

## 🎨 Styling

Le QR code est affiché avec:
- Fond blanc (pour le contraste)
- Coin arrondi (radius: 15)
- Ombre (shadow: 10)
- Responsive au design Cleveroo

## 🐛 Debugging

### Logs de génération
```
✅ QR Code generated successfully
```

### Logs d'enregistrement
```
✅ QR Code saved to backend for child: {childId}
```

### Logs d'erreur
```
⚠️ Failed to generate QR code
⚠️ Failed to save QR code to backend: {error}
```

## 📝 Notes Importantes

1. **Encoding Base64:** Le QR code est convertis en PNG puis encodé en Base64 pour transmission
2. **Correction d'erreur:** Niveau "H" (High) pour permettre la détection même si partiellement dégradé
3. **Size:** 300x300 pixels (peut être ajusté dans QRCodeService.swift)
4. **Format des données:** Utilise "|" comme séparateur (peut être changé si nécessaire)

## ✅ Checklist d'implémentation

- ✅ QRCodeService créé
- ✅ QRCodeImageView créé
- ✅ Child model mis à jour avec qrCode
- ✅ AuthViewModel.addChild() génère QR code
- ✅ AuthViewModel.updateChildQRCode() créée
- ✅ ChildDetailView affiche le QR code
- ✅ Pas d'erreurs de compilation
- ⏳ À tester avec le backend

## 🚀 Prochaines étapes

1. Implémenter les endpoints backend pour sauvegarder/récupérer les QR codes
2. Tester la génération avec des données réelles
3. Tester le scan et la connexion via QR code
4. Optimiser la résolution du QR code si nécessaire
5. Ajouter la possibilité de télécharger/partager le QR code

