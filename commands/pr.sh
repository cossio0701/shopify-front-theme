#!/bin/bash

source utils/env.sh
source utils/git.sh
source utils/common.sh

pr() {
    parse_flags "$@"
    
    echo "🔗 Gestionando Pull Requests..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "🔍 [DRY-RUN] Verificando estado para PR..."
        return 0
    fi
    
    # Verificar si estamos en una rama feature
    local current_branch
    current_branch=$(get_current_branch)
    
    if [[ "$current_branch" == "master" || "$current_branch" == "main" ]]; then
        echo "❌ Debes estar en una rama feature para crear un PR"
        return 1
    fi
    
    # Verificar si hay cambios sin commitear
    if check_uncommitted_changes; then
        echo "⚠️  Hay cambios sin confirmar. Confirma los cambios antes de crear un PR."
        return 1
    fi
    
    # Verificar si la rama existe en remoto
    if ! git ls-remote --heads origin "$current_branch" >/dev/null 2>&1; then
        echo "📤 Subiendo rama al remoto..."
        git push -u origin "$current_branch" || {
            echo "❌ Error al subir la rama"
            return 1
        }
    fi
    
    # Obtener información del último commit
    local last_commit
    last_commit=$(git log -1 --pretty=format:"%s%n%n%b")
    
    echo "📋 Información del PR:"
    echo "Rama: $current_branch"
    echo "Base: master/main"
    echo "Último commit: $last_commit"
    echo ""
    
    # Generar URL del PR (asumiendo GitHub)
    local repo_url
    repo_url=$(git config --get remote.origin.url | sed 's/\.git$//')
    
    if [[ "$repo_url" == *"github.com"* ]]; then
        local pr_url="$repo_url/compare/master...$current_branch"
        echo "🔗 URL del PR: $pr_url"
        echo ""
        echo "💡 Copia esta URL en tu navegador para crear el Pull Request"
    fi
    
    echo "✅ Información del PR preparada"
    log_history "pr" "PR preparado para rama $current_branch"
    suggest_next_steps "PR preparado"
}