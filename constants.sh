#!/bin/bash

# constants.sh - Constantes y configuración para sf
# Versión: 1.0
# Autor: Asistente de desarrollo

# ============================================================================
# CONFIGURACIÓN GLOBAL
# ============================================================================

# Archivos y rutas
readonly SF_HISTORY_FILE=".sf_history"
readonly SF_ENV_FILE=".env"

# Rama principal por defecto
readonly DEFAULT_MAIN_BRANCH="master"

# ============================================================================
# CÓDIGOS DE COLOR ANSI
# ============================================================================

# Colores básicos
readonly COLOR_RED="1;31"
readonly COLOR_GREEN="1;32"
readonly COLOR_YELLOW="1;33"
readonly COLOR_BLUE="1;34"
readonly COLOR_MAGENTA="1;35"
readonly COLOR_CYAN="1;36"
readonly COLOR_WHITE="1;37"

# Colores brillantes
readonly COLOR_BRIGHT_RED="1;91"
readonly COLOR_BRIGHT_GREEN="1;92"
readonly COLOR_BRIGHT_YELLOW="1;93"
readonly COLOR_BRIGHT_BLUE="1;94"

# Reset de color
readonly COLOR_RESET="0"

# ============================================================================
# SÍMBOLOS Y EMOJIS PARA UI
# ============================================================================

# Estados
readonly SYMBOL_SUCCESS="✅"
readonly SYMBOL_ERROR="❌"
readonly SYMBOL_WARNING="⚠️"
readonly SYMBOL_INFO="ℹ️"
readonly SYMBOL_QUESTION="❓"
readonly SYMBOL_ROCKET="🚀"
readonly SYMBOL_GEAR="⚙️"
readonly SYMBOL_BOOK="📖"
readonly SYMBOL_CHECK="✅"
readonly SYMBOL_CROSS="❌"
readonly SYMBOL_STAR="⭐"
readonly SYMBOL_BRANCH="🌿"
readonly SYMBOL_COMMIT="📝"
readonly SYMBOL_PUSH="⬆️"
readonly SYMBOL_PULL="⬇️"
readonly SYMBOL_MERGE="🔀"
readonly SYMBOL_CLEAN="🧹"
readonly SYMBOL_BACKUP="💾"
readonly SYMBOL_SYNC="🔄"
readonly SYMBOL_LOCK="🔒"
readonly SYMBOL_UNLOCK="🔓"

# ============================================================================
# PATRONES REGEX
# ============================================================================

# Validación de tienda Shopify
readonly REGEX_SHOPIFY_STORE='\.myshopify\.com$'

# Validación de Theme ID (solo números)
readonly REGEX_THEME_ID='^[0-9]+$'

# Validación de nombre de rama kebab-case
readonly REGEX_BRANCH_NAME='^[a-z0-9-]+(-[a-z0-9-]+)*$'

# Validación de conventional commits
readonly REGEX_CONVENTIONAL_COMMIT='^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\([a-zA-Z0-9_-]+\))?: .+'

# ============================================================================
# FORMATOS DE FECHA Y HORA
# ============================================================================

# Formato para logs
readonly DATE_FORMAT_LOG='%Y-%m-%d %H:%M:%S'

# Formato para nombres de rama
readonly DATE_FORMAT_BRANCH='%Y%m%d'

# Formato para backups
readonly DATE_FORMAT_BACKUP='%Y%m%d-%H%M%S'

# ============================================================================
# CONFIGURACIÓN DE SERVIDOR DE DESARROLLO
# ============================================================================

# Puerto por defecto para desarrollo
readonly DEFAULT_DEV_PORT="9292"

# Host por defecto para desarrollo
readonly DEFAULT_DEV_HOST="127.0.0.1"

# ============================================================================
# LÍMITES Y UMBRALES
# ============================================================================

# Longitud mínima de mensaje de commit
readonly MIN_COMMIT_MESSAGE_LENGTH=10

# Número máximo de commits sin publicar para warning
readonly MAX_UNPUBLISHED_COMMITS=5

# Número máximo de resultados a mostrar en logs
readonly MAX_LOG_RESULTS=20

# ============================================================================
# MENSAJES DE ERROR PREDEFINIDOS
# ============================================================================

# Errores de validación
readonly ERROR_ENV_NOT_CONFIGURED="Variables de entorno no configuradas"
readonly ERROR_INVALID_SHOPIFY_STORE="SHOPIFY_STORE no parece una URL de Shopify válida"
readonly ERROR_INVALID_THEME_ID="SHOPIFY_THEME_ID debe ser un número"
readonly ERROR_NOT_GIT_REPO="No estás en un repositorio Git"
readonly ERROR_NOT_IN_FEATURE_BRANCH="No puedes hacer commit en la rama master"
readonly ERROR_UNCOMMITTED_CHANGES="Hay cambios sin confirmar"
readonly ERROR_INVALID_BRANCH_NAME="Nombre debe estar en kebab-case"
readonly ERROR_COMMIT_MESSAGE_TOO_SHORT="El mensaje es muy corto"
readonly ERROR_UNKNOWN_COMMAND="Comando desconocido"

# Errores de operaciones
readonly ERROR_GIT_CHECKOUT_FAILED="No se pudo cambiar de rama"
readonly ERROR_GIT_MERGE_FAILED="Conflicto en merge"
readonly ERROR_GIT_PUSH_FAILED="Falló git push"
readonly ERROR_SHOPIFY_PULL_FAILED="Falló shopify theme pull"
readonly ERROR_SHOPIFY_PUSH_FAILED="Falló shopify theme push"

# ============================================================================
# MENSAJES DE ÉXITO PREDEFINIDOS
# ============================================================================

readonly SUCCESS_BRANCH_CREATED="Rama creada exitosamente"
readonly SUCCESS_COMMIT_CREATED="Commit realizado exitosamente"
readonly SUCCESS_PUBLISH_COMPLETED="Publicación completada exitosamente"
readonly SUCCESS_SYNC_COMPLETED="Sincronización completada"
readonly SUCCESS_BACKUP_CREATED="Backup creado exitosamente"
readonly SUCCESS_CLEAN_COMPLETED="Limpieza completada"

# ============================================================================
# MENSAJES DE ADVERTENCIA PREDEFINIDOS
# ============================================================================

readonly WARNING_UNCOMMITTED_CHANGES="Hay cambios sin commit"
readonly WARNING_MANY_UNPUBLISHED_COMMITS="Tienes muchos commits sin publicar"
readonly WARNING_POTENTIAL_CONFLICTS="Posibles conflictos detectados"
readonly WARNING_BRANCH_NOT_MERGED="Rama NO fusionada en master"

# ============================================================================
# MENSAJES INFORMATIVOS PREDEFINIDOS
# ============================================================================

readonly INFO_CHECKING_DEPENDENCIES="Verificando dependencias"
readonly INFO_LOADING_ENV="Cargando variables de entorno"
readonly INFO_VALIDATING_ENV="Validando configuración"
readonly INFO_DETECTING_STATE="Detectando estado del proyecto"
readonly INFO_SYNCING_CHANGES="Sincronizando cambios"
readonly INFO_CREATING_BACKUP="Creando backup automático"

# ============================================================================
# TIPOS DE FLUJO DE TRABAJO
# ============================================================================

# Array de tipos de flujo disponibles
readonly WORKFLOW_TYPES=(
    "fix:Corrección de errores"
    "feat:Nueva funcionalidad"
    "hotfix:Corrección urgente en producción"
    "refactor:Refactorización de código"
    "docs:Cambios en documentación"
    "style:Cambios de estilo/formato"
    "test:Cambios en tests"
    "chore:Tareas de mantenimiento"
)

# ============================================================================
# DEPENDENCIAS REQUERIDAS
# ============================================================================

# Array de dependencias requeridas
readonly REQUIRED_DEPENDENCIES=(
    "git:Git:https://git-scm.com/downloads"
    "shopify:Shopify CLI:https://shopify.dev/themes/tools/cli"
)

# ============================================================================
# CONFIGURACIÓN DE GITIGNORE
# ============================================================================

# Contenido por defecto para .gitignore
readonly DEFAULT_GITIGNORE="# sf
.env
.sf_history

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Logs
*.log
"

# ============================================================================
# CONFIGURACIÓN DE .ENV
# ============================================================================

# Contenido por defecto para .env
readonly DEFAULT_ENV_FILE="# Variables de entorno para el proyecto
# Configuración de Shopify
SHOPIFY_STORE=\"tu-tienda.myshopify.com\"
SHOPIFY_THEME_ID=\"123456789\"
"

# ============================================================================
# VALIDACIÓN DE CONSTANTES
# ============================================================================

# Función para validar que todas las constantes críticas estén definidas
validate_constants() {
    local required_constants=(
        "SF_HISTORY_FILE"
        "SF_ENV_FILE"
        "DEFAULT_MAIN_BRANCH"
        "COLOR_RED"
        "COLOR_GREEN"
        "COLOR_RESET"
        "REGEX_SHOPIFY_STORE"
        "REGEX_THEME_ID"
        "DATE_FORMAT_LOG"
        "MIN_COMMIT_MESSAGE_LENGTH"
    )

    for constant in "${required_constants[@]}"; do
        if [[ -z "${!constant}" ]]; then
            echo "ERROR: Constante crítica no definida: $constant" >&2
            return 1
        fi
    done

    return 0
}

# Auto-validación al cargar
validate_constants || {
    echo "ERROR: Falló validación de constantes en constants.sh" >&2
    exit 1
}