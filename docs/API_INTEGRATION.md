# API Integration - Product Synchronization

## Resumen de Cambios

Se ha implementado la funcionalidad completa para sincronizar productos desde la API remota y guardarlos en la base de datos local SQLite.

## Arquitectura de IDs

### ID Local vs ID Remoto

La aplicación ahora maneja dos tipos de IDs:

1. **`id`** (Local ID)
   - Autoincremental generado por SQLite
   - Único en la base de datos local
   - Se genera automáticamente al insertar
   - Tipo: `int?` (nullable)

2. **`remoteId`** (Remote/API ID)
   - ID del producto en el servidor API
   - Se obtiene del campo `id` de la respuesta del API
   - UNIQUE constraint en la base de datos
   - Tipo: `int` (required)

### Timestamps Locales

Los timestamps son generados por la aplicación local:

- **`createdAt`**: Se genera con `DateTime.now()` al momento de sincronizar desde el API
- **`updatedAt`**: Se actualiza con `DateTime.now()` cada vez que se modifica el producto localmente

## Endpoint de la API

```
GET http://localhost:5131/api/product
```

### Respuesta Esperada

```json
{
  "success": true,
  "message": "Productos recuperados exitosamente",
  "data": [
    {
      "id": 5,
      "name": "Pizza Margarita",
      "description": null,
      "salePrice": 50.00,
      "isActive": true,
      "productCategoryId": null,
      "productCategory": null,
      "taxRateId": null,
      "taxRate": null,
      "formulaId": 1,
      "formula": {
        "id": 1,
        "code": "PMA001",
        "name": "Pizza Margherita"
      },
      "createdAt": "2025-10-16T16:45:26.735826Z",
      "updatedAt": null
    }
  ]
}
```

## Estructura de la Base de Datos

### Tabla `products`

```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID local
  remote_id INTEGER NOT NULL UNIQUE,     -- ID del API
  name TEXT NOT NULL,
  description TEXT,
  sale_price REAL NOT NULL,
  is_active INTEGER DEFAULT 1,
  product_category_id INTEGER,
  tax_rate_id INTEGER,
  formula_id INTEGER,
  formula_code TEXT,
  formula_name TEXT,
  created_at TEXT NOT NULL,              -- Timestamp local de creación
  updated_at TEXT                        -- Timestamp local de actualización
);

-- Índices para mejor rendimiento
CREATE INDEX idx_product_name ON products(name);
CREATE INDEX idx_product_is_active ON products(is_active);
CREATE INDEX idx_product_remote_id ON products(remote_id);
```

## Mapeo de Campos

| API Response | Local Database | Notas |
|--------------|---------------|-------|
| `id` | `remote_id` | ID del servidor |
| - | `id` | Autoincremental local |
| `name` | `name` | Nombre del producto |
| `description` | `description` | Descripción |
| `salePrice` | `sale_price` | Precio de venta |
| `isActive` | `is_active` | Estado activo/inactivo |
| `productCategoryId` | `product_category_id` | ID de categoría |
| `taxRateId` | `tax_rate_id` | ID de tasa de impuesto |
| `formulaId` | `formula_id` | ID de fórmula |
| `formula.code` | `formula_code` | Código de fórmula |
| `formula.name` | `formula_name` | Nombre de fórmula |
| - | `created_at` | `DateTime.now()` |
| - | `updated_at` | `DateTime.now()` en updates |

## Flujo de Sincronización

### 1. Usuario presiona "Sync Products"

```
[HomePage] → _syncProductsFromApi()
    ↓
[Use Case] SyncProducts
    ↓
[Repository] syncProducts()
    ↓
[Remote Data Source] getProductsFromApi()
    ↓
HTTP GET → http://localhost:5131/api/product
    ↓
[API Response] ProductsApiResponse.fromJson()
    ↓
[Product Model] ProductModel.fromJson() para cada producto
    - remoteId = json['id']
    - createdAt = DateTime.now()
    - updatedAt = null
    ↓
[Local Data Source] insertProducts(List<ProductModel>)
    ↓
SQL: INSERT ... ON CONFLICT(remote_id) DO UPDATE ...
    ↓
[Base de Datos Local] SQLite
    ↓
Retorna List<Product> → HomePage
```

### 2. Estrategia UPSERT

La sincronización usa una estrategia de **UPSERT** (INSERT or UPDATE):

```sql
INSERT INTO products (...) VALUES (...)
ON CONFLICT(remote_id) DO UPDATE SET
  name = excluded.name,
  description = excluded.description,
  -- ... otros campos ...
  updated_at = CURRENT_TIMESTAMP
```

**Ventajas:**
- ✅ No se pierden datos locales (no se elimina toda la tabla)
- ✅ Productos nuevos se insertan automáticamente
- ✅ Productos existentes se actualizan
- ✅ El `id` local se mantiene estable

## Nuevos Archivos Creados

### 1. Core - Constantes

**`lib/core/constants/api_constants.dart`**
- URLs y endpoints de la API
- Configuración de timeouts
- Headers HTTP

### 2. Data - Modelos

**`lib/data/models/api_response_model.dart`**
- Modelo genérico de respuesta API
- `ProductsApiResponse` para lista de productos

### 3. Data - Remote Data Source

**`lib/data/datasources/remote/product_remote_datasource.dart`**
- Interface `ProductRemoteDataSource`
- Implementación `ProductRemoteDataSourceImpl`
- Manejo de errores HTTP

### 4. Domain - Use Cases

**`lib/domain/usecases/sync_products.dart`**
- Caso de uso para sincronización de productos

## Archivos Modificados

### 1. Entidad Product
- Agregado campo `remoteId`
- `id` ahora es nullable (autoincremental)
- `createdAt` y `updatedAt` son timestamps locales

### 2. Product Model
- `fromJson()`: Convierte API response a modelo
  - `remoteId` toma el valor de `json['id']`
  - `createdAt` se genera con `DateTime.now()`
- `fromMap()`: Lee de base de datos local
- `toMap()`: Guarda en base de datos local

### 3. Product Repository
- Agregado `fetchProductsFromApi()`
- Agregado `syncProducts()`
- Modificado para usar remote y local datasources

### 4. Local Data Source
- `insertProducts()` usa estrategia UPSERT
- `insertProduct()` verifica `remote_id` existente
- Timestamps de update se generan automáticamente

### 5. Injection Container
- Agregado `httpClient` (http.Client)
- Agregado `productRemoteDataSource`
- Agregado `syncProducts` use case

### 6. Home Page (UI)
- Botón de sincronización en AppBar
- Indicador de progreso durante sincronización
- FloatingActionButton para sincronización rápida
- Pantalla vacía con botón de sincronización
- Visualización de `remoteId` y estado activo

## Cómo Usar

### 1. Sincronizar Productos desde la API

```dart
// En cualquier parte de tu código
final container = InjectionContainer();
final products = await container.syncProducts();

print('${products.length} productos sincronizados');
```

### 2. Obtener Productos Locales

```dart
final container = InjectionContainer();
final products = await container.getAllProducts();

for (var product in products) {
  print('Local ID: ${product.id}');
  print('Remote ID: ${product.remoteId}');
  print('Name: ${product.name}');
  print('Price: \$${product.salePrice}');
  print('Created At: ${product.createdAt}');
}
```

### 3. Buscar Productos

```dart
final container = InjectionContainer();
final results = await container.searchProducts('Pizza');
```

## Manejo de Errores

La aplicación maneja los siguientes escenarios:

### Errores de Red
```dart
try {
  await syncProducts();
} catch (e) {
  // Muestra SnackBar con error
  // Usuario puede intentar nuevamente
}
```

### Errores HTTP
- **404**: Endpoint no encontrado
- **500+**: Error del servidor
- **Timeout**: Conexión timeout (30 segundos)

### Sin Conexión
```dart
Exception('Network error: SocketException...')
```

## Configuración

### Cambiar URL del API

Edita `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'http://tu-servidor.com:puerto';
  static const String productsEndpoint = '/api/product';
}
```

### Cambiar Timeout

```dart
class ApiConstants {
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
```

## Pruebas

### Probar Sincronización

1. Ejecuta tu API backend:
```bash
# Asegúrate de que tu API esté corriendo en
# http://localhost:5131
```

2. Ejecuta la app Flutter:
```bash
flutter run -d windows
```

3. Presiona el botón de sincronización (ícono de nube)

4. Verifica que los productos se muestren

### Verificar Base de Datos

Puedes verificar la base de datos directamente:

```dart
final db = await DatabaseService().database;
final products = await db.query('products');
print(products);
```

La base de datos se encuentra en:
```
C:\Users\[usuario]\Documents\restobar_pos.db
```

## Próximos Pasos

1. **Sincronización Automática**
   - Agregar sincronización periódica (cada X minutos)
   - Sincronización al iniciar la app

2. **Sincronización Bidireccional**
   - Enviar cambios locales al servidor
   - Resolver conflictos

3. **Manejo Offline**
   - Cola de cambios pendientes
   - Sincronización cuando vuelva la conexión

4. **Optimizaciones**
   - Sincronización incremental (solo cambios)
   - Compresión de datos
   - Caché de imágenes

## Diagrama de Flujo

```
┌─────────────────┐
│   API Server    │
│  localhost:5131 │
└────────┬────────┘
         │ HTTP GET
         │ /api/product
         ↓
┌─────────────────────────┐
│  Remote Data Source     │
│  getProductsFromApi()   │
└────────┬────────────────┘
         │ List<ProductModel>
         ↓
┌─────────────────────────┐
│   Repository            │
│   syncProducts()        │
└────────┬────────────────┘
         │ insertProducts()
         ↓
┌─────────────────────────┐
│  Local Data Source      │
│  UPSERT by remote_id    │
└────────┬────────────────┘
         │ SQL
         ↓
┌─────────────────────────┐
│   SQLite Database       │
│   restobar_pos.db       │
│   - id (autoincrement)  │
│   - remote_id (unique)  │
│   - created_at (local)  │
└─────────────────────────┘
```

## Notas Importantes

⚠️ **ID Local es Autoincremental**
- No uses el ID local para comunicarte con el API
- Usa siempre `remoteId` para operaciones con el servidor

⚠️ **Timestamps son Locales**
- `createdAt` y `updatedAt` son timestamps de la app local
- No confundir con los timestamps del servidor API

⚠️ **UPSERT Preserva Datos**
- La sincronización NO elimina productos existentes
- Solo inserta nuevos o actualiza existentes
- El ID local permanece estable

✅ **Listo para Producción**
- Manejo completo de errores
- Transacciones por lotes (batch)
- Índices para rendimiento
- Clean Architecture compliant

