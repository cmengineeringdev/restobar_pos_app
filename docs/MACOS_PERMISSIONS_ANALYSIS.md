# Análisis de Permisos para macOS - Restobar POS

## 📋 Resumen Ejecutivo

Tu aplicación **Restobar POS** es un sistema de punto de venta que requiere varios permisos específicos de macOS para funcionar correctamente. A continuación se detalla el análisis completo.

---

## 🔍 Funcionalidades Detectadas

### 1. **Base de Datos Local (SQLite)**
- ✅ Usa `sqflite_common_ffi`
- ✅ Almacena productos, puntos de venta
- ✅ Ubicación: Application Documents Directory

### 2. **Almacenamiento de Datos**
- ✅ Usa `shared_preferences` para tokens y configuración
- ✅ Usa `path_provider` para acceder a directorios del sistema

### 3. **Comunicación de Red**
- ✅ Realiza peticiones HTTP a API externa
- ✅ Endpoints detectados:
  - Login: `/api/login`
  - Productos: `/api/products`
  - Puntos de Venta: `/api/pointOfSale`

---

## 🛡️ Permisos Actuales Configurados

### Debug/Profile Entitlements (`DebugProfile.entitlements`)
```xml
✅ com.apple.security.app-sandbox = true
✅ com.apple.security.cs.allow-jit = true
✅ com.apple.security.network.server = true
```

### Release Entitlements (`Release.entitlements`)
```xml
✅ com.apple.security.app-sandbox = true
```

---

## ⚠️ PROBLEMAS IDENTIFICADOS

### 🔴 **Problema Crítico: Faltan Permisos en Release**

Tu archivo `Release.entitlements` **NO tiene los permisos necesarios** para que la aplicación funcione en producción. Actualmente solo tiene el sandbox habilitado.

### Permisos Faltantes en Release:

1. **❌ Acceso a Red (Cliente)** - `com.apple.security.network.client`
   - **Crítico**: Sin este permiso, no podrás hacer peticiones HTTP a tu API
   - **Impacto**: Login, sincronización de productos y puntos de venta NO funcionarán

2. **❌ JIT Compilation** - `com.apple.security.cs.allow-jit`
   - **Importante**: Flutter requiere JIT para mejor rendimiento
   - **Impacto**: Posibles problemas de rendimiento en Debug

3. **⚠️ Acceso a Archivos** - `com.apple.security.files.user-selected.read-write`
   - **Opcional pero Recomendado**: Si planeas exportar/importar datos
   - **Impacto**: No podrás guardar/cargar archivos fuera del sandbox

---

## ✅ SOLUCIÓN RECOMENDADA

### 1. Actualizar `Release.entitlements`

Debes agregar los siguientes permisos mínimos requeridos:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App Sandbox (obligatorio para Mac App Store) -->
    <key>com.apple.security.app-sandbox</key>
    <true/>
    
    <!-- CRÍTICO: Acceso de red para peticiones HTTP -->
    <key>com.apple.security.network.client</key>
    <true/>
    
    <!-- JIT para mejor rendimiento de Flutter -->
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
</dict>
</plist>
```

### 2. Permisos Opcionales (Agregar según necesidades futuras)

```xml
<!-- Si necesitas imprimir tickets/facturas -->
<key>com.apple.security.print</key>
<true/>

<!-- Si necesitas exportar reportes -->
<key>com.apple.security.files.user-selected.read-write</key>
<true/>

<!-- Si necesitas acceso a carpetas específicas -->
<key>com.apple.security.files.downloads.read-write</key>
<true/>

<!-- Si usas Bluetooth para impresoras/dispositivos -->
<key>com.apple.security.device.bluetooth</key>
<true/>

<!-- Si usas cámara para escanear códigos QR -->
<key>com.apple.security.device.camera</key>
<true/>
```

### 3. Actualizar `Info.plist` (Si usas servicios adicionales)

Si en el futuro necesitas acceso a recursos protegidos, debes agregar descripciones de uso:

```xml
<!-- Ejemplo: Si usas cámara -->
<key>NSCameraUsageDescription</key>
<string>Esta aplicación necesita acceso a la cámara para escanear códigos de productos</string>

<!-- Ejemplo: Si imprimes -->
<key>NSPrintingUsageDescription</key>
<string>Esta aplicación necesita acceso a la impresora para imprimir tickets y facturas</string>
```

---

## 📊 Matriz de Permisos vs Funcionalidades

| Funcionalidad | Permiso Requerido | Prioridad | Estado Actual |
|--------------|-------------------|-----------|---------------|
| Login/API | `network.client` | 🔴 Crítico | ❌ Falta en Release |
| Base de datos local | Sandbox implícito | ✅ Medio | ✅ Configurado |
| JIT (rendimiento) | `cs.allow-jit` | 🟡 Importante | ❌ Falta en Release |
| Servidor local (debug) | `network.server` | 🟢 Bajo | ✅ En Debug |
| Impresión | `print` | 🟢 Opcional | ❌ No configurado |
| Archivos | `files.user-selected` | 🟢 Opcional | ❌ No configurado |

---

## 🚨 Acciones Inmediatas Recomendadas

### Prioridad ALTA (Hacer YA)
1. ✅ Agregar `com.apple.security.network.client` a `Release.entitlements`
2. ✅ Agregar `com.apple.security.cs.allow-jit` a `Release.entitlements`

### Prioridad MEDIA (Considerar)
3. 🤔 Evaluar si necesitas impresión de tickets
4. 🤔 Evaluar si necesitas exportar reportes

### Prioridad BAJA (Futuro)
5. 📋 Documentar permisos adicionales según evolución de la app

---

## 🧪 Cómo Verificar los Permisos

### 1. Probar en Modo Release
```bash
flutter build macos --release
```

### 2. Verificar los Entitlements del Bundle
```bash
codesign -d --entitlements - /Users/juanquintero/Documents/Projects/flutter/restobar_pos_app/build/macos/Build/Products/Release/restobar_pos_app.app
```

### 3. Revisar Logs de Sandbox
```bash
log show --predicate 'process == "restobar_pos_app"' --last 5m | grep sandbox
```

---

## 📝 Consideraciones para Distribución

### App Store (si aplica)
- ✅ Todos los permisos deben estar justificados en la revisión
- ✅ Debes explicar por qué necesitas cada permiso
- ✅ El sandboxing es obligatorio

### Distribución Fuera del App Store
- ✅ Requiere firma de desarrollador
- ✅ Los usuarios verán advertencias de Gatekeeper
- ✅ Considera notarización para evitar problemas

---

## 🔗 Referencias

- [Apple: Entitlements Documentation](https://developer.apple.com/documentation/bundleresources/entitlements)
- [Flutter macOS Desktop Support](https://docs.flutter.dev/development/platform-integration/macos/building)
- [App Sandbox Design Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/)

---

## 📅 Historial de Cambios

| Fecha | Cambio |
|-------|--------|
| 2025-10-18 | Análisis inicial de permisos |

---

**⚡ Próximo Paso**: Aplicar los cambios recomendados en `Release.entitlements`





