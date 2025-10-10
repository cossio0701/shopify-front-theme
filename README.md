# sf - Shopify Flow CLI v1.0

Un CLI en Bash para gestionar flujos de trabajo entre Git y Shopify Admin, evitando conflictos y facilitando la sincronización.

## 🚀 Flujo Principal de Desarrollo

Para realizar un cambio y publicarlo rápidamente (después de la configuración inicial):

1. **Sincroniza antes de trabajar**: `sf sync`
2. **Inicia desarrollo**: `sf start` (crea rama)
3. **Desarrolla tus cambios** en el código
4. **Prueba localmente**: `sf dev`
5. **Confirma cambios**: `sf commit`
6. **Fusiona rama a master**: `sf merge --dry-run` (simula merge)
7. **Fusiona rama**: `sf merge` (fusiona y sincroniza con Shopify)
8. **Prueba la fusión**: `sf dev --test` (verifica que todo funcione)
9. **Publica en Shopify**: `sf publish`
10. **Limpia**: `sf finish`

**Diagrama del flujo:**

```text
Sync → Start → Develop → Test → Commit → Merge → Test Merge → Publish → Finish
   ↑                                                                        ↓
   └─────────────────────── Repite para siguiente cambio ───────────────────┘
```

## 🧠 Características Inteligentes

El script sf incluye validaciones preventivas y sugerencias inteligentes para evitar errores comunes:

- **🔍 Validaciones preventivas:** Detecta problemas antes de que ocurran (repositorio no inicializado, conexiones faltantes)
- **💡 Sugerencias contextuales:** Recomienda próximos pasos basados en el estado actual del proyecto
- **⚠️ Detección de conflictos:** Identifica posibles conflictos antes de operaciones críticas
- **💾 Backups automáticos:** Crea respaldos antes de operaciones riesgosas
- **📊 Análisis de estado:** Proporciona información completa del estado del proyecto y rama actual

Cada comando incluye mensajes específicos con soluciones cuando algo sale mal.

### Configuración Inicial (una sola vez por proyecto)

Antes de comenzar a desarrollar, configura el proyecto una vez:

- **Instala dependencias**: Asegúrate de tener Git y Shopify CLI instalados.

## 📦 Instalación Rápida

```bash
# 1. Da permisos de ejecución al script sf
chmod +x sf

# 2. Configura alias global para ejecutar sf desde cualquier directorio
echo 'alias sf="/ruta/absoluta/al/proyecto/sf"' >> ~/.bashrc
source ~/.bashrc

# 3. Inicializa el proyecto (esto genera el archivo .env)
sf init

# 4. Configura las variables de entorno en el archivo .env generado
# Edita .env y establece:
# SHOPIFY_STORE="tu-tienda.myshopify.com"
# SHOPIFY_THEME_ID="123456789"
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

### 5. `sf merge` - Fusionar Cambios a Master

**¿Qué hace?** Fusiona la rama de trabajo actual a la rama master y sincroniza con Shopify Admin.

**Cuándo usarlo:** Cuando tus cambios están listos para ser integrados a la rama principal.

```bash
sf merge                      # Fusionar normalmente
sf merge --dry-run           # Simula fusión para ver qué cambiaría
sf merge --force             # Omite algunas validaciones de seguridad
```

**¿Qué hace exactamente?**

- ✅ Fusiona la rama actual a master
- ✅ Sincroniza cambios desde Shopify Admin
- ✅ Crea backup automático antes de la operación
- ✅ Detecta conflictos potenciales
- ✅ Sugiere próximos pasos después del merge

**Validaciones inteligentes:**

- **Prevención de conflictos:** Verifica conflictos antes de fusionar
- **Backup automático:** Guarda estado actual en caso de problemas
- **Sincronización:** Trae cambios de Shopify Admin después del merge
- **Sugerencias:** Recomienda probar cambios o publicar directamente

### 6. `sf publish` - Publicar Cambios

**¿Qué hace?** Publica los cambios desde la rama master a Shopify Admin (debes estar en master).

**Cuándo usarlo:** Después de fusionar cambios a master y verificar que todo funciona.

```bash
sf publish                    # Publica normalmente
sf publish --dry-run         # Simula publicación (recomendado primero)
sf publish --force           # Omite validaciones de seguridad
```

**¿Qué hace exactamente?**

- ✅ Sincroniza con Shopify Admin antes de publicar
- ✅ Publica tema en Shopify usando shopify theme push
- ✅ Sube cambios a repositorio remoto (git push)
- ✅ Valida que estés en la rama master

**Importante:** Debes estar en la rama master para publicar. Usa `sf merge` primero si estás en una rama de trabajo.

### 7. `sf resolve` - Resolver Conflictos

**¿Qué hace?** Confirma cambios resueltos después de un conflicto (solo confirma en Git, no publica a Shopify).

**Cuándo usarlo:** Después de resolver conflictos manualmente en los archivos.

```bash
sf resolve
# ✅ Agrega todos los archivos resueltos
# ✅ Confirma con mensaje "resolve: conflictos de merge"
# ✅ Sube cambios a repositorio remoto
# ✅ NO publica automáticamente a Shopify
```

**Flujo típico de resolución:**

1. Un comando como `sf sync` o `sf merge` detecta conflictos
2. Resuelve conflictos manualmente editando los archivos
3. Ejecuta `git add <archivos>` para marcar como resueltos
4. Usa `sf resolve` para confirmar automáticamente
5. **Prueba los cambios:** `sf dev --test`
6. **Publica manualmente:** `sf publish` cuando estés seguro

### 8. `sf finish` - Finalizar Trabajo

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

Si `sf merge` o `sf sync` falla por conflictos:

```bash
# 1. Revisa qué archivos tienen conflictos
git status

# 2. Edita los archivos y resuelve conflictos manualmente
# (busca las marcas <<<<<<<, =======, >>>>>>>)

# 3. Agrega los archivos resueltos
git add archivo-conflicto.js

# 4. Confirma automáticamente (sin publicar a Shopify)
sf resolve

# 5. Prueba los cambios antes de publicar
sf dev --test

# 6. Publica a Shopify cuando estés seguro
sf publish
```

### Cambios Urgentes (Hotfix)

Para correcciones críticas que necesitan ir directo a producción:

```bash
# Crea rama de hotfix
sf start
# Selecciona "hotfix" en el menú

# Haz tus cambios urgentes
sf commit

# Para hotfix, puedes omitir algunas validaciones si es necesario
sf merge --force     # Fusiona a master (omite algunas validaciones)
sf publish           # Publica inmediatamente
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

### `sf dev` - Servidor de Desarrollo Local

**¿Cuándo usarlo?** Para desarrollar y probar cambios localmente antes de publicar.

```bash
sf dev
# ✅ Inicia servidor de desarrollo con shopify theme dev
# ✅ Usa configuración por defecto (tema de desarrollo)
# ✅ Recarga automática al guardar cambios
# ✅ Acceso local en http://127.0.0.1:9292
# ✅ Verificación de procesos existentes
```

**Características:**

- **🔄 Recarga automática:** Los cambios se reflejan inmediatamente
- **🌐 Acceso local:** Servidor disponible en puerto configurable
- **🛡️ Verificación:** Detecta si ya hay un servidor corriendo
- **⚙️ Configurable:** Puerto, host y opciones personalizables
- **🎯 Tema de Desarrollo:** Ambiente seguro para probar cambios antes de publicar

```bash
# Modo de pruebas (informativo)
sf dev --test

# Opciones personalizadas
sf dev --port 3000 --host 0.0.0.0
```

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

# 🔀 Fusión a master
sf merge --dry-run # Simular fusión (siempre recomendado)
sf merge           # Fusionar rama a master

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
