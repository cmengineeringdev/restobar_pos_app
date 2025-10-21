# Implementación de Riverpod - Gestor de Estado

## 📋 Resumen

Se ha implementado **Riverpod** como gestor de estado para el proyecto Restobar POS, integrándose perfectamente con la arquitectura Clean Architecture existente.

## 🎯 ¿Por qué Riverpod?

Riverpod fue elegido por las siguientes razones:

1. **Perfecto para Clean Architecture** - Se integra naturalmente con casos de uso y repositorios
2. **Type-safe** - Detección de errores en tiempo de compilación
3. **AsyncValue** - Gestión elegante de estados de carga/error/datos
4. **No requiere BuildContext** - Código más limpio y testeable
5. **Escalable** - Ideal para proyectos que crecerán en complejidad
6. **Inmutable** - Menos bugs, más predecible
7. **Testing friendly** - Fácil de testear con provider overrides

## 📦 Dependencias Agregadas

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.9
```

## 🏗️ Estructura de Providers

### 1. Providers Base (`lib/core/providers/providers.dart`)

Este archivo contiene todos los providers básicos:

#### Repositorios
```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {...});
final productRepositoryProvider = Provider<ProductRepository>((ref) {...});
final pointOfSaleRepositoryProvider = Provider<PointOfSaleRepository>((ref) {...});
```

#### Casos de Uso
- **Auth**: `loginUserProvider`, `getCurrentUserProvider`, `logoutUserProvider`
- **Products**: `getAllProductsProvider`, `searchProductsProvider`, `syncProductsProvider`
- **Point of Sale**: `getPointsOfSaleProvider`, `selectPointOfSaleProvider`, etc.

#### Providers de Datos
```dart
final currentUserProvider = FutureProvider<User?>((ref) async {...});
final selectedPointOfSaleProvider = FutureProvider<PointOfSale?>((ref) async {...});
final pointsOfSaleProvider = FutureProvider<List<PointOfSale>>((ref) async {...});
final productsProvider = FutureProvider<List<Product>>((ref) async {...});
```

### 2. StateNotifiers

#### AuthStateNotifier (`auth_state_notifier.dart`)
Gestiona el estado de autenticación:

```dart
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
}
```

**Métodos:**
- `login(username, password, companyCode)` - Inicia sesión
- `logout()` - Cierra sesión
- `setUser(user)` - Establece el usuario actual
- `clearError()` - Limpia errores

**Provider:**
```dart
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {...});
```

#### ProductStateNotifier (`product_state_notifier.dart`)
Gestiona el estado de productos:

```dart
class ProductState {
  final List<Product> products;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final String? successMessage;
}
```

**Métodos:**
- `loadProducts()` - Carga todos los productos
- `searchProducts(query)` - Busca productos
- `syncProducts()` - Sincroniza desde API
- `clearMessages()` - Limpia mensajes

**Provider:**
```dart
final productStateProvider = StateNotifierProvider<ProductStateNotifier, ProductState>((ref) {...});
```

#### PointOfSaleStateNotifier (`point_of_sale_state_notifier.dart`)
Gestiona el estado del punto de venta:

```dart
class PointOfSaleState {
  final List<PointOfSale> availablePointsOfSale;
  final PointOfSale? selectedPointOfSale;
  final bool isLoading;
  final String? error;
  final String? successMessage;
}
```

**Métodos:**
- `loadPointsOfSale()` - Carga puntos de venta disponibles
- `selectPointOfSale(pos)` - Selecciona un punto de venta
- `loadSelectedPointOfSale()` - Carga el punto de venta actual
- `clearSelectedPointOfSale()` - Limpia la selección
- `clearMessages()` - Limpia mensajes

**Provider:**
```dart
final pointOfSaleStateProvider = StateNotifierProvider<PointOfSaleStateNotifier, PointOfSaleState>((ref) {...});
```

## 🔄 Páginas Refactorizadas

### 1. LoginPage

**Antes (StatefulWidget con setState):**
```dart
class LoginPage extends StatefulWidget {...}
class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  
  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    // ...
  }
}
```

**Después (ConsumerStatefulWidget con Riverpod):**
```dart
class LoginPage extends ConsumerStatefulWidget {...}
class _LoginPageState extends ConsumerState<LoginPage> {
  Future<void> _handleLogin() async {
    await ref.read(authStateProvider.notifier).login(...);
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    // Usa authState.isLoading, authState.error, etc.
  }
}
```

### 2. SelectPointOfSalePage

**Cambios principales:**
- Usa `pointOfSaleStateProvider` para gestionar el estado
- `loadPointsOfSale()` se llama desde el notifier
- Estado de carga y errores gestionados automáticamente

```dart
class SelectPointOfSalePage extends ConsumerStatefulWidget {...}
class _SelectPointOfSalePageState extends ConsumerState<SelectPointOfSalePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pointOfSaleStateProvider.notifier).loadPointsOfSale();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(pointOfSaleStateProvider);
    // Usa posState.isLoading, posState.availablePointsOfSale, etc.
  }
}
```

### 3. HomePage

**Cambios principales:**
- Usa `authStateProvider` para el usuario actual
- Usa `productStateProvider` para sincronización de productos
- Estados de carga gestionados automáticamente

```dart
class HomePage extends ConsumerStatefulWidget {...}
class _HomePageState extends ConsumerState<HomePage> {
  Future<void> _syncProductsFromApi() async {
    await ref.read(productStateProvider.notifier).syncProducts();
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final productState = ref.watch(productStateProvider);
    // Usa authState.user, productState.isSyncing, etc.
  }
}
```

## 📚 Cómo Usar Riverpod en el Proyecto

### 1. Crear un Widget con Estado

Para widgets que necesitan leer estado:

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return Text('Usuario: ${authState.user?.fullName ?? "Invitado"}');
  }
}
```

Para widgets con estado local:

```dart
class MyWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productStateProvider);
    
    return ListView.builder(
      itemCount: productState.products.length,
      itemBuilder: (context, index) {
        return Text(productState.products[index].name);
      },
    );
  }
}
```

### 2. Leer Estado

**`ref.watch`** - Escucha cambios y reconstruye el widget:
```dart
final authState = ref.watch(authStateProvider);
```

**`ref.read`** - Lee una vez sin escuchar cambios:
```dart
final user = ref.read(authStateProvider).user;
```

**`ref.listen`** - Escucha cambios sin reconstruir (útil para side effects):
```dart
ref.listen(authStateProvider, (previous, next) {
  if (next.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(next.error!)),
    );
  }
});
```

### 3. Modificar Estado

Siempre usar `.notifier` para modificar:

```dart
// Login
await ref.read(authStateProvider.notifier).login(username, password, companyCode);

// Sincronizar productos
await ref.read(productStateProvider.notifier).syncProducts();

// Seleccionar punto de venta
await ref.read(pointOfSaleStateProvider.notifier).selectPointOfSale(pos);
```

### 4. FutureProvider - Para Datos Asíncronos

```dart
// En el provider
final currentUserProvider = FutureProvider<User?>((ref) async {
  final getCurrentUser = ref.watch(getCurrentUserProvider);
  return await getCurrentUser();
});

// En el widget
final userAsync = ref.watch(currentUserProvider);

userAsync.when(
  data: (user) => Text('Hola ${user?.fullName}'),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

## 🧪 Testing con Riverpod

Riverpod facilita el testing con `ProviderContainer` y overrides:

```dart
test('login success', () async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(MockAuthRepository()),
    ],
  );
  
  final notifier = container.read(authStateProvider.notifier);
  await notifier.login('test', 'password', 'company');
  
  expect(container.read(authStateProvider).isAuthenticated, true);
});
```

## 🚀 Próximos Pasos

Para agregar nuevas funcionalidades:

1. **Crear casos de uso** en `lib/domain/usecases/`
2. **Crear providers** en `lib/core/providers/providers.dart`
3. **Crear StateNotifier** si necesitas estado complejo
4. **Usar en widgets** con `ConsumerWidget` o `ConsumerStatefulWidget`

## 📖 Recursos

- [Documentación oficial de Riverpod](https://riverpod.dev)
- [Riverpod Code Generation](https://riverpod.dev/docs/concepts/about_code_generation)
- [Testing con Riverpod](https://riverpod.dev/docs/cookbooks/testing)

## ✅ Ventajas de la Implementación

1. **Separación de responsabilidades** - UI y lógica de negocio separadas
2. **Estado inmutable** - Menos bugs y más predecible
3. **Gestión automática de loading/error** - Menos código boilerplate
4. **Fácil de testear** - Provider overrides simplifica testing
5. **Type-safe** - Errores detectados en compilación
6. **Escalable** - Fácil agregar nuevos módulos
7. **Integración con Clean Architecture** - Mantiene la arquitectura limpia

## 🎓 Conceptos Clave

- **Provider**: Provee un valor (repositorio, caso de uso, etc.)
- **StateNotifier**: Gestiona estado mutable de forma inmutable
- **FutureProvider**: Para operaciones asíncronas
- **ConsumerWidget**: Widget que puede leer providers
- **ref.watch**: Escucha cambios y reconstruye
- **ref.read**: Lee valor sin escuchar
- **ref.listen**: Escucha para side effects

---

**Nota**: Este documento debe actualizarse cuando se agreguen nuevos providers o StateNotifiers al proyecto.

