# 🎯 Cómo Ver y Usar el Collection View Toggle en Shopify

## Opción 1: Ver en una Colección Existente (MÁS RÁPIDO)

### Paso 1: Acceder al Editor del Tema
1. Ve a tu **Shopify Admin**
2. Navega a **Online Store** → **Themes**
3. En tu tema activo, haz clic en **Customize** (o **Edit code**)

### Paso 2: Ir a una Colección
1. En la barra de navegación del editor, busca **Collection**
2. Selecciona cualquier colección existente, por ejemplo:
   - Haz clic en el dropdown/selector de páginas
   - Busca y selecciona una colección como "All Products", "Men's Collection", etc.

### Paso 3: Encontrar la Sección "Main Collection"
1. En el panel derecho, verás las secciones de la página
2. Busca la sección llamada **"Collection"** (es la que usa `main-collection.liquid`)
3. Haz clic en ella para expandirla

### Paso 4: Activar el Toggle de Vista
1. En los settings de la sección, busca la opción:
   - **"Enable view toggle (single, double, editorial)"**
2. Marca el checkbox ✅
3. Haz clic en **Save** o **Publish**

### Paso 5: Ver el Resultado
1. En el preview de la página, verás los **3 botones de vista** aparecer arriba del grid de productos
2. Prueba haciendo clic en cada botón:
   - 📋 Single column
   - ⬜ Double column (default)
   - 📊 Editorial

---

## Opción 2: Crear un Archivo JSON Personalizado para Nueva Colección

Si quieres crear una **nueva colección desde cero** con el toggle ya habilitado:

### Paso 1: Crear archivo JSON de colección
1. En VS Code o tu editor, abre `/templates/`
2. Crea un nuevo archivo: `collection.mi-nueva-coleccion.json`
3. Copia el contenido de `collection.json` como base

### Paso 2: Modificar el archivo
En la sección `"main_collection"` (busca en el archivo), agrega/modifica esta línea:

```json
"main_collection": {
  "type": "main-collection",
  "settings": {
    "enable_view_toggle": true,  // 👈 Asegúrate de que sea true
    "filters": "drawer",
    "enable_sorting": true,
    "products_per_page": 16,
    // ... resto de settings
  }
}
```

### Paso 3: Crear la colección en Shopify Admin
1. Ve a **Products** → **Collections**
2. Crea una **nueva colección** manual o por condiciones
3. Dale un nombre, por ejemplo: "Mi Nueva Colección"
4. Guarda

### Paso 4: Asignar el template
1. En la página de la colección que acabas de crear
2. Baja hasta el final y busca **"Template"** o **"Theme template"**
3. Selecciona tu archivo JSON personalizado (si existe)
4. Guarda

---

## Opción 3: Ver en Vivo en tu Tienda (SIN tema en desarrollo)

### Paso 1: Publicar cambios
1. Asegúrate de que tu tema esté **publicado** (no es un draft)
2. Ve a **Online Store** → **Themes**
3. Verifica que tu tema sea el "Active" (en verde)

### Paso 2: Ir a una colección en vivo
1. Abre tu tienda en una ventana privada/incógnito
2. Navega a cualquier categoría/colección
3. Deberías ver los botones de vista si:
   - ✅ El toggle está habilitado en la sección
   - ✅ La página usa el template `main-collection.liquid`

### Paso 3: Probar la funcionalidad
1. Haz clic en cada botón de vista
2. La página cambiará instantáneamente sin recargar
3. Actualiza la página → la vista se mantiene (localStorage)

---

## Opción 4: Crear desde el Liquid Editor (Programadores)

Si prefieres trabajar directamente con código:

### Paso 1: Editar `main-collection.liquid`
1. Ve a **Online Store** → **Themes** → **Customize**
2. En la barra lateral, abre **Edit code** (o en Customize, busca el menú)
3. En Assets, abre `main-collection.liquid`

### Paso 2: Verificar que el toggle esté activado
Busca en el schema (al final del archivo) esta línea:

```liquid
{
  "type": "checkbox",
  "id": "enable_view_toggle",
  "label": "t:sections.main-collection.settings.enable_view_toggle.label",
  "default": true
}
```

Asegúrate de que `"default": true`

### Paso 3: Guardar y ver en preview
1. Guarda el archivo
2. Ve a una colección en preview
3. El toggle debería estar habilitado por defecto

---

## ¿Dónde Ver Exactamente los Botones?

Cuando accedas a una colección y el toggle esté habilitado, verás esto:

```
┌─────────────────────────────────────────┐
│  FILTROS    ORDENAR    [VIEW: □ ⬜ 📊]  │  ← AQUÍ ESTÁN LOS BOTONES
├─────────────────────────────────────────┤
│  Producto 1    Producto 2                │
│  [imagen]      [imagen]                  │
│  Precio        Precio                    │
│                                          │
│  Producto 3    Producto 4                │
│  [imagen]      [imagen]                  │
│  Precio        Precio                    │
└─────────────────────────────────────────┘
```

Los botones están en la **barra de utilidades** junto a filtros y ordenamiento.

---

## 📋 Checklist: Paso a Paso Rápido

### Para Ver Inmediatamente:
- [ ] Abre Shopify Admin
- [ ] Ve a Online Store → Themes → Customize
- [ ] Selecciona una colección existente
- [ ] Busca la sección "Collection"
- [ ] Marca "Enable view toggle"
- [ ] Haz clic en un botón para cambiar vista
- [ ] ✅ ¡Listo!

### Para Hacer Permanente:
- [ ] Asegúrate de que `"default": true` en `main-collection.liquid`
- [ ] Publica cambios
- [ ] Prueba en tu tienda en vivo

---

## 🔍 Solución de Problemas

### Los botones no aparecen
1. ✅ Verifica que el checkbox esté marcado
2. ✅ Asegúrate de que sea la sección "Main Collection"
3. ✅ Revisa que `collection-view.js` exista en Assets
4. ✅ Abre la consola (F12) y busca errores de JavaScript

### Los botones aparecen pero no funcionan
1. ✅ Abre Developer Tools (F12)
2. ✅ Busca errores en la consola
3. ✅ Verifica que `collection-view.js` esté cargado
4. ✅ Limpia el caché del navegador

### La vista no persiste entre sesiones
1. ✅ Verifica que localStorage esté habilitado en el navegador
2. ✅ No estés en modo incógnito (desactiva localStorage)
3. ✅ Intenta en navegador privado

---

## 🎓 Entender la Estructura

```
Tu Tienda Shopify
├── Colecciones
│   ├── All Products
│   ├── Men's Collection
│   ├── Women's Collection
│   └── ... (cada una usa collection.json o variante)
│
├── Template: collection.json
│   └── Contiene secciones (Main Collection, Banners, etc.)
│
└── Sección: main-collection.liquid
    ├── JavaScript: collection-view.js
    ├── CSS: section-collection.css
    └── Settings (incluyendo enable_view_toggle)
```

**Cuando habilitaste `enable_view_toggle`:**
- Se muestra el componente `<collection-view>`
- Se carga el script `collection-view.js`
- Se aplican los estilos de `.section-collection.css`
- Los usuarios pueden cambiar entre 3 vistas

---

## 🌍 Múltiples Colecciones

**Buena noticia**: Una vez habilitado en una colección, se hereda a todas.

Por ejemplo:
1. Habilita en "Main Collection" de `collection.json`
2. Todas las colecciones lo usarán automáticamente
3. A menos que tengan un template personalizado

Si tienes archivos como:
- `collection.mens-collection.json`
- `collection.womens-collection.json`

Necesitarías habilitar el toggle en cada uno.

---

## 💡 Tips Útiles

### Cambiar Vista Por Defecto
Si quieres que la vista "Editorial" sea el default:
1. Edita `sections/main-collection.liquid`
2. Busca los botones de vista
3. Cambia `aria-pressed="true"` a otro botón:

```liquid
<!-- Cambiar de este -->
<button data-view="double" aria-pressed="true"> ... </button>

<!-- A este -->
<button data-view="editorial" aria-pressed="true"> ... </button>
```

### Deshabilitar el Toggle Globalmente
Si lo quieres desactivar:
1. En `main-collection.liquid`, cambia:
   ```liquid
   "default": true  →  "default": false
   ```
2. O simplemente no marques el checkbox

### Personalizar los Iconos
Los iconos están en SVG dentro de los botones. Puedes editarlos en:
- `sections/main-collection.liquid` - Busca los `<svg>` tags

---

## 📞 Próximos Pasos

Una vez que veas el toggle funcionando:
1. ✅ Prueba cambiar entre las 3 vistas
2. ✅ Verifica que las vistas sean responsivas en mobile
3. ✅ Personaliza los estilos si es necesario
4. ✅ Traduce los labels si tienes múltiples idiomas
5. ✅ Publica en vivo

¡Listo! 🚀
