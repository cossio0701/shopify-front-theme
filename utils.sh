#!/bin/bash

# utils.sh - Funciones utilitarias para sf
# Versión: 1.0
# Autor: Asistente de desarrollo

# Nota: Las constantes se importan desde sf para evitar duplicaciones

# ============================================================================
# FUNCIONES DE CARGA Y CONFIGURACIÓN
# ============================================================================

# Función para cargar variables de entorno desde .env
# Uso: load_env
# Retorna: 0 si se cargó correctamente, 1 si hay error
load_env() {
    local env_file="$SF_ENV_FILE"

    if [[ -f "$env_file" ]]; then
        if source "$env_file" 2>/dev/null; then
            log_debug "$INFO_LOADING_ENV desde $env_file"
            return 0
        else
            log_error "Error al cargar $env_file"
            return 1
        fi
    else
        log_debug "Archivo $env_file no encontrado"
        return 1
    fi
}

# ============================================================================
# FUNCIONES DE LOGGING
# ============================================================================

# Función para registrar acciones en el historial
# Uso: log_history "mensaje"
# Retorna: 0 siempre
log_history() {
    local message="$1"
    local timestamp
    timestamp=$(date "$DATE_FORMAT_LOG")

    echo "[$timestamp] $message" >> "$SF_HISTORY_FILE"
}

# Función para logging de debug (solo si verbose está activado)
# Uso: log_debug "mensaje"
log_debug() {
    local message="$1"
    local verbose="${VERBOSE:-false}"

    if [[ "$verbose" == "true" ]]; then
        echo "[DEBUG] $message" >&2
    fi
}

# Función para logging de información
# Uso: log_info "mensaje"
log_info() {
    local message="$1"
    echo "$SYMBOL_INFO $message"
}

# Función para logging de éxito
# Uso: log_success "mensaje"
log_success() {
    local message="$1"
    echo "$SYMBOL_SUCCESS $message"
}

# Función para logging de advertencia
# Uso: log_warning "mensaje"
log_warning() {
    local message="$1"
    echo "$SYMBOL_WARNING $message"
}

# Función para logging de error
# Uso: log_error "mensaje"
log_error() {
    local message="$1"
    echo "$SYMBOL_ERROR $message" >&2
}

# ============================================================================
# FUNCIONES DE COLORES Y UI
# ============================================================================

# Función para verificar si la terminal soporta colores
# Uso: supports_colors
# Retorna: 0 si soporta colores, 1 si no
supports_colors() {
    # Forzar colores ANSI siempre para consistencia
    return 0
}

# Función para colorear texto si es soportado
# Uso: color_text "codigo_color" "texto"
# Ejemplo: color_text "$COLOR_RED" "Error"
color_text() {
    local color_code="$1"
    local text="$2"

    if supports_colors; then
        echo -e "\033[${color_code}m${text}\033[${COLOR_RESET}m"
    else
        # Si no hay colores, usar símbolos para resaltar
        case "$color_code" in
            "$COLOR_RED"|"$COLOR_BRIGHT_RED") echo "$SYMBOL_ERROR $text" ;;
            "$COLOR_GREEN"|"$COLOR_BRIGHT_GREEN") echo "$SYMBOL_SUCCESS $text" ;;
            "$COLOR_YELLOW"|"$COLOR_BRIGHT_YELLOW") echo "$SYMBOL_WARNING $text" ;;
            "$COLOR_BLUE"|"$COLOR_BRIGHT_BLUE") echo "$SYMBOL_INFO $text" ;;
            *) echo "$text" ;;
        esac
    fi
}

# Función para mostrar texto coloreado directamente
# Uso: print_colored "codigo_color" "texto"
print_colored() {
    local color_code="$1"
    local text="$2"
    echo -e "$(color_text "$color_code" "$text")"
}

# ============================================================================
# FUNCIONES DE CONFIRMACIÓN Y INTERACCIÓN
# ============================================================================

# Función para confirmar acción del usuario
# Uso: confirm_action "mensaje" ["y"|"n"] ["texto_ayuda"]
# Retorna: 0 si confirma, 1 si cancela
confirm_action() {
    local prompt="$1"
    local default="${2:-n}"  # Default a 'n' si no se especifica
    local help_text="$3"

    echo ""
    echo "$SYMBOL_QUESTION $prompt"

    if [[ -n "$help_text" ]]; then
        echo "$help_text"
    fi

    local response
    read -p "¿Continuar? (y/N): " -n 1 -r response
    echo

    if [[ "$default" == "y" ]]; then
        [[ ! "$response" =~ ^[Nn]$ ]]
    else
        [[ "$response" =~ ^[Yy]$ ]]
    fi
}

# Función para menú interactivo con flechas
# Uso: interactive_menu "array_de_opciones"
# Retorna: 0 si selecciona, 1 si cancela
# Establece variable global SELECTED_OPTION
interactive_menu() {
    local -n options_ref="$1"  # Referencia al array pasado
    local selected=0
    local key=""

    # Función para dibujar el menú
    draw_menu() {
        echo -e "\nSelecciona una opción (usa ↑↓ flechas, Enter para seleccionar):"
        for i in "${!options_ref[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo -e "  \e[7m${options_ref[$i]}\e[0m"  # Resaltado inverso
            else
                echo "  ${options_ref[$i]}"
            fi
        done
        echo
    }

    # Ocultar cursor
    echo -e "\e[?25l"

    # Bucle principal
    while true; do
        draw_menu
        read -sn1 key

        case "$key" in
            $'\e')  # Escape sequence
                read -sn2 -t 0.1 key2
                case "$key2" in
                    '[A')  # Flecha arriba
                        ((selected--))
                        if [[ $selected -lt 0 ]]; then
                            selected=$((${#options_ref[@]} - 1))
                        fi
                        ;;
                    '[B')  # Flecha abajo
                        ((selected++))
                        if [[ $selected -ge ${#options_ref[@]} ]]; then
                            selected=0
                        fi
                        ;;
                esac
                ;;
            '')  # Enter
                break
                ;;
            'q'|'Q')  # Salir con q
                echo -e "\e[?25h"  # Mostrar cursor
                echo "$SYMBOL_CROSS Operación cancelada."
                return 1
                ;;
        esac

        # Limpiar pantalla hacia arriba
        echo -e "\e[${#options_ref[@]}A\e[J"
    done

    # Mostrar cursor
    echo -e "\e[?25h"

    # Establecer variable global con la selección
    SELECTED_OPTION="${options_ref[$selected]}"
    SELECTED_INDEX="$selected"

    echo "$SYMBOL_CHECK Seleccionado: $SELECTED_OPTION"
    return 0
}

# ============================================================================
# FUNCIONES DE VALIDACIÓN
# ============================================================================

# Función para validar dependencias
# Uso: validate_dependencies
# Retorna: 0 si todas están presentes, 1 si faltan algunas
validate_dependencies() {
    local missing_deps=()

    for dep_info in "${REQUIRED_DEPENDENCIES[@]}"; do
        IFS=':' read -r command name url <<< "$dep_info"

        if ! command -v "$command" &> /dev/null; then
            missing_deps+=("$name")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "$ERROR_MISSING_DEPENDENCIES"
        printf "  - %s\n" "${missing_deps[@]}" >&2
        echo "" >&2
        echo "Instala las dependencias faltantes:" >&2

        for dep_info in "${REQUIRED_DEPENDENCIES[@]}"; do
            IFS=':' read -r command name url <<< "$dep_info"
            if [[ " ${missing_deps[*]} " == *" $name "* ]]; then
                echo "  - $name: $url" >&2
            fi
        done

        return 1
    fi

    return 0
}

# Función para validar variables de entorno
# Uso: validate_env
# Retorna: 0 si válidas, 1 si inválidas
validate_env() {
    if [[ -z "${SHOPIFY_STORE:-}" || -z "${SHOPIFY_THEME_ID:-}" ]]; then
        log_error "$ERROR_ENV_NOT_CONFIGURED"
        echo "" >&2
        echo "Solución:" >&2
        echo "1. Crea o edita el archivo $SF_ENV_FILE en la raíz del proyecto:" >&2
        echo "   SHOPIFY_STORE=\"tu-tienda.myshopify.com\"" >&2
        echo "   SHOPIFY_THEME_ID=\"123456789\"" >&2
        echo "" >&2
        echo "2. O configura las variables en tu entorno:" >&2
        echo "   export SHOPIFY_STORE=\"tu-tienda.myshopify.com\"" >&2
        echo "   export SHOPIFY_THEME_ID=\"123456789\"" >&2
        echo "" >&2
        echo "Después de configurar, ejecuta el comando nuevamente." >&2
        return 1
    fi

    # Validar formato básico
    if [[ ! "$SHOPIFY_STORE" =~ $REGEX_SHOPIFY_STORE ]]; then
        log_warning "$ERROR_INVALID_SHOPIFY_STORE"
        echo "   Esperado: algo.myshopify.com" >&2
        echo "   Actual: $SHOPIFY_STORE" >&2
    fi

    if [[ ! "$SHOPIFY_THEME_ID" =~ $REGEX_THEME_ID ]]; then
        log_warning "$ERROR_INVALID_THEME_ID"
        echo "   Actual: $SHOPIFY_THEME_ID" >&2
    fi

    return 0
}

# Función para validar formato de conventional commits
# Uso: validate_commit_message "mensaje"
# Retorna: 0 si válido, 1 si inválido
validate_commit_message() {
    local message="$1"

    if [[ $message =~ $REGEX_CONVENTIONAL_COMMIT ]]; then
        return 0  # Válido
    else
        return 1  # Inválido
    fi
}

# ============================================================================
# FUNCIONES DE PARSING
# ============================================================================

# Función para parsear flags globales
# Uso: parse_flags "$@"
# Salida: imprime "dry_run force verbose" separados por espacios
parse_flags() {
    local dry_run=false
    local force=false
    local verbose=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                dry_run=true
                shift
                ;;
            --force)
                force=true
                shift
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    # Devolver los valores parseados
    echo "$dry_run $force $verbose"
}

# ============================================================================
# FUNCIONES DE GIT
# ============================================================================

# Función para obtener rama actual
# Uso: get_current_branch
# Establece variable global CURRENT_BRANCH
get_current_branch() {
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
}

# Función para verificar si hay cambios sin commit
# Uso: check_uncommitted_changes
# Retorna: 0 si no hay cambios, 1 si hay cambios
check_uncommitted_changes() {
    if ! git diff --quiet || ! git diff --staged --quiet; then
        log_error "$ERROR_UNCOMMITTED_CHANGES"
        echo "" >&2
        echo "Archivos modificados:" >&2
        git status --porcelain | head -10 >&2
        echo "" >&2
        echo "Opciones:" >&2
        echo "1. Confirma los cambios: sf commit" >&2
        echo "2. Guarda temporalmente: sf stash" >&2
        echo "3. Descarta cambios: git checkout -- .  (⚠️  PELIGROSO)" >&2
        echo "4. Continua de todas formas: usa --force" >&2
        return 1
    fi

    return 0
}

# ============================================================================
# FUNCIONES DE DETECCIÓN DE ESTADO
# ============================================================================

# Función para detectar el estado del proyecto
# Uso: detect_project_state
detect_project_state() {
    # Obtener rama actual
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "desconocida")

    # Contar cambios
    local staged_changes
    local unstaged_changes
    local untracked_files
    staged_changes=$(git diff --staged --name-only 2>/dev/null | wc -l)
    unstaged_changes=$(git diff --name-only 2>/dev/null | wc -l)
    untracked_files=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l)

    # Commits por publicar
    local commits_ahead
    commits_ahead=$(git rev-list "$DEFAULT_MAIN_BRANCH"..HEAD --count 2>/dev/null || git rev-list HEAD --count 2>/dev/null || echo "0")

    # Mostrar estado
    echo "$SYMBOL_BRANCH Rama actual: $(color_text "$COLOR_BLUE" "$current_branch")"

    if [[ $staged_changes -gt 0 ]]; then
        echo "$SYMBOL_COMMIT Cambios preparados: $staged_changes archivo(s)"
    fi

    if [[ $unstaged_changes -gt 0 ]]; then
        echo "✏️  Cambios sin preparar: $unstaged_changes archivo(s)"
    fi

    if [[ $untracked_files -gt 0 ]]; then
        echo "📄 Archivos no rastreados: $untracked_files archivo(s)"
    fi

    if [[ $commits_ahead -gt 0 ]]; then
        echo "$SYMBOL_PUSH Commits por publicar: $commits_ahead"
    fi

    # Estado general
    if [[ $staged_changes -eq 0 && $unstaged_changes -eq 0 && $untracked_files -eq 0 ]]; then
        echo "$SYMBOL_SUCCESS Repositorio limpio"
    fi
}

# ============================================================================
# FUNCIONES DE SUGERENCIAS
# ============================================================================

# Función para sugerir próximos pasos
# Uso: suggest_next_steps "comando" ["contexto"]
suggest_next_steps() {
    local command="$1"
    local context="${2:-}"

    echo ""
    echo "$SYMBOL_STAR Próximos pasos sugeridos:"

    case "$command" in
        init)
            echo "1. Edita $SF_ENV_FILE con tus credenciales de Shopify"
            echo "2. Reinicia terminal o ejecuta: source ~/.bashrc"
            echo "3. Prueba: sf status"
            ;;
        start)
            echo "1. Realiza tus cambios en el código"
            echo "2. Confirma cambios: sf commit"
            echo "3. Publica cuando esté listo: sf publish --dry-run"
            ;;
        commit)
            echo "1. Verifica cambios: sf diff --with-master"
            echo "2. Publica: sf publish --dry-run (primero)"
            echo "3. Publica: sf publish"
            ;;
        publish)
            echo "1. Verifica que todo funciona en Shopify"
            echo "2. Limpia rama: sf finish"
            echo "3. Inicia nuevo trabajo: sf start"
            ;;
        sync)
            echo "1. Verifica cambios: sf status"
            echo "2. Si hay conflictos, resuélvelos y confirma: sf resolve"
            echo "3. Inicia nuevo trabajo: sf start"
            ;;
        resolve)
            echo "1. Verifica que todo funciona: sf status"
            echo "2. Inicia nuevo trabajo: sf start"
            ;;
        finish)
            echo "1. Verifica que todo está bien: sf status"
            echo "2. Inicia nuevo trabajo: sf start"
            echo "3. O sincroniza si es necesario: sf sync"
            ;;
        *)
            echo "Ejecuta 'sf help' para ver todos los comandos disponibles"
            ;;
    esac
}

# Función para detectar y sugerir correcciones comunes
# Uso: smart_suggestions "comando"
smart_suggestions() {
    local command="$1"

    case "$command" in
        start)
            # Si hay stash, sugerir restaurarlo
            if [[ $(git stash list 2>/dev/null | wc -l) -gt 0 ]]; then
                echo "$SYMBOL_INFO Tienes $(git stash list | wc -l) cambios en stash. Considera restaurarlos: git stash pop"
            fi
            ;;
        commit)
            # Si no hay cambios, sugerir qué hacer
            if git diff --quiet && git diff --staged --quiet; then
                echo "$SYMBOL_INFO No hay cambios para confirmar. Modifica archivos primero."
                return
            fi
            ;;
        publish)
            # Verificar si hay muchos commits sin publicar
            local commits_ahead
            commits_ahead=$(git rev-list "$DEFAULT_MAIN_BRANCH"..HEAD --count 2>/dev/null || echo "0")
            if [[ $commits_ahead -gt $MAX_UNPUBLISHED_COMMITS ]]; then
                echo "$SYMBOL_WARNING Tienes $commits_ahead commits por publicar. Considera hacer commits más pequeños."
            fi
            ;;
    esac
}

# ============================================================================
# FUNCIONES DE VALIDACIONES PREVENTIVAS
# ============================================================================

# Función para validaciones preventivas inteligentes
# Uso: preventive_checks "comando"
# Retorna: 0 si pasa checks, 1 si falla
preventive_checks() {
    local command="$1"

    # Solo ejecutar para comandos que modifican estado
    case "$command" in
        start|commit|publish|finish|resolve)
            # Verificar si estamos en un repo Git
            if [[ ! -d ".git" ]]; then
                log_error "$ERROR_NOT_GIT_REPO"
                echo "$SYMBOL_STAR Ejecuta 'sf init' para inicializar el proyecto."
                return 1
            fi

            # Verificar conexión con remoto
            if ! git ls-remote --exit-code origin >/dev/null 2>&1; then
                log_warning "No se puede conectar con el repositorio remoto."
                echo "   Verifica tu conexión a internet y configuración de Git."
            fi
            ;;
    esac

    return 0
}