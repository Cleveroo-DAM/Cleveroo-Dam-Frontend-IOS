# 🔄 Integration iOS - Backend QR Code

## 📋 Résumé des Modifications iOS

### 1. **QRCodeService.swift** - Adapté au backend
- ✅ Nouveau endpoint : `POST /qr/children/{childId}/generate`
- ✅ Méthode `generateQRTokenForChild()` pour récupérer le token QR du backend
- ✅ Méthode `uiImageFromDataURI()` pour convertir le DataURI en UIImage
- ✅ Méthode `base64FromDataURI()` pour extraire le Base64 du DataURI
- ✅ Localisation : Base URL pointe vers `http://localhost:3000/qr`

### 2. **AuthViewModel.swift** - Intégration backend
- ✅ Modification de `addChild()` : appelle `generateQRTokenForChild()` après création
- ✅ Nouvelle méthode `generateQRTokenForChild()` : récupère le token QR du backend
- ✅ Suppression de `updateChildQRCode()` (plus nécessaire)

### 3. **ChildDetailView.swift** - Affichage du token et de l'image QR
- ✅ Champs d'état : `@State var qrToken`, `@State var qrImage`, `@State var isLoadingQR`
- ✅ Section QR Code affichant :
  - L'image QR générée (250x250)
  - Le token QR (première partie visible)
  - Message d'instruction
- ✅ Méthode `loadQRToken()` : charge le token et génère l'image localement
- ✅ Support du DataURI du backend comme fallback

## 🔄 Flux Complet

```
Parent accède à ChildDetailView
      ↓
onAppear() appelle loadQRToken(childId)
      ↓
AuthViewModel.generateQRTokenForChild() appelle le backend
      ↓
Backend génère le token QR et retourne :
  - token: "hex_token_32_bytes"
  - qrDataUri: "data:image/png;base64,iVBORw0KGgo..."
  - expiresAt: timestamp
      ↓
iOS génère localement l'image QR à partir du token
      ↓
Affichage du token + image QR
```

## 📦 Structure Backend Attendue

Votre backend doit déjà avoir :

### ✅ Endpoint POST `/qr/children/{childId}/generate`
```typescript
POST /qr/children/{childId}/generate
Authorization: Bearer {token}
Content-Type: application/json

{
  "ttlSeconds": 120,
  "returnQrImage": true
}
```

**Response:**
```json
{
  "token": "a1b2c3d4e5f6g7h8...",
  "expiresAt": "2025-11-21T15:30:00.000Z",
  "qrDataUri": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAA..."
}
```

### ✅ Endpoint POST `/qr/exchange`
```typescript
POST /qr/exchange
Content-Type: application/json

{
  "token": "a1b2c3d4e5f6g7h8..."
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "childId": "507f1f77bcf86cd799439011"
}
```

## 🎯 Données Stockées dans MongoDB

### QrToken Collection
```javascript
{
  _id: ObjectId("..."),
  token: "a1b2c3d4e5f6g7h8...",
  childId: ObjectId("507f1f77bcf86cd799439011"),
  parentId: ObjectId("507f1f77bcf86cd799439010"),
  used: false,
  expiresAt: ISODate("2025-11-21T15:30:00.000Z"),
  createdAt: ISODate("2025-11-21T15:10:00.000Z"),
  updatedAt: ISODate("2025-11-21T15:10:00.000Z")
}
```

## 🔐 Sécurité

✅ **Token Temporary** : Expire après 2 minutes (par défaut)
✅ **One-time Use** : Marqué comme `used: true` après échange
✅ **TTL Index** : MongoDB supprime automatiquement les tokens expirés
✅ **Authorization** : Endpoints protégés par JWT
✅ **Validation** : Vérification que l'enfant appartient au parent

## 🚀 Flux de Connexion Enfant via QR

1. **Parent génère QR** : accède à ChildDetailView
2. **Backend génère token** : `/qr/children/{childId}/generate`
3. **iOS affiche QR** : image générée localement + token
4. **Enfant scanne QR** : scanner lit le token
5. **Enfant échange token** : POST `/qr/exchange` avec le token
6. **Backend valide** :
   - Token existe et n'est pas expiré
   - Token n'a pas été utilisé
   - Marque comme `used: true`
7. **Backend retourne JWT** : accès_token pour l'enfant
8. **Enfant connecté** : utilise le JWT

## ✅ Points de Vérification

- [x] iOS récupère le token QR du backend
- [x] iOS génère l'image QR localement
- [x] QRCodeService compatible avec DataURI
- [x] AuthViewModel intégré au backend
- [x] ChildDetailView affiche token + image
- [x] Aucune erreur de compilation

## 📝 Logs à Vérifier

**Lors de l'accès à ChildDetailView :**
```
🔄 Loading QR token for child: 507f...
✅ QR token loaded: a1b2c3d4e5f6g7h8...
✅ QR image generated successfully
```

**Lors de la création d'un enfant :**
```
✅ Child added successfully
🔄 Generating QR token for child: 507f...
✅ QR token generated: a1b2c3d4e5f6g7h8...
```

## 🔧 Configuration

**Base URL QR Backend :**
```swift
private let baseURL = "http://localhost:3000/qr"
```

**TTL du Token (par défaut) :**
```swift
ttlSeconds: 120  // 2 minutes
```

**Taille de l'Image QR :**
```swift
size: CGSize(width: 300, height: 300)
```

## 📱 Interface Utilisateur

La section "Login QR Code" dans ChildDetailView affiche :

1. **Titre** : "Login QR Code" avec icône 🔐
2. **Image QR** : 250x250 pixels, fond blanc, coins arrondis
3. **Token** : Première partie du token visible (20 caractères)
4. **Message** : "Share this QR code with your child to login"
5. **Spinner** : Pendant le chargement du token

## ✨ Améliorations Futures

- [ ] Ajouter un bouton "Régénérer" pour créer un nouveau token
- [ ] Ajouter un bouton "Copier token"
- [ ] Ajouter un bouton "Télécharger QR"
- [ ] Afficher la date d'expiration du token
- [ ] Afficher la liste des tokens actifs

