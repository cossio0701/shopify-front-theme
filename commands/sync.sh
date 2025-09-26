#!/bin/bash
source utils/env.sh
source utils/git.sh
source utils/common.sh

sync() {
    validate_env

    # Parsear flags
    local flags_output=$(parse_flags "$@")
    local dry_run=$(echo "$flags_output" | cut -d' ' -f1)
    local force=$(echo "$flags_output" | cut -d' ' -f2)
    local verbose=$(echo "$flags_output" | cut -d' ' -f3)

    get_current_branch

    echo "🔄 Sincronizando con Shopify Admin..."
    echo "📍 Rama actual: $CURRENT_BRANCH"

    if [[ "$dry_run" == true ]]; then
        echo "🔍 Modo dry-run: Simulando sincronización..."
        echo "  ✅ Verificar cambios en Shopify Admin"
        echo "  ✅ Cambiar a master si es necesario"
        echo "  ✅ Sincronizar repositorio local"
        echo "  ✅ Verificar conflictos con cambios locales"
        return 0
    fi

    # Verificar cambios locales sin commit ANTES de cualquier operación
    local has_local_changes=false
    if ! git diff --quiet || ! git diff --staged --quiet; then
        has_local_changes=true
        echo "⚠️  Tienes cambios locales sin commit."
            
        echo "📝 Archivos modificados:"
    # Mostrar archivos modificados pero no preparados
    local unstaged=$(git diff --name-only)
    if [[ -n "$unstaged" ]]; then
        echo "✏️  Cambios sin preparar:"
        echo "$unstaged" | sed 's/^/    /'
            
    fi
    
    # Mostrar archivos preparados para commit
    local staged=$(git diff --staged --name-only)
    if [[ -n "$staged" ]]; then
        echo "📝 Cambios preparados:"
        echo "$staged" | sed 's/^/    /'
            
    fi
    
    # Mostrar archivos no rastreados
    local untracked=$(git ls-files --others --exclude-standard)
    if [[ -n "$untracked" ]]; then
        echo "📄 Archivos no rastreados:"
        echo "$untracked" | sed 's/^/    /'
            
    fi
            

        if [[ "$force" == true ]]; then
            echo "🔄 Modo force activado: guardando cambios en stash automáticamente..."
            git stash push -m "auto-stash-sync-$(date '+%Y%m%d-%H%M%S')" || { echo "❌ Error: Falló git stash."; return 1; }
            echo "✅ Cambios guardados en stash."
        else
            echo "Opciones:"
            echo "1. Guardar cambios en stash temporalmente"
            echo "2. Confirmar cambios primero (recomendado)"
            echo "3. Cancelar sincronización"
                

            local choice
            read -p "Elige opción (1-3): " -n 1 -r choice
            echo

            case $choice in
                1)
                    echo "📦 Guardando cambios en stash..."
                    git stash push -m "auto-stash-sync-$(date '+%Y%m%d-%H%M%S')" || { echo "❌ Error: Falló git stash."; return 1; }
                    echo "✅ Cambios guardados en stash."
                    ;;
                2)
                    echo "💡 Confirma tus cambios primero con 'sf commit', luego ejecuta 'sf sync' nuevamente."
                    return 1
                    ;;
                *)
                    echo "🚫 Sincronización cancelada."
                    return 1
                    ;;
            esac
        fi
    fi

    # Cambiar a master si no estamos ahí
    if [[ "$CURRENT_BRANCH" != "master" ]]; then
        echo "🔄 Cambiando a rama master..."
        git checkout master || { echo "❌ Error: No se pudo cambiar a master."; return 1; }
    fi

    # Verificar cambios en Shopify antes de descargar
    echo "🔍 Verificando cambios en Shopify Admin..."

    # Recordar estado antes del pull
    local changes_before=$(git status --porcelain | wc -l)

    # Intentar descargar cambios desde Shopify
    echo "📥 Descargando cambios desde Shopify..."
    if shopify theme pull -s "$SHOPIFY_STORE" -t "$SHOPIFY_THEME_ID" 2>/dev/null; then
        local changes_after=$(git status --porcelain | wc -l)
        if [[ $changes_after -gt $changes_before ]]; then
            local shopify_has_changes=true
            echo "✅ Se encontraron cambios nuevos desde Shopify Admin."
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
            echo "✅ No hay cambios nuevos en Shopify Admin."
        fi
    else
        echo "❌ Error: Falló shopify theme pull."
        echo "💡 Verifica tu conexión y credenciales de Shopify."
        return 1
    fi

    # Sincronizar con remoto
    echo "🔄 Sincronizando con repositorio remoto..."
    git pull origin master || {
        echo "$(color_text "1;31" "❌ Error: Falló git pull. Posible conflicto con cambios remotos.")"
        echo "💡 Resuelve manualmente: git pull origin master"
        return 1
    }

    # Si había cambios locales guardados en stash, intentar restaurarlos
    if [[ "$has_local_changes" == true ]]; then
        echo "🔄 Restaurando cambios locales desde stash..."
        if git stash pop >/dev/null 2>&1; then
            echo "✅ Cambios locales restaurados exitosamente."

            # Verificar si hay conflictos después de restaurar
            if git diff --quiet && git diff --staged --quiet; then
                echo "✅ No hay conflictos entre cambios locales y los de Shopify."
            else
                echo "$(color_text "1;31" "⚠️  Hay conflictos entre tus cambios locales y los de Shopify.")"
                    
                echo "$(color_text "1;31" "📝 Archivos con conflictos:")"
    # Mostrar archivos modificados pero no preparados
    local unstaged=$(git diff --name-only)
    if [[ -n "$unstaged" ]]; then
        echo "✏️  Cambios sin preparar:"
        echo "$unstaged" | sed 's/^/    /'
            
    fi
    
    # Mostrar archivos preparados para commit
    local staged=$(git diff --staged --name-only)
    if [[ -n "$staged" ]]; then
        echo "📝 Cambios preparados:"
        echo "$staged" | sed 's/^/    /'
            
    fi
    
    # Mostrar archivos no rastreados
    local untracked=$(git ls-files --others --exclude-standard)
    if [[ -n "$untracked" ]]; then
        echo "📄 Archivos no rastreados:"
        echo "$untracked" | sed 's/^/    /'
            
    fi
                    
                echo "🔧 Para resolver conflictos:"
                echo "1. Edita los archivos marcados con 'UU' (conflicto)"
                echo "2. Ejecuta: git add <archivo> después de resolver"
                echo "3. Confirma: git commit -m 'resolve: conflictos sync Shopify'"
                    
                echo "O usa 'git merge --abort' para cancelar y restaurar estado anterior."
                return 1
            fi
        else
            echo "⚠️  No se pudieron restaurar los cambios del stash."
            echo "💡 Puedes restaurarlos manualmente con: git stash pop"
        fi
    fi

    # Verificar si hay cambios después de sync (solo si no había cambios locales originalmente)
    if [[ "$has_local_changes" == false ]] && (! git diff --quiet || ! git diff --staged --quiet); then
            
        echo "📝 Se encontraron cambios después de sincronizar:"
    # Mostrar archivos modificados pero no preparados
    local unstaged=$(git diff --name-only)
    if [[ -n "$unstaged" ]]; then
        echo "✏️  Cambios sin preparar:"
        echo "$unstaged" | sed 's/^/    /'
            
    fi
    
    # Mostrar archivos preparados para commit
    local staged=$(git diff --staged --name-only)
    if [[ -n "$staged" ]]; then
        echo "📝 Cambios preparados:"
        echo "$staged" | sed 's/^/    /'
            
    fi
    
    # Mostrar archivos no rastreados
    local untracked=$(git ls-files --others --exclude-standard)
    if [[ -n "$untracked" ]]; then
        echo "📄 Archivos no rastreados:"
        echo "$untracked" | sed 's/^/    /'
            
    fi

        if [[ "$force" == true ]] || confirm_action "¿Confirmar estos cambios automáticamente?" "y" "Se creará un commit con mensaje 'sync: cambios desde admin Shopify'"; then
            git add . || { echo "❌ Error: Falló git add."; return 1; }
            git commit -m "sync: cambios desde admin Shopify" || { echo "❌ Error: Falló git commit."; return 1; }
            git push origin master || { echo "❌ Error: Falló git push."; return 1; }
            log_history "Synced and committed changes from Shopify Admin"
            echo "✅ Sincronización completada con commit automático."
        else
            echo "🚫 Sincronización cancelada."
            echo "💡 Los cambios locales permanecen sin commit."
            echo "   Puedes confirmarlos manualmente cuando estés listo."
            return 1
        fi
    else
        if [[ "$shopify_has_changes" == true ]] || [[ "$has_local_changes" == true ]]; then
            log_history "Synced from Shopify Admin"
            echo "✅ Sincronización completada. Cambios de Shopify incorporados."
        else
            log_history "Sync checked (no changes)"
            echo "✅ Todo está sincronizado. No hay cambios nuevos."
        fi
    fi

    suggest_next_steps "sync"
}