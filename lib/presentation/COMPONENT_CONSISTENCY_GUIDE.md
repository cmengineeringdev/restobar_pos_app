# Guía de Consistencia de Componentes - Restobar POS

## 📋 Resumen

Esta guía documenta todas las correcciones aplicadas para garantizar que **todos los componentes** de la aplicación usen exclusivamente los colores del tema profesional.

## 🎨 Paleta de Colores Única

**IMPORTANTE:** Solo usa estos colores de `AppTheme`:

```dart
// Colores principales
AppTheme.primaryColor       // #1E3A5F - Azul oscuro profesional
AppTheme.secondaryColor     // #2C5282 - Azul medio
AppTheme.successColor       // #38A169 - Verde oscuro
AppTheme.errorColor         // #E53E3E - Rojo oscuro
AppTheme.warningColor       // #D69E2E - Amarillo oscuro
AppTheme.infoColor          // #3182CE - Azul información

// Colores de texto
AppTheme.textPrimary        // #1A202C - Negro azulado
AppTheme.textSecondary      // #4A5568 - Gris medio
AppTheme.textDisabled       // #A0AEC0 - Gris claro

// Colores de superficie
AppTheme.surfaceColor       // #FFFFFF - Blanco
AppTheme.backgroundColor    // #F7FAFC - Gris azul muy claro
AppTheme.borderColor        // #E2E8F0 - Gris azul claro
AppTheme.borderColorDark    // #CBD5E0 - Gris azul medio
```

## ❌ Colores PROHIBIDOS

**NUNCA uses:**
- `Colors.red`, `Colors.green`, `Colors.blue`, etc. directamente
- `Colors.grey`, `Colors.grey[600]`, etc.
- `Theme.of(context).colorScheme.primary` (usa `AppTheme.primaryColor`)
- `Theme.of(context).colorScheme.inversePrimary`
- Cualquier color que no esté en `AppTheme`

## ✅ Componentes Corregidos

### 1. **Card**

```dart
// ✅ CORRECTO
Card(
  elevation: 0,
  color: AppTheme.surfaceColor,
  surfaceTintColor: Colors.transparent,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
    side: const BorderSide(color: AppTheme.borderColor, width: 1),
  ),
  child: ...
)

// ❌ INCORRECTO
Card(
  elevation: 2,  // Evitar sombras
  // Sin surfaceTintColor -> tinte rosado
  child: ...
)
```

### 2. **AlertDialog**

```dart
// ✅ CORRECTO
AlertDialog(
  backgroundColor: AppTheme.surfaceColor,
  surfaceTintColor: Colors.transparent,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
  ),
  title: const Text(
    'Título',
    style: TextStyle(color: AppTheme.textPrimary),
  ),
  content: const Text(
    'Contenido',
    style: TextStyle(color: AppTheme.textSecondary),
  ),
  actions: [...]
)
```

### 3. **SnackBar**

```dart
// ✅ CORRECTO - Éxito
SnackBar(
  content: Text('Mensaje'),
  backgroundColor: AppTheme.successColor,
  behavior: SnackBarBehavior.floating,
)

// ✅ CORRECTO - Error
SnackBar(
  content: Text('Error'),
  backgroundColor: AppTheme.errorColor,
  behavior: SnackBarBehavior.floating,
)

// ✅ CORRECTO - Info
SnackBar(
  content: Text('Info'),
  backgroundColor: AppTheme.primaryColor,
  behavior: SnackBarBehavior.floating,
)

// ❌ INCORRECTO
SnackBar(
  backgroundColor: Colors.red,  // ❌ NO
  backgroundColor: Colors.green, // ❌ NO
)
```

### 4. **TextField / TextFormField**

```dart
// ✅ CORRECTO
TextField(
  style: const TextStyle(
    fontSize: 15,
    color: AppTheme.textPrimary,
  ),
  cursorColor: AppTheme.primaryColor,
  decoration: InputDecoration(
    hintText: 'Placeholder',
    hintStyle: const TextStyle(color: AppTheme.textDisabled),
    filled: true,
    fillColor: AppTheme.surfaceColor,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppTheme.borderColor, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
    ),
  ),
)
```

### 5. **ElevatedButton**

```dart
// ✅ CORRECTO
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,  // Sin sombra
  ),
  child: Text('Botón'),
)

// ✅ CORRECTO - Botón de error/destructivo
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.errorColor,
    foregroundColor: Colors.white,
  ),
  child: Text('Eliminar'),
)
```

### 6. **TextButton**

```dart
// ✅ CORRECTO
TextButton(
  onPressed: () {},
  style: TextButton.styleFrom(
    foregroundColor: AppTheme.primaryColor,
  ),
  child: Text('Botón de texto'),
)

// ✅ CORRECTO - Acción secundaria
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: AppTheme.textSecondary,
  ),
  child: Text('Cancelar'),
)
```

### 7. **FloatingActionButton**

```dart
// ✅ CORRECTO
FloatingActionButton.extended(
  onPressed: () {},
  backgroundColor: AppTheme.primaryColor,
  foregroundColor: Colors.white,
  elevation: 2,  // Mínima elevación
  icon: Icon(Icons.add),
  label: Text('Agregar'),
)
```

### 8. **PopupMenuButton**

```dart
// ✅ CORRECTO
PopupMenuButton<String>(
  color: AppTheme.surfaceColor,
  surfaceTintColor: Colors.transparent,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
  ),
  itemBuilder: (context) => [
    PopupMenuItem(
      child: Text(
        'Opción',
        style: TextStyle(color: AppTheme.textPrimary),
      ),
    ),
  ],
)
```

### 9. **AppBar**

```dart
// ✅ CORRECTO
AppBar(
  backgroundColor: AppTheme.surfaceColor,
  elevation: 0,
  title: const Text(
    'Título',
    style: TextStyle(color: AppTheme.textPrimary),
  ),
  iconTheme: const IconThemeData(color: AppTheme.primaryColor),
)

// ❌ INCORRECTO
AppBar(
  backgroundColor: Theme.of(context).colorScheme.inversePrimary, // ❌ NO
)
```

### 10. **CircularProgressIndicator**

```dart
// ✅ CORRECTO
CircularProgressIndicator(
  color: AppTheme.primaryColor,
)

// ✅ CORRECTO - En botón
CircularProgressIndicator(
  color: Colors.white,  // OK si el fondo es oscuro
  strokeWidth: 2,
)
```

### 11. **Icon con estados**

```dart
// ✅ CORRECTO
Icon(
  Icons.check_circle,
  color: AppTheme.successColor,  // Verde
)

Icon(
  Icons.error,
  color: AppTheme.errorColor,  // Rojo
)

Icon(
  Icons.info,
  color: AppTheme.infoColor,  // Azul
)

Icon(
  Icons.icon_name,
  color: AppTheme.textSecondary,  // Gris medio
)

// ❌ INCORRECTO
Icon(
  Icons.check_circle,
  color: Colors.green,  // ❌ NO
)
```

### 12. **Container con bordes**

```dart
// ✅ CORRECTO
Container(
  decoration: BoxDecoration(
    color: AppTheme.surfaceColor,
    border: Border.all(
      color: AppTheme.borderColor,
      width: 1,
    ),
    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
  ),
  child: ...
)

// ❌ INCORRECTO
Container(
  decoration: BoxDecoration(
    color: Colors.grey.withOpacity(0.1),  // ❌ NO
    boxShadow: [BoxShadow(...)],  // ❌ Evitar sombras
  ),
)
```

### 13. **Divider**

```dart
// ✅ CORRECTO
Divider(
  color: AppTheme.borderColor,
  thickness: 1,
)

// ❌ INCORRECTO
Divider()  // Sin color explícito
```

### 14. **showModalBottomSheet**

```dart
// ✅ CORRECTO
showModalBottomSheet(
  context: context,
  backgroundColor: AppTheme.surfaceColor,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(AppTheme.radiusMedium),
    ),
  ),
  builder: (context) => Container(
    padding: const EdgeInsets.all(AppTheme.spacingLarge),
    color: AppTheme.surfaceColor,  // Importante
    child: ...
  ),
)
```

## 📊 Vistas Corregidas

### ✅ login_page.dart
- Cards con fondo blanco
- Inputs con bordes del tema
- Botones con colores correctos
- TextButton "Olvidó contraseña" con color primario
- Dividers con color del tema

### ✅ home_page.dart
- AppBar con colores del tema
- PopupMenu sin tinte rosado
- FloatingActionButton con colores correctos
- TextField de búsqueda con colores del tema
- AlertDialog de logout correcto
- Todos los SnackBars con colores apropiados

### ✅ select_point_of_sale_page.dart
- AppBar sin inversePrimary
- Cards con colores del tema
- Iconos con colores del tema (sin Colors.grey)
- Textos con colores del tema
- SnackBars con successColor/errorColor
- CircularProgressIndicator con color primario
- Estados seleccionado/no seleccionado con colores correctos

### ✅ custom_text_field.dart
- Bordes explícitos en todos los estados
- Colores de placeholder correctos
- Cursor con color primario
- Sin colores fuera del esquema

### ✅ product_card.dart
- Card sin tinte rosado
- Bordes sutiles
- Badges con colores del tema

### ✅ custom_button.dart
- Elevation 0 (sin sombras)
- Colores del tema

## 🔧 Checklist de Revisión

Antes de crear o modificar un componente, verifica:

- [ ] ¿Usa solo colores de `AppTheme`?
- [ ] ¿Tiene `surfaceTintColor: Colors.transparent` si es Card/Dialog/PopupMenu?
- [ ] ¿Tiene `elevation: 0` o muy bajo?
- [ ] ¿Usa `AppTheme.radiusSmall` (8px) para border radius?
- [ ] ¿Los textos usan `textPrimary`, `textSecondary` o `textDisabled`?
- [ ] ¿Los bordes usan `borderColor` o `borderColorDark`?
- [ ] ¿Los estados de error usan `errorColor`?
- [ ] ¿Los estados de éxito usan `successColor`?
- [ ] ¿Sin gradientes ni sombras excesivas?

## 🚨 Errores Comunes a Evitar

1. **Usar Theme.of(context)** en lugar de AppTheme
2. **Olvidar surfaceTintColor** en Cards/Dialogs
3. **Usar Colors.grey** directamente
4. **Usar Colors.red/green** para estados
5. **Olvidar especificar bordes explícitos** en inputs
6. **Usar elevations altas** (>2)
7. **No especificar colores de texto** explícitamente

## 📝 Ejemplo Completo

```dart
// ✅ Vista completa con diseño consistente
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: const Text(
          'Mi Página',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          children: [
            // Card
            Card(
              elevation: 0,
              color: AppTheme.surfaceColor,
              surfaceTintColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Text(
                  'Contenido',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingMedium),
            
            // Botón
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text('Acción'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

**Última actualización:** Todas las vistas han sido revisadas y corregidas para usar exclusivamente los colores del tema profesional.

