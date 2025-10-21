# Implementación de Validación de Token y Manejo de Sesión

## Resumen

Se ha implementado un sistema completo de validación de token y manejo automático de sesión expirada que:

1. **Valida el token antes de cada petición HTTP**
2. **Detecta respuestas 401 (No autorizado)** de la API
3. **Cierra la sesión automáticamente** cuando el token expira o se recibe un 401
4. **Redirige al usuario a la pantalla de login** con un mensaje informativo

## Archivos Creados

### 1. `/lib/core/exceptions/auth_exceptions.dart`
Excepciones personalizadas para manejo de autenticación:
- `TokenExpiredException`: Cuando el token ha expirado localmente
- `UnauthorizedException`: Cuando la API responde con 401

### 2. `/lib/core/services/session_manager.dart`
Gestor centralizado de sesión que:
- Valida si el token ha expirado
- Maneja el cierre automático de sesión
- Muestra mensajes al usuario
- Coordina la navegación al login

## Archivos Modificados

### 1. `/lib/core/services/http_service.dart`
**Cambios:**
- Agrega validación de token ANTES de cada petición HTTP
- Intercepta respuestas 401 de la API
- Maneja excepciones de token expirado
- Llama al SessionManager para cerrar sesión automáticamente

**Flujo:**
```
Request → Validar token local → Enviar petición → Verificar 401 → Manejar sesión expirada
```

### 2. `/lib/core/injection/injection_container.dart`
**Cambios:**
- Agrega `SessionManager` como dependencia
- Inyecta `SessionManager` en `AuthenticatedHttpClient`

### 3. `/lib/main.dart`
**Cambios:**
- Agrega `GlobalKey` para navegación desde cualquier lugar
- Agrega `GlobalKey` para mostrar mensajes desde cualquier lugar
- Convierte `MyApp` a `ConsumerWidget` para acceso a Riverpod
- Registra callbacks del `SessionManager` para navegación y mensajes
- Valida token expirado en `AuthCheck` al iniciar la app
- Maneja sesión expirada con mensaje y redirección automática

### 4. `/lib/core/providers/auth_state_notifier.dart`
**Cambios:**
- Agrega método `forceLogout()` para logout sin estado de carga
- Útil cuando se cierra sesión automáticamente por token expirado

## Flujos Implementados

### Flujo 1: Token Expirado Localmente
```
Usuario hace petición HTTP
    ↓
AuthenticatedHttpClient verifica token local
    ↓
Token expirado detectado
    ↓
SessionManager.handleSessionExpired()
    ↓
- Limpia datos locales
- Muestra mensaje "Tu sesión ha expirado..."
- Navega a LoginPage
```

### Flujo 2: Respuesta 401 de la API
```
Usuario hace petición HTTP
    ↓
Token pasa validación local
    ↓
API responde 401 No Autorizado
    ↓
AuthenticatedHttpClient intercepta 401
    ↓
SessionManager.handle401Response()
    ↓
- Limpia datos locales
- Muestra mensaje "Tu sesión ha expirado..."
- Navega a LoginPage
```

### Flujo 3: Validación al Iniciar App
```
App inicia
    ↓
AuthCheck se ejecuta
    ↓
Verifica usuario logueado
    ↓
Verifica token no expirado
    ↓
Si token expirado:
    - Cierra sesión
    - Muestra mensaje
    - Navega a LoginPage
```

## Características Implementadas

### ✅ Validación Proactiva
- El token se valida ANTES de cada petición HTTP
- Evita peticiones innecesarias con tokens expirados

### ✅ Manejo de Respuestas 401
- Intercepta todas las respuestas 401 de la API
- Cierra sesión automáticamente sin intervención del usuario

### ✅ Navegación Global
- Usa `GlobalKey<NavigatorState>` para navegar desde cualquier lugar
- Elimina el stack de navegación al ir al login

### ✅ Mensajes Informativos
- Muestra SnackBar rojo con mensaje claro
- Usa `GlobalKey<ScaffoldMessengerState>` para mensajes globales

### ✅ Validación al Inicio
- Verifica token expirado cuando la app inicia
- Evita que usuarios entren con tokens expirados

### ✅ Limpieza Completa
- Elimina todos los datos de sesión del almacenamiento local
- Resetea el estado de autenticación en Riverpod

## Seguridad

### Capas de Validación
1. **Validación Local**: Verifica `expiresAt` en el User entity
2. **Validación de API**: Respeta respuestas 401 del servidor
3. **Validación de Inicio**: Verifica token al abrir la app

### Datos Protegidos
- Access Token eliminado
- Refresh Token eliminado
- Datos de usuario eliminados
- Estado de autenticación reseteado

## Experiencia de Usuario

### Mensajes Claros
- "Tu sesión ha expirado. Por favor inicia sesión nuevamente."
- Duración de 4 segundos
- Color rojo para indicar acción requerida

### Navegación Fluida
- Redirección automática sin pantallas intermedias
- Limpia todo el stack de navegación
- Usuario va directamente al login

### Sin Intervención Manual
- No requiere que el usuario cierre sesión manualmente
- El sistema detecta y maneja automáticamente

## Compatibilidad

### Respuestas HTTP Manejadas
- ✅ 401 Unauthorized
- ✅ Token expirado localmente
- ✅ Usuario sin token

### Plataformas
- ✅ iOS
- ✅ Android
- ✅ macOS
- ✅ Windows
- ✅ Linux
- ✅ Web

## Pruebas Recomendadas

### Escenario 1: Token Expirado Natural
1. Iniciar sesión
2. Esperar a que el token expire (según `expiresAt`)
3. Intentar hacer cualquier acción que requiera API
4. Verificar redirección automática al login

### Escenario 2: API Responde 401
1. Iniciar sesión
2. Invalidar token en el servidor (opcional)
3. Hacer petición a la API
4. Verificar que la app detecta 401 y cierra sesión

### Escenario 3: App Inicia con Token Expirado
1. Iniciar sesión
2. Modificar `expiresAt` a fecha pasada (para pruebas)
3. Cerrar y abrir la app
4. Verificar que se detecta token expirado y va al login

### Escenario 4: Usuario sin Token
1. Desinstalar y reinstalar la app
2. Abrir la app
3. Verificar que va directamente al login

## Mantenimiento

### Logging (Recomendado)
Para producción, considera agregar logging en:
- `SessionManager.handleSessionExpired()` → Log de sesión expirada
- `AuthenticatedHttpClient.send()` → Log de interceptación 401
- `AuthCheck._checkAndNavigate()` → Log de validación de inicio

### Monitoreo (Recomendado)
Monitorear métricas de:
- Frecuencia de tokens expirados
- Frecuencia de respuestas 401
- Tiempo entre login y expiración

## Notas Técnicas

### Singleton Pattern
- `SessionManager` usa patrón singleton
- Garantiza una única instancia en toda la app

### Injection Container
- Todas las dependencias centralizadas
- Fácil de testear y mantener

### Riverpod Integration
- Compatible con el estado global de Riverpod
- No interfiere con providers existentes

### Thread Safety
- Todas las operaciones asíncronas manejadas correctamente
- Usa `mounted` para verificar widgets antes de navegar

## Conclusión

El sistema implementado proporciona una capa robusta de seguridad y validación de sesión que:
- ✅ Mejora la experiencia de usuario
- ✅ Previene accesos no autorizados
- ✅ Maneja automáticamente tokens expirados
- ✅ Respeta las respuestas del servidor
- ✅ Es escalable y mantenible

La implementación sigue las mejores prácticas de Flutter y Dart, con código limpio, bien documentado y fácil de extender.

