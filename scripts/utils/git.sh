#!/bin/bash

# Función para obtener rama actual
get_current_branch() {
    CURRENT_BRANCH=$(git branch --show-current)
}

# Función para verificar cambios sin commit
check_uncommitted_changes() {
    if ! git diff --quiet || ! git diff --staged --quiet; then
        echo "❌ Error: Hay cambios sin confirmar (commit)"
            
        echo "Archivos modificados:"
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
            
        echo "Opciones:"
        echo "1. Confirma los cambios: sf commit"
        echo "2. Guarda temporalmente: sf stash"
        echo "3. Descarta cambios: git checkout -- .  (⚠️  PELIGROSO)"
        echo "4. Continua de todas formas: usa --force"
        exit 1
    fi
}

# Función para detectar el estado del proyecto
detect_project_state() {
    # Obtener rama actual
    local current_branch=$(git branch --show-current 2>/dev/null || echo "desconocida")

    # Contar cambios
    local staged_changes=$(git diff --staged --name-only | wc -l)
    local unstaged_changes=$(git diff --name-only | wc -l)
    local untracked_files=$(git ls-files --others --exclude-standard | wc -l)

    # Commits por publicar
    local commits_ahead=$(git rev-list origin/master..HEAD --count 2>/dev/null || git rev-list master..HEAD --count 2>/dev/null || echo "0")

    # Mostrar estado
    echo "🌿 Rama actual: $(color_text "1;34" "$current_branch")"

    if [[ $staged_changes -gt 0 ]]; then
    #  echo "$(color_text "1;32" "📝 Cambios preparados:")"
        echo "📝 Cambios preparados: $(color_text "1;32" "$staged_changes archivo(s)")"
    fi

    if [[ $unstaged_changes -gt 0 ]]; then
        echo "✏️  Cambios sin preparar: $(color_text "1;33" "$unstaged_changes archivo(s)")"
    fi

    if [[ $untracked_files -gt 0 ]]; then
        echo "📄 Archivos no rastreados: $(color_text "1;33" "$untracked_files archivo(s)")"
    fi

    if [[ $commits_ahead -gt 0 ]]; then
        echo "⬆️  Commits por publicar: $(color_text "1;33" "$commits_ahead")"
    fi

    # Estado general
    if [[ $staged_changes -eq 0 && $unstaged_changes -eq 0 && $untracked_files -eq 0 ]]; then
        echo "✅ Repositorio limpio"
    fi
}

# Función para resolver conflictos con cambios de Shopify
resolve_shopify_conflicts() {
    local conflicted_files=("$@")
    if [[ ${#conflicted_files[@]} -gt 0 ]]; then
        echo "$(color_text "1;31" "⚠️  Se detectaron conflictos con cambios committed. Creando marcadores de merge granulares...")"
        for file in "${conflicted_files[@]}"; do
            local base_file=$(mktemp)
            local ours_file=$(mktemp)
            local theirs_file=$(mktemp)
            echo "" > "$base_file"
            git show HEAD:"$file" > "$ours_file" 2>/dev/null || echo "" > "$ours_file"
            cat "$file" > "$theirs_file"
            git merge-file "$ours_file" "$base_file" "$theirs_file" >/dev/null 2>&1
            cat "$ours_file" > "$file"
            rm "$base_file" "$ours_file" "$theirs_file"
        done
        echo "✅ Marcadores de merge granulares creados en ${#conflicted_files[@]} archivo(s)."
        echo "🔧 Resuelve los conflictos editando los archivos, luego:"
        echo "  git add <archivo>"
        echo "  git commit -m 'resolve: conflictos sync Shopify'"
        return 1
    fi
    return 0
}

# Función para validaciones preventivas inteligentes
preventive_checks() {
    local command="$1"

    # Solo ejecutar para comandos que modifican estado
    case "$command" in
        start|commit|publish|finish|resolve)
            # Verificar si estamos en un repo Git
            if [[ ! -d ".git" ]]; then
                echo "❌ Error: No estás en un repositorio Git."
                echo "💡 Ejecuta 'sf init' para inicializar el proyecto."
                return 1
            fi

            # Verificar conexión con remoto
            if ! git ls-remote --exit-code origin >/dev/null 2>&1; then
                echo "⚠️  No se puede conectar con el repositorio remoto."
                echo "   Verifica tu conexión a internet y configuración de Git."
            fi
            ;;
    esac

    return 0
}

# Función para detectar y sugerir correcciones comunes
smart_suggestions() {
    local command="$1"

    case "$command" in
        start)
            # Si hay stash, sugerir restaurarlo
            if [[ $(git stash list | wc -l) -gt 0 ]]; then
                echo "💡 Tienes $(git stash list | wc -l) cambios en stash. Considera restaurarlos: git stash pop"
            fi
            ;;
        commit)
            # Si no hay cambios, sugerir qué hacer
            if git diff --quiet && git diff --staged --quiet; then
                echo "💡 No hay cambios para confirmar. Modifica archivos primero."
                return
            fi
            ;;
        publish)
            # Verificar si hay muchos commits sin publicar
            local commits_ahead=$(git rev-list master..HEAD --count 2>/dev/null || echo "0")
            if [[ $commits_ahead -gt 5 ]]; then
                echo "⚠️  Tienes $commits_ahead commits por publicar. Considera hacer commits más pequeños."
            fi
            ;;
    esac
}