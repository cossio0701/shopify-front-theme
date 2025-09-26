#!/bin/bash

# commands.sh - Implementación de comandos para sf
# Versión: 1.0
# Autor: Asistente de desarrollo

# Nota: Las utilidades se importan desde sf para evitar duplicaciones

# ============================================================================
# FUNCIONES DE SOPORTE PARA COMANDOS
# ============================================================================

# Función para resolver conflictos con cambios de Shopify
# Uso: resolve_shopify_conflicts "archivo1" "archivo2" ...
# Retorna: 0 si no hay conflictos, 1 si hay conflictos resueltos
resolve_shopify_conflicts() {
    local conflicted_files=("$@")
    if [[ ${#conflicted_files[@]} -gt 0 ]]; then
        log_warning "Se detectaron conflictos con cambios committed. Creando marcadores de merge granulares..."
        for file in "${conflicted_files[@]}"; do
            local base_file
            local ours_file
            local theirs_file
            base_file=$(mktemp)
            ours_file=$(mktemp)
            theirs_file=$(mktemp)
            echo "" > "$base_file"
            git show HEAD:"$file" > "$ours_file" 2>/dev/null || echo "" > "$ours_file"
            cat "$file" > "$theirs_file"
            git merge-file "$ours_file" "$base_file" "$theirs_file" >/dev/null 2>&1
            cat "$ours_file" > "$file"
            rm "$base_file" "$ours_file" "$theirs_file"
        done
        log_success "Marcadores de merge granulares creados en ${#conflicted_files[@]} archivo(s)."
        echo "$SYMBOL_GEAR Resuelve los conflictos editando los archivos, luego:"
        echo "  git add <archivo>"
        echo "  git commit -m 'resolve: conflictos sync Shopify'"
        return 1
    fi
    return 0
}

# Función para sugerir tipos de commit basados en cambios
# Uso: suggest_commit_type "cambios_summary"
# Retorna: tipo sugerido como string
suggest_commit_type() {
    local changes_summary="$1"

    # Analizar cambios para sugerir tipo
    if echo "$changes_summary" | grep -q "\.md\|\.txt\|README\|docs/"; then
        echo "docs"
    elif echo "$changes_summary" | grep -q "\.test\.|\.spec\.|test/|spec/"; then
        echo "test"
    elif echo "$changes_summary" | grep -q "\.css\|\.scss\|\.sass\|styles/"; then
        echo "style"
    elif echo "$changes_summary" | grep -q "package\.json\|yarn\.lock\|package-lock\.json\|\.gitignore"; then
        echo "chore"
    elif echo "$changes_summary" | grep -q "refactor\|rename\|move"; then
        echo "refactor"
    elif echo "$changes_summary" | grep -q "fix\|bug\|error\|issue"; then
        echo "fix"
    else
        echo "feat"  # Default
    fi
}

# Función para mostrar ejemplos de conventional commits
# Uso: show_commit_examples
show_commit_examples() {
    echo "$SYMBOL_BOOK Formato recomendado (Conventional Commits):"
    echo ""
    echo "  feat: agregar nueva funcionalidad de login"
    echo "  fix: corregir error en validación de email"
    echo "  docs: actualizar documentación de instalación"
    echo "  style: formatear código con prettier"
    echo "  refactor: renombrar variables para mayor claridad"
    echo "  test: agregar pruebas para componente header"
    echo "  chore: actualizar dependencias"
    echo "  perf: optimizar carga de imágenes"
    echo ""
    echo "$SYMBOL_INFO Tipos disponibles: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert"
}

# ============================================================================
# COMANDO: SF START
# ============================================================================

# Comando: sf start
# Uso: start_branch
start_branch() {
    validate_env
    log_info "Iniciando nuevo flujo de trabajo..."

    # Detectar estado actual
    echo "$SYMBOL_GEAR Estado actual del proyecto:"
    detect_project_state

    get_current_branch

    # Validaciones preventivas
    if [[ "$CURRENT_BRANCH" == "$DEFAULT_MAIN_BRANCH" ]]; then
        # Estamos en master, podemos crear nueva rama
        :
    else
        echo ""
        log_warning "Ya estás en una rama de trabajo: $CURRENT_BRANCH"
        echo "¿Quieres continuar en esta rama o crear una nueva?"
        echo "1. Continuar en $CURRENT_BRANCH"
        echo "2. Crear nueva rama (cambiará a $DEFAULT_MAIN_BRANCH primero)"
        echo "3. Cancelar"

        local choice
        read -p "Elige opción (1-3): " -n 1 -r choice
        echo

        case $choice in
            1)
                log_success "Continuando en rama actual: $CURRENT_BRANCH"
                suggest_next_steps "start" "existing-branch"
                return 0
                ;;
            2)
                log_info "Cambiando a $DEFAULT_MAIN_BRANCH para crear nueva rama..."
                git checkout "$DEFAULT_MAIN_BRANCH" || {
                    log_error "$ERROR_GIT_CHECKOUT_FAILED a $DEFAULT_MAIN_BRANCH."
                    return 1
                }
                ;;
            *)
                log_info "Operación cancelada."
                return 1
                ;;
        esac
    fi

    # Verificar cambios sin commit antes de crear rama
    if ! git diff --quiet || ! git diff --staged --quiet; then
        echo ""
        log_warning "$WARNING_UNCOMMITTED_CHANGES en $DEFAULT_MAIN_BRANCH."
        if ! confirm_action "¿Crear rama desde este estado?" "n" "Los cambios sin commit estarán en la nueva rama."; then
            return 1
        fi
    fi

    # Sincronizar con Shopify y remoto antes de crear rama
    log_info "Sincronizando con Shopify y remoto..."
    sync_changes --force || {
        log_error "Falló sincronización."
        return 1
    }

    # Menú interactivo para seleccionar tipo de flujo
    local workflow_options=("${WORKFLOW_TYPES[@]}")
    if ! interactive_menu workflow_options; then
        return 1
    fi

    # Extraer el tipo del option seleccionado
    local flow_type="${SELECTED_OPTION%%:*}"

    # Preguntar nombre descriptivo en kebab-case
    read -p "Nombre descriptivo (kebab-case): " name
    if [[ -z "$name" ]]; then
        log_error "El nombre es obligatorio."
        return 1
    fi

    if [[ ! "$name" =~ $REGEX_BRANCH_NAME ]]; then
        log_error "$ERROR_INVALID_BRANCH_NAME (solo letras minúsculas, números y guiones)."
        echo "Ejemplos válidos: add-product-slider, fix-header-bug, update-styles"
        return 1
    fi

    # Generar nombre de rama
    local date_suffix
    date_suffix=$(date "$DATE_FORMAT_BRANCH")
    local branch_name="${flow_type}/${name}-${date_suffix}"

    log_info "Creando rama: $branch_name"

    # Ejecutar comandos
    git checkout -b "$branch_name" || {
        log_error "No se pudo crear la rama."
        return 1
    }
    shopify theme pull -s "$SHOPIFY_STORE" -t "$SHOPIFY_THEME_ID" || {
        log_error "Falló shopify theme pull."
        return 1
    }
    git push -u origin "$branch_name" || {
        log_error "$ERROR_GIT_PUSH_FAILED."
        return 1
    }

    log_history "Started branch: $branch_name"
    log_success "$SUCCESS_BRANCH_CREATED."
    echo ""
    echo "$SYMBOL_ROCKET Trabajo listo para comenzar en: $branch_name"

    suggest_next_steps "start"
}

# ============================================================================
# COMANDO: SF COMMIT
# ============================================================================

# Comando: sf commit
# Uso: commit_changes
commit_changes() {
    validate_env
    get_current_branch

    if [[ "$CURRENT_BRANCH" == "$DEFAULT_MAIN_BRANCH" ]]; then
        log_error "$ERROR_NOT_IN_FEATURE_BRANCH."
        echo "$SYMBOL_STAR Usa 'sf start' para crear una rama de trabajo."
        return 1
    fi

    log_info "Preparando commit en rama: $CURRENT_BRANCH"

    # Mostrar estado actual
    echo "$SYMBOL_GEAR Archivos modificados:"
    git status --porcelain
    echo ""

    # Verificar si hay cambios
    if git diff --quiet && git diff --staged --quiet; then
        log_warning "No hay cambios para confirmar."
        echo "$SYMBOL_STAR Modifica algunos archivos primero, luego ejecuta 'sf commit'."
        return 1
    fi

    # Agregar archivos
    git add . || {
        log_error "Falló git add."
        return 1
    }

    # Mostrar diff resumido
    echo "$SYMBOL_BOOK Cambios a confirmar:"
    git diff --staged --stat
    echo ""

    # Preguntar mensaje de commit
    echo "$SYMBOL_COMMIT Mensaje de commit (formato recomendado: tipo: descripción)"
    echo "$SYMBOL_STAR Presiona Enter sin escribir para ver ejemplos"

    read -p "Mensaje de commit: " commit_message

    # Si no escribe nada, mostrar ejemplos
    if [[ -z "$commit_message" ]]; then
        show_commit_examples
        echo ""
        read -p "Mensaje de commit: " commit_message
        if [[ -z "$commit_message" ]]; then
            log_error "El mensaje de commit es obligatorio."
            return 1
        fi
    fi

    # Validar formato conventional commits
    if ! validate_commit_message "$commit_message"; then
        log_warning "El mensaje no sigue el formato recomendado de Conventional Commits."
        echo ""
        show_commit_examples
        echo ""

        # Sugerir tipo basado en cambios
        local changes_summary
        changes_summary=$(git diff --staged --name-only)
        local suggested_type
        suggested_type=$(suggest_commit_type "$changes_summary")
        echo "$SYMBOL_INFO Sugerencia basada en tus cambios: $suggested_type: $commit_message"
        echo ""

        if ! confirm_action "¿Usar este mensaje de todas formas?" "n" "Se recomienda usar el formato tipo: descripción"; then
            echo "$SYMBOL_STAR Intenta con: $suggested_type: $commit_message"
            return 1
        fi
    fi

    # Validar longitud del mensaje
    if [[ ${#commit_message} -lt $MIN_COMMIT_MESSAGE_LENGTH ]]; then
        log_warning "El mensaje es muy corto (${#commit_message} caracteres)."
        if ! confirm_action "¿Usar este mensaje de todas formas?" "n"; then
            return 1
        fi
    fi

    git commit -m "$commit_message" || {
        log_error "Falló git commit."
        return 1
    }

    log_history "Committed changes on $CURRENT_BRANCH: $commit_message"
    log_success "$SUCCESS_COMMIT_CREATED."
    echo "$SYMBOL_BACKUP Mensaje: $commit_message"

    suggest_next_steps "commit"
}

# ============================================================================
# COMANDO: SF PUBLISH
# ============================================================================

# Comando: sf publish
# Uso: publish_changes [--dry-run] [--force] [--verbose]
publish_changes() {
    validate_env
    get_current_branch

    # Parsear flags
    local flags_output
    flags_output=$(parse_flags "$@")
    local dry_run
    local force
    local verbose
    dry_run=$(echo "$flags_output" | cut -d' ' -f1)
    force=$(echo "$flags_output" | cut -d' ' -f2)
    verbose=$(echo "$flags_output" | cut -d' ' -f3)

    if [[ "$CURRENT_BRANCH" == "$DEFAULT_MAIN_BRANCH" ]]; then
        log_error "Ya estás en $DEFAULT_MAIN_BRANCH. Usa 'sf sync' para sincronizar."
        return 1
    fi

    log_info "Preparando publicación de: $CURRENT_BRANCH"

    # Mostrar resumen de cambios
    echo "$SYMBOL_GEAR Resumen de cambios:"
    echo "Rama: $CURRENT_BRANCH"
    echo "Commits por fusionar: $(git rev-list "$DEFAULT_MAIN_BRANCH".."$CURRENT_BRANCH" --count)"
    echo ""
    echo "Archivos modificados:"
    git diff --stat "$DEFAULT_MAIN_BRANCH".."$CURRENT_BRANCH"
    echo ""

    if [[ "$dry_run" == "true" ]]; then
        echo "$SYMBOL_GEAR Modo dry-run: Simulando publicación..."
        echo "  $SYMBOL_CHECK Verificar que no hay conflictos"
        echo "  $SYMBOL_CHECK Cambiar a $DEFAULT_MAIN_BRANCH"
        echo "  $SYMBOL_CHECK Fusionar $CURRENT_BRANCH"
        echo "  $SYMBOL_CHECK Publicar en Shopify"
        echo "  $SYMBOL_CHECK Subir cambios a remoto"
        echo ""
        echo "$SYMBOL_STAR Ejecuta sin --dry-run cuando estés listo para publicar."
        return 0
    fi

    # Validaciones críticas
    if [[ "$force" != "true" ]]; then
        check_uncommitted_changes

        # Verificar conflictos potenciales
        echo "$SYMBOL_GEAR Verificando conflictos potenciales..."
        if ! git merge-tree $(git merge-base "$DEFAULT_MAIN_BRANCH" "$CURRENT_BRANCH") "$DEFAULT_MAIN_BRANCH" "$CURRENT_BRANCH" >/dev/null 2>&1; then
            log_warning "$WARNING_POTENTIAL_CONFLICTS."
            if ! confirm_action "¿Continuar de todas formas?" "n" "Revisa los archivos que podrían tener conflictos."; then
                return 1
            fi
        fi
    fi

    # Ejecutar sync antes de publicar para actualizar y resolver conflictos
    log_info "Ejecutando sincronización completa antes de publicar..."
    if ! sync_changes --force; then
        log_error "Falló la sincronización. No se puede continuar con la publicación."
        return 1
    fi

    # Después de sync, deberíamos estar en master y listos para el merge
    log_info "Publicando cambios..."

    local feature_branch="$CURRENT_BRANCH"

    # Backup automático antes de publicar
    log_info "$INFO_CREATING_BACKUP..."
    git stash push -m "backup-auto-$(date "$DATE_FORMAT_BACKUP")" >/dev/null 2>&1 || true

    # Después de sync, estamos en master y listos para el merge
    if ! git merge "$feature_branch"; then
        log_error "$ERROR_GIT_MERGE_FAILED."
        echo ""
        echo "$SYMBOL_GEAR Para resolver:"
        echo "1. Edita los archivos en conflicto"
        echo "2. Ejecuta: git add <archivo>"
        echo "3. Ejecuta: git commit -m 'Resolve conflicts'"
        echo "4. Luego: shopify theme push -s \"$SHOPIFY_STORE\" -t \"$SHOPIFY_THEME_ID\""
        echo "5. Finalmente: git push origin $DEFAULT_MAIN_BRANCH"
        echo ""
        echo "$SYMBOL_STAR O usa 'sf backup restore' para restaurar el estado anterior."
        exit 1
    fi

    echo "$SYMBOL_PUSH Publicando en Shopify..."
    shopify theme push -s "$SHOPIFY_STORE" -t "$SHOPIFY_THEME_ID" || {
        log_error "$ERROR_SHOPIFY_PUSH_FAILED."
        echo "$SYMBOL_STAR El merge se completó, pero falló la publicación en Shopify."
        echo "   Puedes intentar nuevamente o publicar manualmente."
        return 1
    }

    git push origin "$DEFAULT_MAIN_BRANCH" || {
        log_error "$ERROR_GIT_PUSH_FAILED."
        return 1
    }

    log_history "Published changes from $feature_branch to $DEFAULT_MAIN_BRANCH"
    log_success "$SUCCESS_PUBLISH_COMPLETED!"
    echo "$SYMBOL_WEB 🌐 Cambios publicados en: https://$SHOPIFY_STORE"
    echo "$SYMBOL_MERGE Rama fusionada: $feature_branch → $DEFAULT_MAIN_BRANCH"

    suggest_next_steps "publish"
}

# ============================================================================
# COMANDO: SF SYNC
# ============================================================================

# Comando: sf sync
# Uso: sync_changes [--dry-run] [--force] [--verbose]
sync_changes() {
    validate_env

    # Parsear flags
    local flags_output
    flags_output=$(parse_flags "$@")
    local dry_run
    local force
    local verbose
    dry_run=$(echo "$flags_output" | cut -d' ' -f1)
    force=$(echo "$flags_output" | cut -d' ' -f2)
    verbose=$(echo "$flags_output" | cut -d' ' -f3)

    get_current_branch

    log_info "Sincronizando con Shopify Admin..."
    echo "$SYMBOL_BRANCH Rama actual: $CURRENT_BRANCH"

    if [[ "$dry_run" == "true" ]]; then
        echo "$SYMBOL_GEAR Modo dry-run: Simulando sincronización..."
        echo "  $SYMBOL_CHECK Verificar cambios en Shopify Admin"
        echo "  $SYMBOL_CHECK Cambiar a $DEFAULT_MAIN_BRANCH si es necesario"
        echo "  $SYMBOL_CHECK Sincronizar repositorio local"
        echo "  $SYMBOL_CHECK Verificar conflictos con cambios locales"
        return 0
    fi

    # Verificar cambios locales sin commit ANTES de cualquier operación
    local has_local_changes=false
    if ! git diff --quiet || ! git diff --staged --quiet; then
        has_local_changes=true
        echo ""
        log_warning "Tienes cambios locales sin commit."
        echo ""
        echo "$SYMBOL_COMMIT Archivos modificados:"
        git status --porcelain | head -10
        echo ""

        if [[ "$force" == "true" ]]; then
            log_info "Modo force activado: guardando cambios en stash automáticamente..."
            git stash push -m "auto-stash-sync-$(date "$DATE_FORMAT_BACKUP")" || {
                log_error "Falló git stash."
                return 1
            }
            log_success "Cambios guardados en stash."
        else
            echo "Opciones:"
            echo "1. Guardar cambios en stash temporalmente"
            echo "2. Confirmar cambios primero (recomendado)"
            echo "3. Cancelar sincronización"
            echo ""

            local choice
            read -p "Elige opción (1-3): " -n 1 -r choice
            echo

            case $choice in
                1)
                    echo "$SYMBOL_BACKUP Guardando cambios en stash..."
                    git stash push -m "auto-stash-sync-$(date "$DATE_FORMAT_BACKUP")" || {
                        log_error "Falló git stash."
                        return 1
                    }
                    log_success "Cambios guardados en stash."
                    ;;
                2)
                    echo "$SYMBOL_STAR Confirma tus cambios primero con 'sf commit', luego ejecuta 'sf sync' nuevamente."
                    return 1
                    ;;
                *)
                    log_info "Sincronización cancelada."
                    return 1
                    ;;
            esac
        fi
    fi

    # Cambiar a master si no estamos ahí
    if [[ "$CURRENT_BRANCH" != "$DEFAULT_MAIN_BRANCH" ]]; then
        log_info "Cambiando a rama $DEFAULT_MAIN_BRANCH..."
        git checkout "$DEFAULT_MAIN_BRANCH" || {
            log_error "$ERROR_GIT_CHECKOUT_FAILED a $DEFAULT_MAIN_BRANCH."
            return 1
        }
    fi

    # Verificar cambios en Shopify antes de descargar
    echo "$SYMBOL_GEAR Verificando cambios en Shopify Admin..."

    # Recordar estado antes del pull
    local changes_before
    changes_before=$(git status --porcelain | wc -l)

    # Intentar descargar cambios desde Shopify
    echo "$SYMBOL_PULL Descargando cambios desde Shopify..."
    if shopify theme pull -s "$SHOPIFY_STORE" -t "$SHOPIFY_THEME_ID" 2>/dev/null; then
        # Verificar si realmente había cambios comparando con el estado anterior
        local changes_after
        changes_after=$(git status --porcelain | wc -l)
        if [[ $changes_after -gt $changes_before ]]; then
            local shopify_has_changes=true
            log_success "Se encontraron cambios nuevos desde Shopify Admin."
            # Verificar si hay conflictos con cambios committed
            local conflicted_files=()
            for file in $(git diff --name-only); do
                if git diff HEAD "$file" >/dev/null 2>&1; then
                    conflicted_files+=("$file")
                fi
            done
            resolve_shopify_conflicts "${conflicted_files[@]}"
            if [[ $? -eq 1 ]]; then
                return 1
            fi
        else
            local shopify_has_changes=false
            log_success "No hay cambios nuevos en Shopify Admin."
        fi
    else
        log_error "$ERROR_SHOPIFY_PULL_FAILED."
        echo "$SYMBOL_STAR Verifica tu conexión y credenciales de Shopify."
        return 1
    fi

    # Sincronizar con remoto
    echo "$SYMBOL_SYNC Sincronizando con repositorio remoto..."
    git pull origin "$DEFAULT_MAIN_BRANCH" || {
        log_error "Falló git pull. Posible conflicto con cambios remotos."
        echo "$SYMBOL_STAR Resuelve manualmente: git pull origin $DEFAULT_MAIN_BRANCH"
        return 1
    }

    # Si había cambios locales guardados en stash, intentar restaurarlos
    if [[ "$has_local_changes" == "true" ]]; then
        echo "$SYMBOL_SYNC Restaurando cambios locales desde stash..."
        if git stash pop >/dev/null 2>&1; then
            log_success "Cambios locales restaurados exitosamente."

            # Verificar si hay conflictos después de restaurar
            if git diff --quiet && git diff --staged --quiet; then
                log_success "No hay conflictos entre cambios locales y de Shopify."
            else
                log_error "Hay conflictos entre tus cambios locales y los de Shopify."
                echo ""
                echo "$SYMBOL_COMMIT Archivos con conflictos:"
                git status --porcelain | grep "^UU\|^AA\|^DD" | head -10
                echo ""
                echo "$SYMBOL_GEAR Para resolver conflictos:"
                echo "1. Edita los archivos marcados con 'UU' (conflicto)"
                echo "2. Ejecuta: git add <archivo> después de resolver"
                echo "3. Confirma: git commit -m 'resolve: conflictos sync Shopify'"
                echo ""
                echo "$SYMBOL_STAR O usa 'git merge --abort' para cancelar y restaurar estado anterior."
                return 1
            fi
        else
            log_warning "No se pudieron restaurar los cambios del stash."
            echo "$SYMBOL_STAR Puedes restaurarlos manualmente con: git stash pop"
        fi
    fi

    # Verificar si hay cambios después de sync (solo si no había cambios locales originalmente)
    if [[ "$has_local_changes" == "false" ]] && (! git diff --quiet || ! git diff --staged --quiet); then
        echo ""
        echo "$SYMBOL_COMMIT Se encontraron cambios después de sincronizar:"
        git status --porcelain | head -5

        if [[ "$force" == "true" ]] || confirm_action "¿Confirmar estos cambios automáticamente?" "y" "Se creará un commit con mensaje 'sync: cambios desde admin Shopify'"; then
            git add . || {
                log_error "Falló git add."
                return 1
            }
            git commit -m "sync: cambios desde admin Shopify" || {
                log_error "Falló git commit."
                return 1
            }
            git push origin "$DEFAULT_MAIN_BRANCH" || {
                log_error "$ERROR_GIT_PUSH_FAILED."
                return 1
            }
            log_history "Synced and committed changes from Shopify Admin"
            log_success "Sincronización completada con commit automático."
        else
            log_info "Sincronización cancelada."
            echo "$SYMBOL_STAR Los cambios locales permanecen sin commit."
            echo "   Puedes confirmarlos manualmente cuando estés listo."
            return 1
        fi
    else
        if [[ "$shopify_has_changes" == "true" ]] || [[ "$has_local_changes" == "true" ]]; then
            log_history "Synced from Shopify Admin"
            log_success "Sincronización completada. Cambios de Shopify incorporados."
        else
            log_history "Sync checked (no changes)"
            log_success "Todo está sincronizado. No hay cambios nuevos."
        fi
    fi

    suggest_next_steps "sync"
}

# ============================================================================
# COMANDO: SF RESOLVE
# ============================================================================

# Comando: sf resolve
# Uso: resolve_conflicts
resolve_conflicts() {
    validate_env
    log_info "Resolviendo conflictos y confirmando cambios..."

    get_current_branch

    # Verificar que estamos en master
    if [[ "$CURRENT_BRANCH" != "$DEFAULT_MAIN_BRANCH" ]]; then
        log_error "Debes estar en la rama $DEFAULT_MAIN_BRANCH para resolver conflictos."
        echo "$SYMBOL_STAR Cambia a $DEFAULT_MAIN_BRANCH: git checkout $DEFAULT_MAIN_BRANCH"
        return 1
    fi

    # Verificar que estamos en medio de un merge o hay cambios para confirmar
    if git diff --quiet && git diff --staged --quiet && ! [[ -f .git/MERGE_HEAD ]]; then
        log_info "No hay conflictos pendientes ni cambios para confirmar."
        echo ""
        echo "$SYMBOL_WEB Estado actual del repositorio:"
        detect_project_state
        echo ""
        echo "$SYMBOL_STAR Si quieres sincronizar los cambios actuales con Shopify Admin:"
        echo "   shopify theme push -s \"$SHOPIFY_STORE\" -t \"$SHOPIFY_THEME_ID\""
        echo ""
        echo "$SYMBOL_STAR O si tienes cambios en una rama de trabajo, considera:"
        echo "   sf publish  # Para publicar cambios desde una rama de trabajo"
        return 0
    fi

    # Agregar todos los cambios
    echo "$SYMBOL_COMMIT Agregando archivos resueltos..."
    git add . || {
        log_error "Falló git add."
        return 1
    }

    # Confirmar con mensaje específico
    local commit_message="resolve: conflictos sync Shopify"
    echo "$SYMBOL_CHECK Confirmando cambios con mensaje: '$commit_message'"
    git commit -m "$commit_message" || {
        log_error "Falló git commit."
        return 1
    }

    # Publicar cambios
    echo "$SYMBOL_PUSH Publicando cambios a remoto..."
    git push origin "$DEFAULT_MAIN_BRANCH" || {
        log_error "$ERROR_GIT_PUSH_FAILED."
        return 1
    }

    log_history "Resolved conflicts and committed changes"
    log_success "Conflictos resueltos y publicados exitosamente."

    suggest_next_steps "resolve"
}

# ============================================================================
# COMANDO: SF STATUS
# ============================================================================

# Comando: sf status
# Uso: show_status
show_status() {
    validate_env
    echo "$SYMBOL_GEAR Estado del proyecto:"

    # Usar función de detección de estado
    detect_project_state

    echo ""
    echo "$SYMBOL_WEB Shopify Store: $(color_text "$COLOR_GREEN" "$SHOPIFY_STORE")"
    echo "$SYMBOL_STAR Theme ID: $SHOPIFY_THEME_ID"
    echo ""
    echo "$SYMBOL_STAR Para verificar cambios en Shopify Admin:"
    echo "   shopify theme pull -s \"$SHOPIFY_STORE\" -t \"$SHOPIFY_THEME_ID\""
}

# ============================================================================
# COMANDO: SF FINISH
# ============================================================================

# Comando: sf finish
# Uso: finish_branch
finish_branch() {
    validate_env
    get_current_branch

    if [[ "$CURRENT_BRANCH" == "$DEFAULT_MAIN_BRANCH" ]]; then
        log_error "No puedes finalizar la rama $DEFAULT_MAIN_BRANCH."
        return 1
    fi

    log_info "Preparando limpieza de rama: $CURRENT_BRANCH"

    # Verificar estado
    echo "$SYMBOL_GEAR Verificando estado antes de eliminar..."

    # Verificar si la rama está fusionada
    if git merge-base --is-ancestor "$CURRENT_BRANCH" "$DEFAULT_MAIN_BRANCH" 2>/dev/null; then
        log_success "Rama fusionada en $DEFAULT_MAIN_BRANCH"
    else
        log_warning "$WARNING_BRANCH_NOT_MERGED."
        echo "$SYMBOL_STAR Asegúrate de haber ejecutado 'sf publish' primero."
        if ! confirm_action "¿Eliminar rama de todas formas?" "n"; then
            return 1
        fi
    fi

    # Verificar cambios sin commit
    if ! git diff --quiet || ! git diff --staged --quiet; then
        log_warning "Hay cambios sin commit en esta rama."
        echo "Opciones:"
        echo "1. Guardar cambios: sf stash"
        echo "2. Forzar eliminación (perderás cambios)"
        echo "3. Cancelar y hacer commit primero"

        local choice
        read -p "Elige opción (1-3): " -n 1 -r choice
        echo

        case $choice in
            1)
                echo "$SYMBOL_BACKUP Guardando cambios en stash..."
                git stash push -m "auto-stash-finish-$(date "$DATE_FORMAT_BACKUP")" || {
                    log_error "No se pudieron guardar los cambios."
                    return 1
                }
                ;;
            2)
                log_warning "Los cambios sin commit se perderán permanentemente."
                if ! confirm_action "¿Confirmas eliminación forzada?" "n"; then
                    return 1
                fi
                ;;
            *)
                log_info "Operación cancelada. Confirma o guarda tus cambios primero."
                return 1
                ;;
        esac
    fi

    local branch_to_delete="$CURRENT_BRANCH"

    if ! confirm_action "¿Confirmas eliminar la rama '$branch_to_delete'?" "n" "Esta acción no se puede deshacer."; then
        log_info "Operación cancelada."
        return 1
    fi

    echo "$SYMBOL_CLEAN Eliminando rama..."

    git checkout "$DEFAULT_MAIN_BRANCH" || {
        log_error "$ERROR_GIT_CHECKOUT_FAILED a $DEFAULT_MAIN_BRANCH."
        return 1
    }
    git branch -d "$branch_to_delete" || {
        log_error "No se pudo eliminar la rama local."
        return 1
    }

    # Intentar eliminar rama remota
    if git push origin --delete "$branch_to_delete" &>/dev/null; then
        echo "$SYMBOL_CHECK Rama remota eliminada"
    else
        log_warning "No se pudo eliminar rama remota (puede que no exista)"
    fi

    log_history "Finished and deleted branch: $branch_to_delete"
    log_success "Rama '$branch_to_delete' eliminada exitosamente."
    echo "$SYMBOL_BRANCH Ahora estás en: $DEFAULT_MAIN_BRANCH"

    suggest_next_steps "finish"
}

# ============================================================================
# COMANDO: SF STASH
# ============================================================================

# Comando: sf stash
# Uso: stash_changes
stash_changes() {
    read -p "Mensaje para el stash: " stash_message
    if [[ -z "$stash_message" ]]; then
        stash_message="Stashed changes"
    fi

    git stash push -m "$stash_message" || {
        log_error "Falló git stash."
        return 1
    }

    log_history "Stashed changes: $stash_message"
    log_success "Cambios guardados en stash."
}

# ============================================================================
# COMANDO: SF LOG
# ============================================================================

# Comando: sf log
# Uso: show_log [--last N] [--today] [--yesterday] [--this-week]
show_log() {
    if [[ ! -f "$SF_HISTORY_FILE" ]]; then
        echo "$SYMBOL_BOOK No hay historial de acciones registrado."
        return 0
    fi

    echo "$SYMBOL_BOOK Historial de acciones de sf:"
    echo "================================="

    local filter=""
    local limit=""

    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --last)
                limit="$2"
                shift 2
                ;;
            --today)
                filter="today"
                shift
                ;;
            --yesterday)
                filter="yesterday"
                shift
                ;;
            --this-week)
                filter="this-week"
                shift
                ;;
            *)
                log_error "Opción desconocida: $1"
                echo "Opciones: --last N, --today, --yesterday, --this-week"
                return 1
                ;;
        esac
    done

    # Leer y filtrar historial
    local entries=()
    while IFS= read -r line; do
        local should_include=true

        if [[ -n "$filter" ]]; then
            local entry_date
            entry_date=$(echo "$line" | cut -d' ' -f1)
            local today
            today=$(date '+%Y-%m-%d')
            local yesterday
            yesterday=$(date -d 'yesterday' '+%Y-%m-%d')

            case $filter in
                today)
                    [[ "$entry_date" != "$today" ]] && should_include=false
                    ;;
                yesterday)
                    [[ "$entry_date" != "$yesterday" ]] && should_include=false
                    ;;
                this-week)
                    local week_start
                    week_start=$(date -d 'last monday' '+%Y-%m-%d')
                    [[ "$entry_date" < "$week_start" ]] && should_include=false
                    ;;
            esac
        fi

        if [[ "$should_include" == true ]]; then
            entries+=("$line")
        fi
    done < "$SF_HISTORY_FILE"

    # Aplicar límite
    if [[ -n "$limit" ]]; then
        entries=("${entries[@]: -limit}")
    fi

    # Mostrar entradas
    if [[ ${#entries[@]} -eq 0 ]]; then
        echo "No se encontraron entradas con los filtros aplicados."
    else
        for entry in "${entries[@]}"; do
            echo "$entry"
        done
    fi
}

# ============================================================================
# COMANDO: SF DIFF
# ============================================================================

# Comando: sf diff
# Uso: show_diff [--with-shopify] [--with-master] [--branches R1 R2]
show_diff() {
    validate_env
    get_current_branch

    local diff_type="$DEFAULT_MAIN_BRANCH"
    local target=""

    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --with-shopify)
                diff_type="shopify"
                shift
                ;;
            --with-master)
                diff_type="$DEFAULT_MAIN_BRANCH"
                shift
                ;;
            --branches)
                if [[ -n "$2" && -n "$3" ]]; then
                    diff_type="branches"
                    local branch1="$2"
                    local branch2="$3"
                    shift 3
                else
                    log_error "Uso: sf diff --branches <rama1> <rama2>"
                    return 1
                fi
                ;;
            *)
                log_error "Opción desconocida: $1"
                echo "Opciones:"
                echo "  --with-shopify    Comparar con cambios en Shopify Admin"
                echo "  --with-master     Comparar con rama $DEFAULT_MAIN_BRANCH (por defecto)"
                echo "  --branches R1 R2  Comparar entre dos ramas específicas"
                return 1
                ;;
        esac
    done

    echo "$SYMBOL_GEAR Comparando diferencias..."

    case $diff_type in
        "$DEFAULT_MAIN_BRANCH")
            if [[ "$CURRENT_BRANCH" == "$DEFAULT_MAIN_BRANCH" ]]; then
                log_warning "Ya estás en $DEFAULT_MAIN_BRANCH. No hay diferencias que mostrar."
                return 0
            fi
            echo "Comparando $CURRENT_BRANCH con $DEFAULT_MAIN_BRANCH:"
            git diff "$DEFAULT_MAIN_BRANCH..$CURRENT_BRANCH"
            ;;
        shopify)
            echo "Comparando cambios locales con Shopify Admin..."
            echo "Nota: Esta es una comparación simulada. Para ver cambios reales:"
            echo "  shopify theme pull -s \"$SHOPIFY_STORE\" -t \"$SHOPIFY_THEME_ID\""
            echo ""
            # Simular comparación mostrando archivos modificados
            echo "Archivos que podrían tener cambios en Shopify:"
            git status --porcelain | head -10
            ;;
        branches)
            echo "Comparando $branch1 con $branch2:"
            if git rev-parse --verify "$branch1" &>/dev/null && git rev-parse --verify "$branch2" &>/dev/null; then
                git diff "$branch1..$branch2"
            else
                log_error "Una o ambas ramas no existen: $branch1, $branch2"
                return 1
            fi
            ;;
    esac
}

# ============================================================================
# COMANDO: SF CLEAN
# ============================================================================

# Comando: sf clean
# Uso: clean_branches [--merged] [--older-than N] [--dry-run]
clean_branches() {
    local clean_type="merged"
    local days=""
    local dry_run=false

    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --merged)
                clean_type="merged"
                shift
                ;;
            --older-than)
                if [[ -n "$2" ]]; then
                    clean_type="older"
                    days="$2"
                    shift 2
                else
                    log_error "Uso: sf clean --older-than <dias>"
                    return 1
                fi
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            *)
                log_error "Opción desconocida: $1"
                echo "Opciones:"
                echo "  --merged          Eliminar ramas ya merged en $DEFAULT_MAIN_BRANCH"
                echo "  --older-than N    Eliminar ramas con commits más antiguos que N días"
                echo "  --dry-run         Mostrar qué se eliminaría sin hacerlo"
                return 1
                ;;
        esac
    done

    echo "$SYMBOL_CLEAN Limpiando ramas..."

    local branches_to_clean=()

    case $clean_type in
        merged)
            echo "Buscando ramas ya merged en $DEFAULT_MAIN_BRANCH..."
            # Obtener ramas locales merged
            while IFS= read -r branch; do
                if [[ "$branch" != "$DEFAULT_MAIN_BRANCH" && "$branch" != "*" ]]; then
                    branch=${branch#* }
                    if git merge-base --is-ancestor "$branch" "$DEFAULT_MAIN_BRANCH" 2>/dev/null; then
                        branches_to_clean+=("$branch")
                    fi
                fi
            done < <(git branch --merged "$DEFAULT_MAIN_BRANCH")
            ;;
        older)
            echo "Buscando ramas con commits más antiguos que $days días..."
            local cutoff_date
            cutoff_date=$(date -d "$days days ago" '+%Y-%m-%d')
            while IFS= read -r branch; do
                if [[ "$branch" != "$DEFAULT_MAIN_BRANCH" && "$branch" != "*" ]]; then
                    branch=${branch#* }
                    local last_commit_date
                    last_commit_date=$(git log -1 --format=%ci "$branch" 2>/dev/null | cut -d' ' -f1)
                    if [[ -n "$last_commit_date" && "$last_commit_date" < "$cutoff_date" ]]; then
                        branches_to_clean+=("$branch")
                    fi
                fi
            done < <(git branch)
            ;;
    esac

    if [[ ${#branches_to_clean[@]} -eq 0 ]]; then
        log_success "No se encontraron ramas para limpiar."
        return 0
    fi

    echo "Ramas encontradas para limpiar:"
    for branch in "${branches_to_clean[@]}"; do
        echo "  - $branch"
    done
    echo ""

    if [[ "$dry_run" == true ]]; then
        echo "$SYMBOL_GEAR Modo dry-run: No se eliminaron ramas."
        return 0
    fi

    if ! confirm_action "¿Confirmas eliminar estas ${#branches_to_clean[@]} ramas?"; then
        log_info "Operación cancelada."
        return 1
    fi

    local deleted_local=0
    local deleted_remote=0

    for branch in "${branches_to_clean[@]}"; do
        # Eliminar rama local
        if git branch -d "$branch" &>/dev/null; then
            ((deleted_local++))
            echo "  $SYMBOL_CHECK Eliminada rama local: $branch"
        fi

        # Intentar eliminar rama remota
        if git push origin --delete "$branch" &>/dev/null; then
            ((deleted_remote++))
            echo "  $SYMBOL_CHECK Eliminada rama remota: $branch"
        fi
    done

    log_history "Cleaned branches: ${#branches_to_clean[@]} local, $deleted_remote remote"
    echo ""
    log_success "$SUCCESS_CLEAN_COMPLETED: $deleted_local ramas locales, $deleted_remote ramas remotas eliminadas."
}

# ============================================================================
# COMANDO: SF BACKUP
# ============================================================================

# Comando: sf backup
# Uso: create_backup [create|branch|list|restore <nombre>]
create_backup() {
    local backup_type="stash"
    local backup_name=""

    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            create)
                backup_type="stash"
                shift
                ;;
            branch)
                backup_type="branch"
                shift
                ;;
            list)
                backup_type="list"
                shift
                ;;
            restore)
                if [[ -n "$2" ]]; then
                    backup_type="restore"
                    backup_name="$2"
                    shift 2
                else
                    log_error "Uso: sf backup restore <nombre>"
                    return 1
                fi
                ;;
            *)
                log_error "Opción desconocida: $1"
                echo "Opciones:"
                echo "  create              Crear backup en stash (por defecto)"
                echo "  branch              Crear backup en rama temporal"
                echo "  list                Listar backups disponibles"
                echo "  restore <nombre>    Restaurar backup específico"
                return 1
                ;;
        esac
    done

    case $backup_type in
        stash)
            echo "$SYMBOL_BACKUP Creando backup en stash..."
            local stash_message="backup-$(date "$DATE_FORMAT_BACKUP")"
            git stash push -m "$stash_message" || {
                log_error "Falló git stash."
                return 1
            }
            log_history "Created backup stash: $stash_message"
            log_success "$SUCCESS_BACKUP_CREATED: $stash_message"
            ;;
        branch)
            get_current_branch
            echo "$SYMBOL_BACKUP Creando backup en rama temporal..."
            local backup_branch="backup/$CURRENT_BRANCH-$(date "$DATE_FORMAT_BACKUP")"
            git checkout -b "$backup_branch" || {
                log_error "No se pudo crear rama backup."
                return 1
            }
            git checkout "$CURRENT_BRANCH" || {
                log_error "No se pudo volver a la rama original."
                return 1
            }
            log_history "Created backup branch: $backup_branch"
            log_success "$SUCCESS_BACKUP_CREATED en rama: $backup_branch"
            ;;
        list)
            echo "$SYMBOL_BOOK Backups disponibles:"
            echo ""
            echo "Stashes:"
            git stash list | nl -v0 || echo "  No hay stashes"
            echo ""
            echo "Ramas de backup:"
            git branch | grep "^  backup/" | nl -v1 || echo "  No hay ramas de backup"
            ;;
        restore)
            if [[ -z "$backup_name" ]]; then
                log_error "Debes especificar el nombre del backup a restaurar."
                echo "Usa 'sf backup list' para ver backups disponibles."
                return 1
            fi

            echo "$SYMBOL_SYNC Restaurando backup: $backup_name"

            # Intentar restaurar stash
            if git stash list | grep -q "$backup_name"; then
                local stash_index
                stash_index=$(git stash list | grep -n "$backup_name" | head -1 | cut -d: -f1)
                ((stash_index--))
                git stash apply "stash@{$stash_index}" || {
                    log_error "Falló restaurar stash."
                    return 1
                }
                log_success "Stash restaurado: $backup_name"
            # Intentar checkout de rama backup
            elif git branch | grep -q "^  $backup_name$"; then
                git checkout "$backup_name" || {
                    log_error "Falló checkout de rama backup."
                    return 1
                }
                log_success "Rama backup restaurada: $backup_name"
            else
                log_error "Backup no encontrado: $backup_name"
                return 1
            fi

            log_history "Restored backup: $backup_name"
            ;;
    esac
}

# ============================================================================
# COMANDO: SF PR
# ============================================================================

# Comando: sf pr
# Uso: create_pr_issue pr|issue [--title "titulo"] [--body "descripcion"]
create_pr_issue() {
    local action="$1"
    shift
    local title=""
    local body=""

    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            pr)
                action="pr"
                shift
                ;;
            issue)
                action="issue"
                shift
                ;;
            --title)
                if [[ -n "$2" ]]; then
                    title="$2"
                    shift 2
                else
                    log_error "Uso: --title <título>"
                    return 1
                fi
                ;;
            --body)
                if [[ -n "$2" ]]; then
                    body="$2"
                    shift 2
                else
                    log_error "Uso: --body <descripción>"
                    return 1
                fi
                ;;
            *)
                log_error "Opción desconocida: $1"
                echo "Opciones:"
                echo "  pr                 Crear Pull Request (por defecto)"
                echo "  issue              Crear Issue"
                echo "  --title <texto>    Título personalizado"
                echo "  --body <texto>     Descripción personalizada"
                return 1
                ;;
        esac
    done

    get_current_branch

    # Generar título por defecto
    if [[ -z "$title" ]]; then
        case $action in
            pr)
                title="feat: $CURRENT_BRANCH"
                ;;
            issue)
                title="Issue: $CURRENT_BRANCH"
                ;;
        esac
    fi

    # Generar descripción por defecto
    if [[ -z "$body" ]]; then
        case $action in
            pr)
                body="Pull Request for branch: $CURRENT_BRANCH\n\nChanges:\n$(git log --oneline "$DEFAULT_MAIN_BRANCH..$CURRENT_BRANCH" 2>/dev/null || echo "New branch")"
                ;;
            issue)
                body="Issue related to branch: $CURRENT_BRANCH"
                ;;
        esac
    fi

    echo "$SYMBOL_LINK Creando $action..."

    # Verificar si GitHub CLI está disponible
    if command -v gh &> /dev/null; then
        echo "$SYMBOL_CHECK GitHub CLI detectado. Creando $action automáticamente..."

        case $action in
            pr)
                gh pr create --title "$title" --body "$body" || {
                    log_error "Falló crear PR."
                    return 1
                }
                ;;
            issue)
                gh issue create --title "$title" --body "$body" || {
                    log_error "Falló crear issue."
                    return 1
                }
                ;;
        esac

        log_history "Created $action via GitHub CLI: $title"
        log_success "$action creado exitosamente."

    else
        log_warning "GitHub CLI no detectado. Aquí están las instrucciones manuales:"
        echo ""
        echo "Para crear un $action manualmente:"
        echo ""
        echo "1. Ve a tu repositorio en GitHub/GitLab"
        echo "2. Crea un nuevo $action con estos detalles:"
        echo ""
        echo "Título: $title"
        echo "Descripción:"
        echo "$body"
        echo ""
        echo "Comandos alternativos:"
        echo "- Instala GitHub CLI: https://cli.github.com/"
        echo "- O usa la interfaz web de tu plataforma Git"

        log_history "Generated $action instructions: $title"
    fi
}

# ============================================================================
# COMANDO: SF DEV
# ============================================================================

# Comando: sf dev
# Uso: start_dev_server [--test] [--port N] [--host IP] [--help]
start_dev_server() {
    validate_env

    log_info "Iniciando servidor de desarrollo..."
    echo "$SYMBOL_ROCKET Usando configuración por defecto de Shopify CLI (tema de desarrollo)"
    echo ""

    # Parsear argumentos PRIMERO
    local test_mode=false
    local port="$DEFAULT_DEV_PORT"
    local host="$DEFAULT_DEV_HOST"

    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                echo "Uso: sf dev [opciones]"
                echo ""
                echo "Opciones:"
                echo "  --test     Modo informativo de pruebas (sin cambios funcionales)"
                echo "  --port N   Puerto del servidor (default: $DEFAULT_DEV_PORT)"
                echo "  --host IP  Host del servidor (default: $DEFAULT_DEV_HOST)"
                echo "  --help     Mostrar esta ayuda"
                return 0
                ;;
            --test)
                test_mode=true
                shift
                ;;
            --port)
                port="$2"
                shift 2
                ;;
            --host)
                host="$2"
                shift 2
                ;;
            *)
                log_error "Opción desconocida: $1"
                echo "Usa 'sf dev --help' para ver opciones disponibles."
                return 1
                ;;
        esac
    done

    # Verificar si ya hay un servidor corriendo
    if pgrep -f "shopify theme dev" > /dev/null; then
        log_warning "Parece que ya hay un servidor de desarrollo corriendo."
        echo "$SYMBOL_STAR Si quieres detenerlo, usa: pkill -f 'shopify theme dev'"
        echo ""
        if ! confirm_action "¿Iniciar otro servidor de todas formas?" "n"; then
            return 0
        fi
    fi

    # Construir comando
    local cmd="shopify theme dev --port=\"$port\" --host=\"$host\""

    if [[ "$test_mode" == true ]]; then
        echo "$SYMBOL_GEAR Modo de pruebas activado (desarrollo sin recarga automática)"
        echo "$SYMBOL_WARNING En modo pruebas, los cambios no se reflejan automáticamente"
    else
        echo "$SYMBOL_SYNC Modo desarrollo con recarga automática"
    fi

    echo "$SYMBOL_GEAR Comando: $cmd"
    echo ""
    echo "$SYMBOL_WEB Una vez iniciado, podrás acceder a:"
    echo "   http://$host:$port"
    echo ""
    echo "$SYMBOL_STAR Presiona Ctrl+C para detener el servidor"
    echo ""

    # Ejecutar comando
    eval "$cmd"
}