# 🎨 Guía Visual: Dónde y Cómo Ver el Collection View Toggle

## 📍 UBICACIÓN EN EL SHOPIFY ADMIN

```
┌─────────────────────────────────────────────────────────┐
│ Shopify Admin                                            │
│ ═══════════════════════════════════════════════════════ │
│                                                           │
│  Online Store → Themes → [Tu Tema] → Customize ✓        │
│                                                           │
└─────────────────────────────────────────────────────────┘
         ↓
    Selecciona una
    Colección
         ↓
┌─────────────────────────────────────────────────────────┐
│ PREVIEW                          SETTINGS PANEL          │
│                                  ═══════════════════════ │
│ ┌───────────────────────────┐    │ Sections:            │
│ │ [Colección]               │    │                      │
│ │ ═══════════════════════   │    │ ✓ Banner            │
│ │                           │    │ ✓ Collection        │ ←
│ │ FILTROS│SORT│[□⬜📊] ←   │    │   ├─ enable_sorting  │
│ │         AQUÍ APARECEN     │    │   ├─ filters        │
│ │         LOS BOTONES       │    │   ├─ enable_view    │
│ │                           │    │   │  _toggle       │  ← AQUÍ
│ │ Productos Grid:           │    │   └─ ... etc       │
│ │ ┌─┐ ┌─┐                   │    │                    │
│ │ │1│ │2│                   │    │ ☑️ enable_view     │
│ │ └─┘ └─┘                   │    │    _toggle         │
│ │ ┌─┐ ┌─┐                   │    │                    │
│ │ │3│ │4│                   │    │ (Cambias aquí)      │
│ │ └─┘ └─┘                   │    │                    │
│ └───────────────────────────┘    └────────────────────┘
└─────────────────────────────────────────────────────────┘
```

---

## 🖱️ PASO A PASO EN EL EDITOR

### PASO 1: Abre Customize
```
Shopify Admin
    ↓
Online Store
    ↓
Themes
    ↓
[Tu Tema Activo] → Customize ← HACES CLIC AQUÍ
```

### PASO 2: Selecciona una Colección
```
En el editor, arriba verás un dropdown/selector:

┌──────────────────────────┐
│ Collections  ▼           │  ← Haces clic
├──────────────────────────┤
│ All Products             │
│ Men's Collection         │  ← Selecciona una
│ Women's Collection       │
│ Summer Sale              │
└──────────────────────────┘
```

### PASO 3: Busca la Sección "Collection"
```
Panel de Secciones (lado derecho):

┌────────────────────────────────┐
│ SECTIONS                        │
├────────────────────────────────┤
│ ▼ Banner Landing                │
│ ▼ Page Banner                   │
│ ▼ Collection         ← AQUÍ      │
│   ├─ Filters                    │
│   ├─ Enable sorting             │
│   ├─ Enable view toggle    ✓    │  ← MARCA AQUÍ
│   └─ ... more settings          │
│ ▼ Recommended Products          │
│ ▼ Newsletter Banner             │
└────────────────────────────────┘
```

### PASO 4: Marca el Checkbox
```
Busca en la sección "Collection":

☐ Enable view toggle (single, double, editorial)

Cambias a:

☑ Enable view toggle (single, double, editorial)
```

### PASO 5: Haz clic Save/Publish
```
Botón en la parte inferior derecha:

[Save] o [Publish Changes]
```

### PASO 6: ¡Verás los Botones!
```
En el preview izquierdo, aparecerán los botones:

┌─────────────────────────────────┐
│ COLLECTION PAGE                 │
├─────────────────────────────────┤
│ View: [ □ ] [ ⬜ ] [ 📊 ]      │ ← LOS 3 BOTONES
│        Single Double Editorial  │
├─────────────────────────────────┤
│ PRODUCTO 1 │ PRODUCTO 2         │
│ Imagen     │ Imagen             │
│ Precio     │ Precio             │
│            │                    │
│ PRODUCTO 3 │ PRODUCTO 4         │
│ Imagen     │ Imagen             │
│ Precio     │ Precio             │
└─────────────────────────────────┘
```

---

## 🔄 CAMBIAR ENTRE VISTAS

Cuando hagas clic en cada botón, el grid cambia:

### Vista 1: SINGLE COLUMN (□)
```
┌────────────────────────────┐
│ PRODUCTO 1                 │
│ ┌──────────────────────┐   │
│ │                      │   │
│ │      IMAGEN          │   │
│ │                      │   │
│ │                      │   │
│ └──────────────────────┘   │
│ Nombre del Producto        │
│ $99.99                     │
│ [Add to Cart]              │
├────────────────────────────┤
│ PRODUCTO 2                 │
│ ┌──────────────────────┐   │
│ │                      │   │
│ │      IMAGEN          │   │
│ │                      │   │
│ │                      │   │
│ └──────────────────────┘   │
│ Nombre del Producto        │
│ $99.99                     │
│ [Add to Cart]              │
└────────────────────────────┘
```

### Vista 2: DOUBLE COLUMN (⬜) - DEFAULT
```
┌──────────────────┬──────────────────┐
│ PRODUCTO 1       │ PRODUCTO 2       │
│ ┌──────────┐     │ ┌──────────┐     │
│ │ IMAGEN   │     │ │ IMAGEN   │     │
│ │          │     │ │          │     │
│ └──────────┘     │ └──────────┘     │
│ Producto         │ Producto         │
│ $99.99           │ $99.99           │
├──────────────────┼──────────────────┤
│ PRODUCTO 3       │ PRODUCTO 4       │
│ ┌──────────┐     │ ┌──────────┐     │
│ │ IMAGEN   │     │ │ IMAGEN   │     │
│ │          │     │ │          │     │
│ └──────────┘     │ └──────────┘     │
│ Producto         │ Producto         │
│ $99.99           │ $99.99           │
└──────────────────┴──────────────────┘
```

### Vista 3: EDITORIAL/MASONRY (📊)
```
┌────────────────┬────────────────┬─────────────┐
│                │                │ PRODUCTO 3  │
│  PRODUCTO 1    │  PRODUCTO 2    │ ┌─────────┐ │
│ ┌────────────┐ │ ┌────────────┐ │ │ IMAGEN  │ │
│ │            │ │ │            │ │ │         │ │
│ │   IMAGEN   │ │ │   IMAGEN   │ │ └─────────┘ │
│ │            │ │ │            │ │ Producto   │
│ │            │ │ │            │ │ $99.99     │
│ └────────────┘ │ └────────────┘ ├─────────────┤
│   (2x2)        │                │ PRODUCTO 5  │
│                │  (1x1)         │ ┌─────────┐ │
│                │                │ │ IMAGEN  │ │
│                │                │ │         │ │
│                ├────────────────┤ └─────────┘ │
│ PRODUCTO 4     │ PRODUCTO 6     │ Producto   │
│ ┌────────────┐ │ ┌────────────┐ │ $99.99     │
│ │            │ │ │            │ │            │
│ │   IMAGEN   │ │ │   IMAGEN   │ │ (2x2)      │
│ │            │ │ │            │ │            │
│ │            │ │ │            │ │            │
│ └────────────┘ │ └────────────┘ │            │
│   (1x1)        │    (1x1)       │            │
└────────────────┴────────────────┴─────────────┘
         ↓ (El patrón se repite)
```

---

## 📱 EN DIFERENTES DISPOSITIVOS

### DESKTOP (≥ 1100px)
```
View: [ □ Single ] [ ⬜ Double ] [ 📊 Editorial ]
```
- Single: 1 columna
- Double: 2 columnas
- Editorial: 3 columnas con masonry

### TABLET (750px - 1099px)
```
View: [ □ ] [ ⬜ ] [ 📊 ]
```
- Single: 1 columna
- Double: 2 columnas
- Editorial: 2 columnas (adaptado)

### MOBILE (< 750px)
```
View: [ □ Single ][ ⬜ Double ][ 📊 Editorial ]
```
- Single: 1 columna (o 2 según config)
- Double: 2 columnas
- Editorial: 1 columna (colapsado)

---

## 💾 PERSISTENCIA (Memoria del Usuario)

Una característica importante es que **la preferencia se guarda**:

```
PRIMERA VISITA:
Usuario entra → Ve la vista por defecto (Double)
                 ↓
Hace clic en "Single"
                 ↓
Se guarda en localStorage
                 ↓
SEGUNDA VISITA:
Usuario regresa → Ve la vista "Single" automáticamente
(sin hacer clic nuevamente)
```

---

## 🔍 VERIFICAR QUE FUNCIONE

### En el Editor (Customize)
1. ✅ Busca los 3 botones en el preview
2. ✅ Haz clic en cada uno
3. ✅ El grid cambia instantáneamente
4. ✅ Los botones muestran cuál está activo (fondo oscuro)

### En tu Tienda En Vivo
1. Abre una colección en tu tienda
2. Deberías ver los botones (si están habilitados)
3. Prueba cambiar de vista
4. Actualiza la página → la vista se mantiene

---

## ❌ SI NO VES LOS BOTONES

### Checklist:
1. ☐ ¿Está marcado el checkbox "Enable view toggle"?
2. ☐ ¿Editaste la sección "Collection" (no otra)?
3. ☐ ¿Publicaste los cambios?
4. ☐ ¿El tema está activo (verde)?
5. ☐ ¿Estás viendo en modo Customize (no en modo de ver)?

### Soluciones:
- Abre Developer Tools (F12) → Console
- Busca errores de JavaScript
- Limpia el caché (Ctrl+Shift+Delete)
- Intenta en navegador privado

---

## 🎯 PARA TRADUCIR A OTROS IDIOMAS

Si tienes tienda multiidioma, los botones se tradujeron automáticamente.

Puedes editarlos en:
```
Archivo: locales/es.json (español)
Busca la sección: "collection"
Edita:
  "view": "Vista",
  "view_single": "Una columna",
  "view_double": "Dos columnas",
  "view_editorial": "Editorial"
```

---

## 📊 ESTRUCTURA FINAL

Una vez implementado, así se ve en el árbol del tema:

```
theme/
├── assets/
│   ├── collection-view.js          ← Maneja los clics
│   └── section-collection.css      ← Estilos del toggle y grid
│
├── sections/
│   └── main-collection.liquid      ← Template con los botones
│                                      y settings
│
├── templates/
│   ├── collection.json             ← Template de colecciones
│   ├── collection.mens.json        ← Template personalizado
│   └── ... (otros)
│
└── locales/
    ├── en.default.json             ← Textos en inglés
    ├── es.json                     ← Textos en español
    └── ... (otros idiomas)
```

**Cuando habilitás el toggle:**
1. Se carga `collection-view.js`
2. Se aplican estilos de `.js-view-btn` y `.collection-view-toggle`
3. Los usuarios pueden cambiar de vista
4. Su preferencia se guarda localmente

---

## ✅ LISTO PARA USAR

Ahora ya sabes:
- ✓ Dónde ver los botones
- ✓ Cómo habilitarlos
- ✓ Qué esperar cuando funcionen
- ✓ Cómo verificar que está funcionando
- ✓ Qué hacer si no aparecen

¡Pruébalo en tu tienda y cuéntame si necesitas ayuda! 🚀
