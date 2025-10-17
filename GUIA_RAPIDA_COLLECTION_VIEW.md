# ⚡ GUÍA RÁPIDA: Ver Collection View Toggle en Shopify

## 🚀 EN 5 MINUTOS

### 1️⃣ Ve al Admin
```
Shopify Admin → Online Store → Themes
```

### 2️⃣ Customiza
Haz clic en **"Customize"** en tu tema activo

### 3️⃣ Selecciona una Colección
En el editor, selecciona una colección (ej: "All Products" o "Men's Collection")

### 4️⃣ Encuentra la Sección Collection
En el panel derecho, busca "Collection" y expándela

### 5️⃣ Marca el Checkbox
Busca: **"Enable view toggle (single, double, editorial)"** ✅

### 6️⃣ Guarda
Haz clic en **"Save"** o **"Publish"**

### 7️⃣ ¡Hecho!
Verás los 3 botones en el preview del lado izquierdo:
```
View: [ □ ] [ ⬜ ] [ 📊 ]
```

---

## 🎯 DÓNDE VES LOS BOTONES

Aparecen en la **barra de utilidades** de la colección:

```
[Filtros] [Ordenar por] [View: □ ⬜ 📊]
                        ↑
                    AQUÍ ESTÁN
```

---

## 🔄 LAS 3 VISTAS

- **□ Single** → 1 producto por fila (ancho completo)
- **⬜ Double** → 2 productos por fila (por defecto)
- **📊 Editorial** → 3 columnas con efecto masonry

Cada una está optimizada para desktop, tablet y mobile.

---

## 💾 LO MEJOR: MEMORIA AUTOMÁTICA

El usuario elige una vista → se guarda en su navegador → próxima vez ve la misma vista automáticamente.

---

## 🌍 APLICA A TODAS TUS COLECCIONES

Una vez habilitado, funciona en:
- ✅ Todas las colecciones
- ✅ Búsquedas
- ✅ Colecciones personalizadas
- ✅ Nuevas categorías que crees

---

## 📱 RESPONSIVE

- **Desktop**: 3 columnas en editorial
- **Tablet**: 2 columnas en editorial
- **Mobile**: 1 columna (se adapta)

---

## 🎨 PERSONALIZABLE

### Cambiar vista por defecto
En `sections/main-collection.liquid`, cambia qué botón tiene `aria-pressed="true"`

### Cambiar estilos
Edita `.js-view-btn` y `.collection-view-toggle` en `assets/section-collection.css`

### Traducir etiquetas
En `locales/es.json`, edita:
```json
"view": "Vista",
"view_single": "Una columna",
"view_double": "Dos columnas",
"view_editorial": "Editorial"
```

---

## ✅ VERIFICACIÓN

- ✓ ¿Ves los 3 botones en el preview?
- ✓ ¿Funcionan al hacer clic?
- ✓ ¿Cambia el grid de productos?
- ✓ ¿Se ve bien en mobile?
- ✓ ✅ ¡Listo!

---

## ❌ SI NO FUNCIONA

Abre **Developer Tools** (F12) y busca errores en Console.

Verifica:
1. ☑️ El checkbox está marcado
2. ☑️ Es la sección "Collection" correcta
3. ☑️ Publicaste los cambios
4. ☑️ Limpiaste el caché del navegador

---

## 📚 MÁS INFORMACIÓN

Lee los documentos de referencia:
- `COLLECTION_VIEW_FEATURE.md` - Documentación técnica
- `COLLECTION_VIEW_TOGGLE_IMPLEMENTATION.md` - Guía de implementación
- `COMO_VER_COLLECTION_VIEW_TOGGLE.md` - Instrucciones detalladas
- `GUIA_VISUAL_COLLECTION_VIEW.md` - Imágenes ASCII explicativas

---

## 🎉 ¡LISTO!

Ya tienes el Collection View Toggle funcionando en tu tema Shopify.

Los clientes ahora pueden elegir cómo ver los productos en tu tienda.

¿Necesitas ayuda? Revisa los documentos o ajusta los estilos según tu marca. 🚀
