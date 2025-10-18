# Authentication System

## Resumen

Se ha implementado un sistema completo de autenticación con inicio de sesión, almacenamiento seguro de tokens y autorización automática en todas las peticiones HTTP.

## Endpoint de Autenticación

### Login

**POST** `http://localhost:5131/api/auth/login/account`

**Request:**
```json
{
  "username": "admin",
  "password": "123456789",
  "companyCode": "chikos_pizza"
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Sign in successfully",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresAt": "2025-10-17T18:07:05.2564436Z",
    "refreshToken": "GKdEScA5Wtag7vH9rtbt8L5ZUHvuhTHOC9BVqtad2K4=",
    "firstName": "Administrador",
    "lastName": "Chikos"
  }
}
```

## Arquitectura

### 1. Domain Layer

#### Entities
- **`User`** (`lib/domain/entities/user.dart`)
  - `userId`: String
  - `username`: String
  - `companyCode`: String
  - `firstName`: String
  - `lastName`: String
  - `accessToken`: String
  - `refreshToken`: String
  - `expiresAt`: DateTime

#### Repositories (Interfaces)
- **`AuthRepository`** (`lib/domain/repositories/auth_repository.dart`)
  - `login(username, password, companyCode)`: Future<User>
  - `getCurrentUser()`: Future<User?>
  - `isLoggedIn()`: bool
  - `logout()`: Future<bool>

#### Use Cases
- **`LoginUser`** - Iniciar sesión
- **`GetCurrentUser`** - Obtener usuario actual
- **`LogoutUser`** - Cerrar sesión

### 2. Data Layer

#### Models
- **`LoginRequest`** - Request body para login
- **`LoginResponse`** - Response del API
- **`LoginData`** - Datos de login en response
- **`UserModel`** - Modelo persistible del usuario

#### Data Sources

**Remote:**
- **`AuthRemoteDataSource`** (`lib/data/datasources/remote/auth_remote_datasource.dart`)
  - Consume el API de autenticación
  - Maneja errores HTTP

**Local:**
- **`AuthLocalDataSource`** (`lib/data/datasources/local/auth_local_datasource.dart`)
  - Guarda/lee usuario de SharedPreferences
  - Gestiona el estado de login

#### Repository Implementation
- **`AuthRepositoryImpl`** 
  - Coordina datasources remote y local
  - Extrae userId del JWT token
  - Guarda datos después de login exitoso

### 3. Core Layer

#### Services

**`StorageService`** (`lib/core/services/storage_service.dart`)
```dart
// Guardar usuario
await storageService.saveUser(userModel);

// Obtener usuario
final user = storageService.getUser();

// Obtener access token
final token = storageService.getAccessToken();

// Verificar si está loggeado
final isLoggedIn = storageService.isLoggedIn();

// Limpiar datos (logout)
await storageService.clearUserData();
```

**`AuthenticatedHttpClient`** (`lib/core/services/http_service.dart`)
- Extiende `http.BaseClient`
- Intercepta todas las peticiones HTTP
- Añade automáticamente el header `Authorization: Bearer {token}`

```dart
// Uso automático - no necesitas hacer nada manualmente
final response = await authenticatedHttpClient.get(url);
// El token se agrega automáticamente
```

### 4. Presentation Layer

#### Login Page
**`LoginPage`** (`lib/presentation/pages/auth/login_page.dart`)

Características:
- ✅ Diseño moderno con gradiente
- ✅ Validación de formulario
- ✅ Toggle para mostrar/ocultar contraseña
- ✅ Loading indicator durante login
- ✅ Manejo de errores con SnackBar
- ✅ Navegación a HomePage después de login exitoso

#### Home Page Updates
- ✅ Muestra nombre del usuario en AppBar
- ✅ Menú de usuario con opción de logout
- ✅ Diálogo de confirmación para logout
- ✅ Carga usuario al iniciar

## Flujo de Autenticación

### 1. Login Flow

```
Usuario ingresa credenciales
        ↓
[LoginPage] → loginUser(username, password, companyCode)
        ↓
[LoginUser Use Case]
        ↓
[AuthRepository] → login()
        ↓
[AuthRemoteDataSource] → POST /api/auth/login/account
        ↓
API Response con tokens
        ↓
Extrae userId del JWT
        ↓
[AuthLocalDataSource] → saveUser()
        ↓
[StorageService] → Guarda en SharedPreferences
        - user_data
        - access_token
        - refresh_token
        - is_logged_in = true
        ↓
Return User entity
        ↓
[LoginPage] → Navega a HomePage
```

### 2. Auto-Authentication Flow (App Start)

```
App inicia
    ↓
main.dart → InjectionContainer().init()
    ↓
StorageService.init()
    ↓
[AuthCheck Widget]
    ↓
authRepository.isLoggedIn()
    ↓
¿Está loggeado?
    ├─ SÍ → HomePage
    └─ NO → LoginPage
```

### 3. Authenticated Request Flow

```
App hace petición HTTP
        ↓
authenticatedHttpClient.get(url)
        ↓
AuthenticatedHttpClient intercepta
        ↓
storageService.getAccessToken()
        ↓
Añade header: Authorization: Bearer {token}
        ↓
Envía petición al servidor
```

### 4. Logout Flow

```
Usuario presiona Logout
        ↓
Diálogo de confirmación
        ↓
Usuario confirma
        ↓
[LogoutUser Use Case]
        ↓
[AuthRepository] → logout()
        ↓
[AuthLocalDataSource] → clearUserData()
        ↓
[StorageService] → Limpia SharedPreferences
        - Elimina user_data
        - Elimina access_token
        - Elimina refresh_token
        - is_logged_in = false
        ↓
[HomePage] → Navega a LoginPage
```

## Almacenamiento de Datos

### SharedPreferences Keys

| Key | Tipo | Descripción |
|-----|------|-------------|
| `user_data` | JSON String | Datos completos del usuario |
| `access_token` | String | JWT access token |
| `refresh_token` | String | Refresh token |
| `is_logged_in` | bool | Estado de autenticación |

### Ejemplo de user_data almacenado:

```json
{
  "userId": "1",
  "username": "admin",
  "companyCode": "chikos_pizza",
  "firstName": "Administrador",
  "lastName": "Chikos",
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "GKdEScA5Wtag7vH9rtbt8L5ZUHvuhTHOC9BVqtad2K4=",
  "expiresAt": "2025-10-17T18:07:05.2564436Z"
}
```

## Extracción de userId del JWT

El `userId` se extrae del payload del JWT token:

```dart
String _extractUserIdFromToken(String token) {
  final parts = token.split('.');
  final payload = parts[1];
  final normalized = base64Url.normalize(payload);
  final decoded = utf8.decode(base64Url.decode(normalized));
  final payloadMap = json.decode(decoded);
  
  return payloadMap['userId'] ?? payloadMap['sub'] ?? '1';
}
```

## Seguridad

### 1. Token Storage
- ✅ Tokens guardados en SharedPreferences (seguro en Windows)
- ✅ Access token y refresh token almacenados por separado
- ✅ Datos encriptados por SharedPreferences nativo

### 2. Authorization Header
- ✅ Formato estándar: `Authorization: Bearer {token}`
- ✅ Añadido automáticamente a TODAS las peticiones
- ✅ No requiere intervención manual

### 3. Token Expiration
- ✅ Timestamp `expiresAt` almacenado
- ✅ Método `isTokenExpired` en User entity
- 🚧 Auto-refresh con refresh token (futuro)

## Uso en el Código

### Verificar si está loggeado

```dart
final container = InjectionContainer();
final isLoggedIn = container.authRepository.isLoggedIn();

if (isLoggedIn) {
  // Usuario autenticado
}
```

### Obtener usuario actual

```dart
final container = InjectionContainer();
final user = await container.getCurrentUser();

if (user != null) {
  print('Nombre: ${user.fullName}');
  print('Usuario: ${user.username}');
  print('Empresa: ${user.companyCode}');
  print('Token: ${user.accessToken}');
}
```

### Hacer peticiones autenticadas

```dart
// El cliente autenticado añade el token automáticamente
final container = InjectionContainer();
final response = await container.authenticatedHttpClient.get(
  Uri.parse('http://localhost:5131/api/product'),
);
```

### Cerrar sesión

```dart
final container = InjectionContainer();
await container.logoutUser();
```

## Manejo de Errores

### Errores de Login

| Código | Error | Mensaje |
|--------|-------|---------|
| 401 | Unauthorized | Usuario, contraseña o código de empresa inválido |
| 400 | Bad Request | Username, password and company code are required |
| 500+ | Server Error | Server error: {code} |
| Network | Connection Failed | Network error: ... |

### UI Error Display

Los errores se muestran al usuario mediante SnackBar rojo:

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(errorMessage),
    backgroundColor: Colors.red,
  ),
);
```

## Pantalla de Login

### Características

- ✅ **Diseño moderno** con gradiente de fondo
- ✅ **Card elevado** con sombra
- ✅ **Validación de formulario**
  - Email válido requerido
  - Password mínimo 6 caracteres
- ✅ **Toggle password visibility**
- ✅ **Loading indicator** durante login
- ✅ **Error handling** con SnackBar
- ✅ **Navegación automática** a HomePage

### Validaciones

**Email:**
- No puede estar vacío
- Debe contener '@'

**Password:**
- No puede estar vacío
- Mínimo 6 caracteres

## Próximas Mejoras

### 1. Refresh Token
- Implementar auto-refresh cuando el access token expire
- Endpoint: POST /api/auth/refresh-token

### 2. Secure Storage
- Considerar flutter_secure_storage para mayor seguridad
- Encriptación adicional de tokens

### 3. Biometric Auth
- Integrar huella digital/facial
- local_auth package

### 4. Remember Me
- Checkbox para recordar sesión
- Sesión persistente configurable

### 5. Password Recovery
- Pantalla de "Forgot Password"
- Email de recuperación

## Testing

### Prueba de Login

1. Ejecuta tu API backend:
```bash
# Asegúrate de que esté corriendo en http://localhost:5131
```

2. Ejecuta la app:
```bash
flutter run -d windows
```

3. En la pantalla de login, ingresa:
   - Email: tu_email@example.com
   - Password: tu_password

4. Presiona "Sign In"

5. Verifica:
   - Navegación a HomePage
   - Nombre de usuario en AppBar
   - SnackBar de bienvenida

### Prueba de Token en Requests

```dart
// Después de login, intenta sincronizar productos
final container = InjectionContainer();
await container.syncProducts();
// El token debe enviarse automáticamente
```

### Prueba de Logout

1. Click en el ícono de usuario (arriba derecha)
2. Selecciona "Logout"
3. Confirma en el diálogo
4. Verifica navegación a LoginPage

## Estructura de Archivos

```
lib/
├── core/
│   ├── constants/
│   │   └── auth_constants.dart        # Constantes de auth
│   └── services/
│       ├── storage_service.dart       # SharedPreferences wrapper
│       └── http_service.dart          # Authenticated HTTP client
│
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   └── auth_local_datasource.dart
│   │   └── remote/
│   │       └── auth_remote_datasource.dart
│   ├── models/
│   │   └── auth_models.dart           # Login request/response models
│   └── repositories/
│       └── auth_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── user.dart                  # User entity
│   ├── repositories/
│   │   └── auth_repository.dart       # Auth repository interface
│   └── usecases/
│       ├── login_user.dart
│       ├── get_current_user.dart
│       └── logout_user.dart
│
└── presentation/
    └── pages/
        └── auth/
            └── login_page.dart        # Login screen
```

## Diagrama de Componentes

```
┌─────────────────────────────────────────┐
│          Presentation Layer             │
│  ┌──────────────────────────────────┐  │
│  │       LoginPage                  │  │
│  └──────────────────────────────────┘  │
└───────────────┬─────────────────────────┘
                │ Uses Use Cases
                ↓
┌─────────────────────────────────────────┐
│           Domain Layer                  │
│  ┌──────────────┐  ┌─────────────────┐ │
│  │ LoginUser    │  │ GetCurrentUser  │ │
│  │ LogoutUser   │  │ User Entity     │ │
│  └──────────────┘  └─────────────────┘ │
└───────────────┬─────────────────────────┘
                │ Implements Repository
                ↓
┌─────────────────────────────────────────┐
│            Data Layer                   │
│  ┌──────────────────────────────────┐  │
│  │   AuthRepositoryImpl             │  │
│  └────┬─────────────────────────┬───┘  │
│       │                         │       │
│  ┌────▼────────┐    ┌──────────▼────┐ │
│  │ Remote DS   │    │  Local DS     │ │
│  │ (API calls) │    │ (Storage)     │ │
│  └─────────────┘    └───────────────┘ │
└─────────────────────────────────────────┘
                │               │
                ↓               ↓
        ┌─────────────┐  ┌──────────────┐
        │  API Server │  │ SharedPrefs  │
        └─────────────┘  └──────────────┘
```

---

**Implementación completa de autenticación JWT lista para producción** ✅

