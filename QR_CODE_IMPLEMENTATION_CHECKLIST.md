# 🎯 Checklist d'Implémentation QR Code Backend + iOS

## ✅ Côté iOS - Modifications Complétées

### 1. **QRCodeService.swift**
- ✅ Méthode `generateQRTokenForChild()` qui appelle `POST /qr/children/{childId}/generate`
- ✅ Récupère le token QR du backend
- ✅ Récupère le qrDataUri (image QR en DataURI)
- ✅ Méthode `uiImageFromDataURI()` pour convertir DataURI en UIImage
- ✅ Génération locale d'image QR comme fallback

### 2. **AuthViewModel.swift**
- ✅ `addChild()` appelle automatiquement `generateQRTokenForChild()` après création
- ✅ `generateQRTokenForChild()` centralise l'appel au backend
- ✅ Gestion complète des erreurs avec logs

### 3. **ChildDetailView.swift**
- ✅ Affichage de la section "Login QR Code"
- ✅ Charge du token QR au démarrage via `onAppear`
- ✅ Génération de l'image QR localement
- ✅ Affichage du token (premiers 20 caractères)
- ✅ Spinner de chargement

## 📋 Backend - Vérification des Endpoints

### ✅ Endpoint Déjà Implémenté: `POST /qr/children/{childId}/generate`
**Fichier:** `qr.controller.ts` (ligne 16-27)

```typescript
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
@Post('children/:childId/generate')
async generate(
  @Request() req: any,
  @Param('childId') childId: string,
  @Body() body: { ttlSeconds?: number; returnQrImage?: boolean },
)
```

**Retourne:**
- `token`: string (hex)
- `expiresAt`: Date
- `qrDataUri`: string (data:image/png;base64,...)

✅ **Status:** IMPLÉMENTÉ - Compatible avec iOS

### ✅ Endpoint Déjà Implémenté: `POST /qr/exchange`
**Fichier:** `qr.controller.ts` (ligne 29-36)

```typescript
@Post('exchange')
async exchange(@Body() body: ExchangeTokenDto)
```

**Retourne:**
- `access_token`: string (JWT)
- `childId`: string

✅ **Status:** IMPLÉMENTÉ - Prêt pour iOS

## 🔍 Vérifications Supplémentaires Recommandées

### 1. **DTO pour Exchange Token**
```typescript
// À vérifier dans: src/qr/dto/exchange-token.dto.ts
export class ExchangeTokenDto {
  @IsString()
  @IsNotEmpty()
  token: string;
}
```

### 2. **Configuration du BaseURL iOS**
Vérifier que le baseURL dans QRCodeService correspond à votre backend :
```swift
private let baseURL = "http://localhost:3000/qr"
```

### 3. **CORS Backend**
S'assurer que CORS est configuré pour accepter les requêtes d'iOS

## 🚀 Test d'Intégration

### Scénario 1: Créer un enfant et afficher le QR code
```
1. Parent crée un child dans AddChildView
2. Redirection vers ParentDashboardView ou ChildrenProgressView
3. Parent accède à ChildDetailView
4. Section "Login QR Code" doit afficher :
   ✅ Token QR (exemple: "a1b2c3d4e5...")
   ✅ Image QR (250x250px)
   ✅ Message "Share this QR code with your child to login"
```

### Scénario 2: Enfant scanne et se connecte
```
1. Enfant ouvre l'app → écran de connexion
2. Scanne le QR code → extrait le token
3. Envoie POST /qr/exchange avec le token
4. Reçoit JWT access_token
5. Se connecte en tant qu'enfant
```

## 📝 Commandes de Test

### Tester la génération de QR code
```bash
# D'abord, créer un parent et récupérer son token
# Puis créer un child
# Puis générer le token QR

curl -X POST http://localhost:3000/qr/children/CHILD_ID/generate \
  -H "Authorization: Bearer PARENT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "ttlSeconds": 120,
    "returnQrImage": true
  }'
```

### Tester l'échange de token
```bash
curl -X POST http://localhost:3000/qr/exchange \
  -H "Content-Type: application/json" \
  -d '{
    "token": "TOKEN_FROM_QR"
  }'
```

## 🔐 Sécurité Vérifiée

- ✅ Endpoint `/qr/children/{childId}/generate` protégé par `JwtAuthGuard`
- ✅ Vérification que l'enfant appartient au parent
- ✅ TTL Index sur MongoDB pour expiration automatique
- ✅ Token marqué comme `used: true` après échange (one-time use)
- ✅ Validation du token lors de l'exchange

## 🎯 Résultat Final

### iOS
- ✅ Récupère le token QR du backend
- ✅ Génère l'image QR localement
- ✅ Affiche le token + image dans ChildDetailView
- ✅ Pas de stockage permanent (temporaire par défaut 2 min)
- ✅ Prêt à être utilisé par l'enfant pour se connecter

### Backend
- ✅ Génère les tokens QR avec expiration
- ✅ Gère l'échange de token contre JWT
- ✅ Marque les tokens comme utilisés (sécurité)
- ✅ Nettoie automatiquement les tokens expirés

## ⚠️ Points à Vérifier

1. **Base URL correcte** : Assurer que `http://localhost:3000/qr` correspond à votre backend
2. **JWT Token valide** : S'assurer que le token du parent est valide quand on accède à ChildDetailView
3. **CORS** : Vérifier que votre backend accepte les requêtes CORS d'iOS
4. **Permissions** : Vérifier que le parent peut générer des QR codes pour ses enfants

## 📱 Interface Utilisaire Résultante

```
┌─────────────────────────────────┐
│        Login QR Code            │
│ ⏳ (spinner pendant chargement)  │
├─────────────────────────────────┤
│                                 │
│     ╔═══════════════════╗       │
│     ║                 ║       │
│     ║   IMAGE QR CODE ║       │
│     ║   (250x250px)   ║       │
│     ║                 ║       │
│     ╚═══════════════════╝       │
│                                 │
│  Token: a1b2c3d4e5f6g7h8...    │
│                                 │
│  Share this QR code with your  │
│  child to login                │
└─────────────────────────────────┘
```

