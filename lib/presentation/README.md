# Capa de Presentación - Restobar POS

## Descripción General

La capa de presentación ha sido completamente rediseñada con un enfoque profesional y formal, implementando Material Design 3 con una paleta de colores corporativa y componentes reutilizables.

## Estructura de Carpetas

```
presentation/
├── pages/
│   ├── auth/
│   │   └── login_page.dart        # Página de inicio de sesión rediseñada
│   └── home/
│       └── home_page.dart         # Página principal con grid view
└── widgets/
    ├── custom_button.dart         # Botones personalizados
    ├── custom_text_field.dart     # Campos de texto personalizados
    └── product_card.dart          # Tarjeta de producto profesional
```

## Características del Diseño

### 1. Sistema de Tema Profesional Minimalista

Se implementó un sistema de tema centralizado en `core/constants/app_theme.dart` con enfoque minimalista y sobrio:

- **Paleta de colores profesional con buen contraste**:
  - Primario: Azul oscuro profesional (#1E3A5F)
  - Secundario: Azul medio (#2C5282)
  - Éxito: Verde oscuro visible (#38A169)
  - Error: Rojo oscuro no brillante (#E53E3E)
  - Fondo: Gris azul muy claro (#F7FAFC)

- **Espaciado consistente**: Sistema de spacing con valores predefinidos (XSmall a XXLarge)
- **Border radius**: Valores pequeños (8px) para un look más limpio y profesional
- **Elevaciones minimalistas**: Sin sombras o muy sutiles (0-2px) para diseño plano
- **Bordes**: Bordes sutiles en lugar de sombras para definir elementos

### 2. Componentes Reutilizables

#### CustomTextField
Campo de texto con diseño profesional que incluye:
- Etiqueta superior con estilo consistente
- Soporte para iconos de prefijo y sufijo
- Validación integrada
- Estados de foco y error bien definidos

#### CustomButton
Botón versátil con:
- Variantes: filled y outlined
- Estado de carga con spinner
- Soporte para iconos
- Dimensiones personalizables

#### ProductCard
Tarjeta de producto con:
- Header con gradiente y ícono
- Información estructurada del producto
- Estados visuales (activo/inactivo)
- Animación de toque (InkWell)

### 3. Página de Login (login_page.dart)

**Características:**
- Layout responsive (diferente en móvil y desktop)
- Panel lateral informativo en pantallas grandes
- Formulario centrado y elegante
- Validación en tiempo real
- Mensajes de error/éxito mejorados

**Layout Desktop:**
- Panel izquierdo con información corporativa
- Panel derecho con formulario de login
- Fondo sólido sin gradientes para look más sobrio
- Lista de características del sistema con bullets minimalistas

**Layout Móvil:**
- Formulario centrado con card con borde sutil (sin sombras)
- Logo compacto en la parte superior con borde
- Diseño optimizado para pantallas pequeñas

### 4. Página Principal (home_page.dart)

**Características:**
- AppBar personalizado con logo y usuario
- Header con estadísticas en tarjetas
- Barra de búsqueda mejorada
- Grid view responsive de productos
- Modal de detalles de producto

**Grid Responsive:**
- 4 columnas en pantallas grandes (>1200px)
- 3 columnas en tablets (>800px)
- 2 columnas en tablets pequeñas (>600px)
- 1 columna en móviles

**Estadísticas:**
- Total de productos
- Productos activos
- Productos inactivos
- Cada estadística con color temático

**Funcionalidades:**
- Sincronización con API
- Búsqueda en tiempo real
- Recarga de productos
- Detalles de producto en modal
- Cierre de sesión confirmado

### 5. Mejoras de UX

1. **Feedback Visual:**
   - Snackbars con iconos y colores semánticos
   - Loading states en botones
   - Progress indicators durante operaciones
   - Estados vacíos informativos

2. **Navegación:**
   - Transiciones suaves entre páginas
   - Confirmación antes de acciones destructivas
   - Menú de usuario con avatar personalizado

3. **Accesibilidad:**
   - Textos con contraste adecuado
   - Tamaños de fuente legibles
   - Áreas de toque apropiadas (min 48x48)
   - Tooltips en iconos

4. **Responsive Design:**
   - Layouts adaptativos según tamaño de pantalla
   - Grid flexible en página principal
   - Formularios optimizados para móvil y desktop

## Paleta de Colores (Profesional con Buen Contraste)

| Color | Hex | Uso |
|-------|-----|-----|
| Primary | #1E3A5F | Botones principales, header, elementos destacados |
| Secondary | #2C5282 | Elementos secundarios |
| Success | #38A169 | Estados activos, mensajes de éxito |
| Error | #E53E3E | Errores, acciones destructivas |
| Warning | #D69E2E | Advertencias |
| Info | #3182CE | Información |
| Text Primary | #1A202C | Texto principal (negro azulado) |
| Text Secondary | #4A5568 | Texto secundario, etiquetas |
| Text Disabled | #A0AEC0 | Texto deshabilitado |
| Border | #E2E8F0 | Bordes sutiles |
| Border Dark | #CBD5E0 | Bordes más visibles |
| Background | #F7FAFC | Fondo de la aplicación |

## Tipografía

Se utiliza la tipografía por defecto de Material Design 3 con los siguientes ajustes:

- **Headlines**: Negrita, para títulos principales
- **Titles**: Semi-negrita, para subtítulos y cards
- **Body**: Regular, para contenido general
- **Labels**: Semi-negrita, para etiquetas y botones

## Espaciado

Sistema de espaciado consistente:

- **XSmall**: 4px - Para espacios muy pequeños
- **Small**: 8px - Espaciado entre elementos relacionados
- **Medium**: 16px - Espaciado estándar
- **Large**: 24px - Separación entre secciones
- **XLarge**: 32px - Separación entre bloques grandes
- **XXLarge**: 48px - Márgenes externos

## Guía de Uso

### Implementar un nuevo campo de texto:

```dart
CustomTextField(
  controller: _myController,
  label: 'Etiqueta',
  hint: 'Texto de ayuda',
  prefixIcon: Icons.icon_name,
  validator: (value) {
    // Tu validación
    return null;
  },
)
```

### Implementar un botón:

```dart
CustomButton(
  text: 'Texto del Botón',
  onPressed: () {
    // Tu acción
  },
  isLoading: _isLoading,
  icon: Icons.icon_name,
)
```

### Mostrar productos en grid:

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.75,
  ),
  itemBuilder: (context, index) {
    return ProductCard(
      product: products[index],
      onTap: () {
        // Acción al tocar
      },
    );
  },
)
```

## Mejores Prácticas

1. **Consistencia**: Usar siempre los componentes y valores del tema
2. **Responsive**: Considerar diferentes tamaños de pantalla
3. **Feedback**: Proporcionar retroalimentación visual al usuario
4. **Estados**: Manejar estados de carga, error y vacío
5. **Accesibilidad**: Mantener contraste y tamaños apropiados

## Próximas Mejoras Sugeridas

1. Implementar animaciones entre transiciones
2. Agregar soporte para tema oscuro
3. Implementar internacionalización (i18n)
4. Agregar más variantes de componentes
5. Implementar caché de imágenes para productos
6. Agregar filtros avanzados en la página de productos
7. Implementar vista de lista como alternativa al grid
8. Agregar gráficos y reportes visuales

