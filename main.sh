#!/bin/bash

# main.sh - Función principal y orquestación para sf
# Versión: 1.0
# Autor: Asistente de desarrollo

# Nota: Los módulos (constants.sh, utils.sh, commands.sh) se importan desde sf
# para evitar reimportaciones duplicadas

# ============================================================================
# COMANDO: SF INIT
# ============================================================================

# ============================================================================
# COMANDO: SF INIT
# ============================================================================

# Comando: sf init
# Uso: init_project [--force]
init_project() {
    echo "$SYMBOL_ROCKET Inicializando proyecto sf..."

    # Verificar si se fuerza reinicialización ANTES de cualquier análisis
    if [[ "$1" == "--force" ]]; then
        echo "$SYMBOL_SYNC Forzando reinicialización completa..."
        echo ""
    fi

    # Análisis inteligente del estado actual
    local needs_init=false
    local existing_config=""

    if [[ -f "$SF_ENV_FILE" ]]; then
        existing_config+="$SYMBOL_CHECK $SF_ENV_FILE existe\n"
        source "$SF_ENV_FILE" 2>/dev/null
        if [[ -n "${SHOPIFY_STORE:-}" && -n "${SHOPIFY_THEME_ID:-}" ]]; then
            existing_config+="$SYMBOL_CHECK Variables de entorno configuradas\n"
        else
            existing_config+="$SYMBOL_WARNING Variables de entorno incompletas\n"
            needs_init=true
        fi
    else
        existing_config+="$SYMBOL_ERROR $SF_ENV_FILE no existe\n"
        needs_init=true
    fi

    if [[ -x "sf" ]]; then
        existing_config+="$SYMBOL_CHECK Script sf es ejecutable\n"
    else
        existing_config+="$SYMBOL_ERROR Script sf no es ejecutable\n"
        needs_init=true
    fi

    if [[ -d ".git" ]]; then
        existing_config+="$SYMBOL_CHECK Repositorio Git inicializado\n"
    else
        existing_config+="$SYMBOL_ERROR Repositorio Git no inicializado\n"
        needs_init=true
    fi

    echo "$SYMBOL_GEAR Estado actual del proyecto:"
    echo -e "$existing_config"

    if [[ "$needs_init" == false && "$1" != "--force" ]]; then
        echo ""
        echo "$SYMBOL_STAR El proyecto ya está completamente inicializado."
        echo "$SYMBOL_STAR Si quieres reinicializar, ejecuta: sf init --force"
        echo ""
        echo "$SYMBOL_STAR Para verificar configuración: sf status"
        return 0
    fi

    # Verificar confirmación (solo si no es --force)
    if [[ "$1" != "--force" ]]; then
        echo ""
        if ! confirm_action "¿Proceder con la inicialización?" "y"; then
            log_info "Inicialización cancelada."
            return 1
        fi
    fi

    # 1. Verificar dependencias
    echo ""
    echo "$SYMBOL_GEAR Verificando dependencias..."
    validate_dependencies

    # 2. Hacer script ejecutable
    echo "$SYMBOL_GEAR Configurando permisos del script..."
    chmod +x sf || {
        log_error "No se pudieron configurar permisos."
        return 1
    }

    # 3. Crear .env si no existe
    if [[ ! -f "$SF_ENV_FILE" ]]; then
        echo "$SYMBOL_COMMIT Creando archivo $SF_ENV_FILE..."
        cat > "$SF_ENV_FILE" << EOF
$DEFAULT_ENV_FILE
EOF
        echo "$SYMBOL_CHECK Archivo $SF_ENV_FILE creado. Edítalo con tus valores reales."
    else
        echo "$SYMBOL_CHECK Archivo $SF_ENV_FILE ya existe."
    fi

    # 4. Verificar/inicializar repositorio Git
    if [[ ! -d ".git" ]]; then
        echo "$SYMBOL_BOOK Inicializando repositorio Git..."
        git init || {
            log_error "No se pudo inicializar Git."
            return 1
        }
        git checkout -b "$DEFAULT_MAIN_BRANCH" 2>/dev/null || git switch -c "$DEFAULT_MAIN_BRANCH" 2>/dev/null || {
            log_error "No se pudo crear rama $DEFAULT_MAIN_BRANCH."
            return 1
        }
        echo "$SYMBOL_CHECK Repositorio Git inicializado."
    else
        echo "$SYMBOL_CHECK Repositorio Git ya existe."
    fi

    # 5. Configurar alias
    echo "$SYMBOL_LINK Configurando alias global..."
    local script_path
    script_path="$(pwd)/sf"
    if ! grep -q "alias sf=" ~/.bashrc 2>/dev/null && ! grep -q "alias sf=" ~/.zshrc 2>/dev/null; then
        echo "alias sf=\"$script_path\"" >> ~/.bashrc
        source ~/.bashrc 2>/dev/null || true
        echo "$SYMBOL_CHECK Alias configurado en ~/.bashrc"
        echo "$SYMBOL_STAR Reinicia tu terminal o ejecuta: source ~/.bashrc"
    else
        echo "$SYMBOL_CHECK Alias ya configurado."
    fi

    # 6. Crear .gitignore si no existe
    if [[ ! -f ".gitignore" ]]; then
        echo "$SYMBOL_BOOK Creando .gitignore básico..."
        cat > .gitignore << EOF
$DEFAULT_GITIGNORE
EOF
        echo "$SYMBOL_CHECK Archivo .gitignore creado."
    fi

    log_history "Project initialized"
    echo ""
    log_success "¡Proyecto inicializado exitosamente!"
    echo ""
    echo "$SYMBOL_BOOK Checklist completado:"
    echo "  $SYMBOL_CHECK Dependencias verificadas"
    echo "  $SYMBOL_CHECK Script configurado"
    echo "  $SYMBOL_CHECK Variables de entorno"
    echo "  $SYMBOL_CHECK Repositorio Git"
    echo "  $SYMBOL_CHECK Alias global"
    echo "  $SYMBOL_CHECK .gitignore"
    echo ""
    suggest_next_steps "init"
}

# ============================================================================
# COMANDO: SF HELP
# ============================================================================

# Comando: sf help
# Uso: show_help
show_help() {
    echo "sf - Shopify Flow CLI"
    echo ""
    echo "Comandos disponibles:"
    echo "  sf init      - Inicializa el proyecto y configura sf"
    echo "  sf start     - Inicia un nuevo flujo de trabajo creando una rama"
    echo "  sf commit    - Confirma cambios en la rama actual"
    echo "  sf publish   - Fusiona rama a $DEFAULT_MAIN_BRANCH y publica en Shopify"
    echo "  sf sync      - Sincroniza cambios desde Shopify Admin"
    echo "  sf resolve   - Resuelve conflictos y confirma cambios"
    echo "  sf status    - Muestra estado de Git y Shopify"
    echo "  sf dev       - Inicia servidor de desarrollo local"
    echo "  sf finish    - Elimina la rama actual después de publicar"
    echo "  sf stash     - Guarda cambios locales en stash"
    echo "  sf log       - Muestra historial de acciones"
    echo "  sf diff      - Compara diferencias entre ramas o con Shopify"
    echo "  sf clean     - Limpia ramas merged o antiguas"
    echo "  sf backup    - Gestiona copias de seguridad"
    echo "  sf pr        - Crea Pull Requests o Issues"
    echo "  sf help      - Muestra esta ayuda"
    echo ""
    echo "Flags globales disponibles:"
    echo "  --dry-run    Simula la operación sin ejecutarla"
    echo "  --force      Omite confirmaciones y validaciones de seguridad"
    echo "  --verbose    Muestra información detallada"
    echo ""
    echo "Asegúrate de configurar SHOPIFY_STORE y SHOPIFY_THEME_ID."
}

# ============================================================================
# FUNCIÓN PRINCIPAL
# ============================================================================

# Función principal
# Uso: main "$@"
main() {
    case "${1:-help}" in
        init) shift; init_project "$@" ;;
        *)
            load_env
            validate_dependencies

            # Validaciones preventivas inteligentes
            if ! preventive_checks "$1"; then
                return 1
            fi

            # Sugerencias inteligentes
            smart_suggestions "$1"

            case "$1" in
                start) start_branch ;;
                commit) commit_changes ;;
                publish) shift; publish_changes "$@" ;;
                sync) shift; sync_changes "$@" ;;
                resolve) resolve_conflicts ;;
                status) show_status ;;
                finish) finish_branch ;;
                stash) stash_changes ;;
                log) shift; show_log "$@" ;;
                diff) shift; show_diff "$@" ;;
                clean) shift; clean_branches "$@" ;;
                backup) shift; create_backup "$@" ;;
                pr) shift; create_pr_issue pr "$@" ;;
                dev) shift; start_dev_server "$@" ;;
                help|--help|-h) show_help ;;
                *) log_error "$ERROR_UNKNOWN_COMMAND: $1"; show_help; exit 1 ;;
            esac
            ;;
    esac
}