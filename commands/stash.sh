#!/bin/bash

source utils/env.sh
source utils/git.sh
source utils/common.sh

stash() {
    parse_flags "$@"
    
    echo "📦 Gestionando stash..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "🔍 [DRY-RUN] Verificando cambios para stash..."
        return 0
    fi
    
    # Verificar si hay cambios para stashear
    if ! check_uncommitted_changes; then
        echo "ℹ️  No hay cambios sin confirmar para guardar en stash"
        return 0
    fi
    
    # Crear mensaje de stash
    local stash_message="sf-stash-$(date +%Y%m%d-%H%M%S)"
    
    echo "💾 Guardando cambios en stash: $stash_message"
    
    if git stash push -m "$stash_message"; then
        echo "✅ Cambios guardados en stash exitosamente"
        log_history "stash" "Cambios guardados en stash: $stash_message"
        
        # Mostrar lista de stashes
        echo "📋 Stashes actuales:"
        git stash list | head -5
        
        suggest_next_steps "Cambios stasheados"
    else
        echo "❌ Error al guardar cambios en stash"
        return 1
    fi
}