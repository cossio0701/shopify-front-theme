# sf - Shopify Flow CLI

Un CLI en Bash para gestionar flujos de trabajo entre Git y Shopify Admin, evitando conflictos y facilitando la sincronización.

## 🚀 Instalación Rápida

```bash
# 1. Clona o descarga el script sf
chmod +x sf

# 2. Crea archivo de configuración
echo 'SHOPIFY_STORE="tu-tienda.myshopify.com"' > .env
echo 'SHOPIFY_THEME_ID="123456789"' >> .env

# 3. Configura alias global (opcional)
echo 'alias sf="/ruta/absoluta/al/proyecto/sf"' >> ~/.bashrc
source ~/.bashrc

# 4. Inicializa el proyecto
sf init
```

## 🎯 Flujo de Desarrollo Principal

### 📋 Resumen del Flujo

El flujo de desarrollo sigue un ciclo claro: **preparar** → **desarrollar** → **publicar** → **limpiar**. Cada paso está diseñado para evitar conflictos entre Git y Shopify Admin.

```text
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Config    │ -> │  Sincroniza │ -> │   Crea Rama │ -> │   Desarrolla │ -> │   Publica   │
│   (init)    │    │    (sync)   │    │   (start)   │    │   (commit)   │    │  (publish)  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                                 │
                                                                                 v
                                                                    ┌─────────────┐
                                                                    │   Limpia    │
                                                                    │  (finish)   │
                                                                    └─────────────┘
```

### 1. `sf init` - Configuración Inicial

**¿Qué hace?** Prepara el proyecto para usar sf, creando archivos de configuración y verificando dependencias.

**Cuándo usarlo:** Una sola vez por proyecto, antes de empezar a trabajar.

```bash
sf init
# ✅ Crea .env si no existe
# ✅ Valida dependencias (Git, Shopify CLI)
# ✅ Configura hooks de Git si es necesario

# Reinicializar proyecto completamente
sf init --force
# ✅ Fuerza reinicialización sin confirmación
# ✅ Reconfigura todos los componentes
```

**Opciones disponibles:**

- `--force`: Reinicializa el proyecto completamente sin pedir confirmación

### 2. `sf sync` - Sincronizar con Shopify Admin

**¿Qué hace?** Trae cambios realizados manualmente en Shopify Admin a tu rama local.

**Cuándo usarlo:** Antes de empezar a trabajar, o cuando sabes que hubo cambios en el Admin.

```bash
sf sync                      # Sincroniza normalmente
sf sync --dry-run           # Simula para ver qué cambiaría
sf sync --force             # Confirma automáticamente commits
```

### 3. `sf start` - Iniciar Desarrollo

**¿Qué hace?** Crea una nueva rama de trabajo basada en el tipo de cambio y sincroniza con Shopify.

**Cuándo usarlo:** Al comenzar una nueva tarea de desarrollo.

```bash
sf start
# Muestra menú interactivo:
# Selecciona el tipo de flujo (usa ↑↓ flechas, Enter para seleccionar):
#   fix:Corrección de errores          ← (cursor aquí)
#   feat:Nueva funcionalidad
#   hotfix:Corrección urgente en producción
#   refactor:Refactorización de código
#   docs:Cambios en documentación
#   style:Cambios de estilo/formato
#   test:Cambios en tests
#   chore:Tareas de mantenimiento
#
# Presiona Enter para seleccionar
# Ingresa nombre descriptivo en kebab-case
# Resultado: rama tipo/nombre-AAAAMMDD
```

### 4. `sf commit` - Confirmar Cambios

**¿Qué hace?** Guarda tus cambios locales en la rama actual con un mensaje descriptivo siguiendo el formato Conventional Commits.

**Cuándo usarlo:** Después de hacer cambios en el código y antes de publicar.

```bash
sf commit
# ✅ Valida formato Conventional Commits (tipo: descripción)
# ✅ Sugiere tipo de commit basado en archivos modificados
# ✅ Muestra ejemplos si el formato es incorrecto
# ✅ Valida que hay cambios para commitear
# ✅ Crea commit con mensaje proporcionado
```

**Formatos de commit recomendados:**

- `feat: agregar nueva funcionalidad de login`
- `fix: corregir error en validación de email`
- `docs: actualizar documentación de instalación`
- `style: formatear código con prettier`
- `refactor: renombrar variables para mayor claridad`
- `test: agregar pruebas para componente header`
- `chore: actualizar dependencias`

**Características inteligentes:**

- **Validación automática:** Verifica que el mensaje siga el formato `tipo: descripción`
- **Sugerencias inteligentes:** Propone el tipo de commit basado en los archivos modificados
- **Ejemplos interactivos:** Muestra ejemplos de formatos válidos cuando es necesario
- **Flexibilidad:** Permite continuar con mensajes no convencionales si se confirma

### 5. `sf publish` - Publicar Cambios

**¿Qué hace?** Fusiona tu rama a master y publica los cambios en Shopify Admin.

**Cuándo usarlo:** Cuando tus cambios están listos para producción.

```bash
sf publish                    # Publica normalmente
sf publish --dry-run         # Simula publicación (recomendado primero)
sf publish --force           # Omite validaciones de seguridad
```

### 6. `sf finish` - Finalizar Trabajo

**¿Qué hace?** Elimina la rama de trabajo después de confirmar que todo está bien.

**Cuándo usarlo:** Después de publicar exitosamente y verificar que todo funciona.

```bash
sf finish
# Confirma eliminación de la rama
# ✅ Elimina rama local si fue fusionada
# ✅ Vuelve a rama master
```

## 🔄 Flujos Alternativos

### Continuar Trabajo en Rama Existente

Si ya tienes una rama de trabajo y quieres continuar desarrollando:

```bash
# Verifica en qué rama estás
sf status

# Si no estás en tu rama, cámbiate a ella
git checkout feat/mi-rama-20230925

# Continúa trabajando normalmente
sf commit  # Cuando tengas cambios
sf publish # Cuando esté listo
```

### Resolver Conflictos de Merge

Si `sf publish` falla por conflictos:

```bash
# 1. Revisa qué archivos tienen conflictos
git status

# 2. Edita los archivos y resuelve conflictos manualmente
# (busca las marcas <<<<<<<, =======, >>>>>>>)

# 3. Agrega los archivos resueltos
git add archivo-conflicto.js

# 4. Continúa con el publish
sf publish --force  # O usa --dry-run primero
```

### Cambios Urgentes (Hotfix)

Para correcciones críticas que necesitan ir directo a producción:

```bash
# Crea rama de hotfix
sf start
# Selecciona "hotfix" en el menú

# Haz tus cambios urgentes
sf commit
sf publish  # Esto irá directo a master sin validaciones extra
```

### Sincronizar Cambios del Admin

Cuando sabes que hubo cambios manuales en Shopify Admin:

```bash
# Antes de empezar nuevo trabajo
sf sync --dry-run  # Ve qué cambiaría
sf sync            # Trae los cambios

# Si hay conflictos, resuélvelos y continua
sf start           # Crea nueva rama desde el estado actualizado
```

### Recuperarse de un Error

Si algo salió mal durante el proceso:

```bash
# Ver historial de acciones
sf log --today

# Crear backup de trabajo actual
sf backup create

# Revisar diferencias
sf diff --with-master

# Restaurar si es necesario
sf backup restore nombre-del-backup
```

## 🛠️ Comandos Auxiliares

### `sf status` - Estado Inteligente del Proyecto

**¿Cuándo usarlo?** En cualquier momento para obtener un análisis completo del estado del proyecto y recibir sugerencias inteligentes sobre próximos pasos.

```bash
sf status
# ✅ Rama actual del proyecto
# ✅ Conteo de cambios preparados y sin preparar
# ✅ Archivos no rastreados por Git
# ✅ Commits pendientes por publicar
# ✅ Estado general del repositorio (limpio o con cambios)
# ✅ Información de conexión con Shopify Admin
```

**Información mostrada:**

- **🌿 Rama actual:** En qué rama estás trabajando
- **📝 Cambios preparados:** Archivos agregados al staging area
- **✏️ Cambios sin preparar:** Modificaciones no confirmadas
- **📄 Archivos no rastreados:** Nuevos archivos no agregados a Git
- **⬆️ Commits por publicar:** Cantidad de commits locales no enviados al remoto
- **✅ Estado general:** Indicador de si el repositorio está limpio

### `sf stash` - Guardar Cambios Temporales

**¿Cuándo usarlo?** Cuando necesitas cambiar de rama pero tienes cambios sin commitear.

```bash
sf stash
# Ingresa mensaje descriptivo para recordar qué guardaste
# ✅ Guarda cambios locales temporalmente
```

## 🔧 Comandos de Mantenimiento

### `sf log` - Historial de Acciones

**¿Cuándo usarlo?** Para debugging, seguimiento de cambios, o recordar qué hiciste.

```bash
sf log --today              # Ver qué hiciste hoy
sf log --last 10           # Últimas 10 acciones
sf log --this-week         # Toda la semana
```

### `sf diff` - Comparar Diferencias

**¿Cuándo usarlo?** Antes de publicar para verificar cambios, o para comparar ramas.

```bash
sf diff --with-master      # Ver qué cambiará al publicar
sf diff --with-shopify     # Simular vs Shopify Admin
```

### `sf clean` - Limpiar Ramas

**¿Cuándo usarlo?** Periódicamente para mantener el repositorio ordenado.

```bash
sf clean --merged          # Eliminar ramas ya en master
sf clean --older-than 30   # Ramas con más de 30 días
```

### `sf backup` - Copias de Seguridad

**¿Cuándo usarlo?** Antes de operaciones riesgosas o para guardar estados importantes.

```bash
sf backup create           # Backup rápido en stash
sf backup branch           # Backup en rama separada
```

### `sf pr` - Pull Requests e Issues

**¿Cuándo usarlo?** Para crear PR después de publicar, o para documentar issues.

```bash
sf pr                      # Crear PR con template
sf pr --title "Mi cambio"  # PR personalizado
```

## 📋 Requisitos

- **Bash** (shell compatible)
- **Git** (control de versiones)
- **Shopify CLI** (interacción con tienda)
- **GitHub CLI** (opcional, para sf pr)

## ⚙️ Configuración

### Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto:

```bash
SHOPIFY_STORE="tu-tienda.myshopify.com"
SHOPIFY_THEME_ID="123456789"
```

### Configuración Automática de Git

El script sf configura automáticamente el archivo `.gitignore` para excluir archivos que no deben versionarse:

```bash
# Archivos excluidos automáticamente:
.sf_history        # Historial de comandos del script sf
.env              # Variables de entorno sensibles
.shopify/         # Archivos temporales de Shopify CLI
```

**Nota:** El archivo `.sf_history` contiene el historial de comandos ejecutados y se mantiene localmente pero se excluye del repositorio Git.

### Alias Global (Recomendado)

Para ejecutar `sf` desde cualquier directorio:

```bash
# Agrega a ~/.bashrc o ~/.zshrc
alias sf="/ruta/absoluta/al/proyecto/sf"
source ~/.bashrc
```

## 🔄 Flujo de Trabajo Completo

### Ciclo de Desarrollo Típico

```bash
# 🏗️ Configuración inicial (una sola vez por proyecto)
sf init

# 🔄 Sincronización (recomendado antes de empezar)
sf sync --dry-run  # Verificar si hay cambios en Admin
sf sync            # Traer cambios si los hay

# 🚀 Desarrollo
sf start           # Crear rama de feature
# ... hacer cambios en el código ...
sf commit          # Confirmar cambios locales

# ✅ Publicación
sf publish --dry-run  # Simular publicación (siempre recomendado)
sf publish         # Publicar a producción

# 🧹 Limpieza
sf finish          # Eliminar rama de trabajo

# 🔄 Siguiente ciclo
# Repite desde sf sync/sf start para el siguiente feature
```

### Flujo con Mantenimiento

```bash
# Verificación diaria
sf status          # Ver estado del proyecto
sf log --today     # Ver qué hiciste hoy

# Limpieza semanal
sf clean --merged  # Limpiar ramas viejas
sf backup list     # Revisar backups antiguos

# Resolución de problemas
sf diff --with-master  # Ver diferencias antes de publicar
sf backup create    # Crear backup antes de operaciones riesgosas
```

### Flujo para Equipos

```bash
# Al unirte a un proyecto existente
sf init            # Configurar entorno
sf sync            # Traer estado actual
sf status          # Verificar rama actual

# Durante desarrollo colaborativo
sf log --this-week # Ver actividad del equipo
sf diff --branches master feat/otra-rama  # Comparar con compañeros
```

## 🆘 Solución de Problemas

### Error: "Debes configurar las variables de entorno"

- Verifica que el archivo `.env` existe y tiene los valores correctos
- Asegúrate de que las variables no estén vacías
- El script valida automáticamente el formato de las URLs de Shopify

### Error: "Dependencias faltantes"

```bash
# Instalar Git
sudo apt-get install git  # Ubuntu/Debian
brew install git           # macOS

# Instalar Shopify CLI
npm install -g @shopify/cli
# o
brew install shopify-cli   # macOS
```

### Error: "Conflicto en merge"

- Resuelve conflictos manualmente en los archivos
- Ejecuta `git add .` y `git commit -m "Resolve conflicts"`
- Luego continúa con `sf publish`

### Mensajes de Validación Mejorados

El script ahora proporciona mensajes específicos con soluciones:

- **"Archivo .env no encontrado"** → Crea el archivo con `sf init`
- **"Rama master no está limpia"** → Confirma o guarda cambios antes de continuar
- **"Shopify CLI no disponible"** → Instala dependencias faltantes
- **"Cambios sin commitear detectados"** → Usa `sf commit` o `sf stash` según corresponda

## 📝 Notas para el Equipo

- Cada desarrollador debe configurar su propio alias apuntando a la ruta local del proyecto
- El archivo `.env` puede compartirse o ignorarse según políticas de seguridad
- Usa `sf log` para debugging y seguimiento de cambios
- Los comandos con `--dry-run` son seguros para probar operaciones

## 💡 Consejos para Mejor UX

### 🚀 Acelera tu flujo de desarrollo

- **Usa `sf status`** para obtener análisis inteligente del proyecto y sugerencias contextuales
- **Usa `sf sync --dry-run`** antes de `sf sync` para ver qué cambiará
- **Siempre usa `sf publish --dry-run`** antes de publicar para evitar sorpresas
- **Configura el alias global** para ejecutar `sf` desde cualquier directorio

### 🔍 Debugging y seguimiento

- **Revisa `sf log --today`** al empezar el día para recordar dónde dejaste el trabajo
- **Usa `sf status`** frecuentemente para mantenerte orientado y recibir validaciones preventivas
- **Crea backups** con `sf backup create` antes de operaciones riesgosas

### 🛡️ Validaciones y Seguridad

- **Validaciones automáticas:** El script detecta problemas comunes antes de que ocurran
- **Mensajes contextuales:** Errores específicos con soluciones sugeridas
- **Prevención de conflictos:** Alertas tempranas sobre posibles problemas de sincronización
- **Verificación de dependencias:** Confirma que todas las herramientas necesarias están disponibles

### 🛡️ Trabajo seguro

- **Sincroniza siempre** con `sf sync` antes de empezar nuevo trabajo
- **Verifica diferencias** con `sf diff --with-master` antes de publicar
- **Trabaja en ramas separadas** - nunca hagas cambios directamente en master

### 👥 Trabajo en equipo

- **Comunica tus cambios** usando `sf pr` para crear Pull Requests
- **Revisa el historial** con `sf log --this-week` para entender el progreso del equipo
- **Limpia regularmente** con `sf clean --merged` para mantener el repositorio ordenado

### ⚡ Atajos útiles

```bash
# Ver estado inteligente y sugerencias
sf status          # Análisis completo + sugerencias de próximos pasos

# Ver todo de una vez (estado + historial reciente)
sf status && sf log --last 5

# Flujo express (para cambios simples)
sf start && sf commit && sf publish --dry-run && sf publish && sf finish

# Verificar antes de publicar (con validaciones inteligentes)
sf diff --with-master && sf publish --dry-run
```

## 🤝 Contribución

Si encuentras errores o mejoras, edita el script `sf` directamente o crea un issue/PR.
