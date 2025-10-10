#!/bin/bash

source scripts/utils/env.sh
source scripts/utils/git.sh
source scripts/utils/common.sh

clean() {
    parse_flags "$@"
    
    echo "🧹 Limpiando ramas..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "🔍 [DRY-RUN] Verificando ramas para limpiar..."
        return 0
    fi
    
    # Obtener rama actual
    local current_branch
    current_branch=$(get_current_branch)
    
    # Encontrar ramas merged
    local merged_branches
    merged_branches=$(git branch --merged | grep -v "^\*" | grep -v "master\|main" | sed 's/^[[:space:]]*//')
    
    if [[ -z "$merged_branches" ]]; then
        echo "ℹ️  No hay ramas merged para limpiar"
        return 0
    fi
    
    echo "Ramas que pueden ser eliminadas:"
    echo "$merged_branches"
    echo ""
    
    if [[ "$FORCE" != "true" ]]; then
        if ! confirm_action "Eliminar estas ramas"; then
            echo "❌ Operación cancelada."
            return 1
        fi
    fi
    
    # Eliminar ramas
    local deleted_count=0
    while IFS= read -r branch; do
        if [[ -n "$branch" ]]; then
            echo "🗑️  Eliminando rama: $branch"
            if git branch -d "$branch"; then
                ((deleted_count++))
            else
                echo "⚠️  No se pudo eliminar: $branch"
            fi
        fi
    done <<< "$merged_branches"
    
    echo "✅ Eliminadas $deleted_count ramas"
    log_history "clean" "Eliminadas $deleted_count ramas merged"
    suggest_next_steps "Limpieza completada"
}