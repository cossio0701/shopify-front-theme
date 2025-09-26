#!/bin/bash
source utils/env.sh
source utils/git.sh
source utils/common.sh

commit() {
    validate_env
    get_current_branch

    if [[ "$CURRENT_BRANCH" == "master" ]]; then
        echo "❌ Error: No puedes hacer commit en la rama master."
        echo "💡 Usa 'sf start' para crear una rama de trabajo."
        return 1
    fi

    echo "📝 Preparando commit en rama: $CURRENT_BRANCH"

    # Mostrar estado actual
    echo "📊 Archivos modificados:"
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
        

    # Verificar si hay cambios
    if git diff --quiet && git diff --staged --quiet; then
        echo "⚠️  No hay cambios para confirmar."
        echo "💡 Modifica algunos archivos primero, luego ejecuta 'sf commit'."
        return 1
    fi

    # Agregar archivos
    git add . || { echo "❌ Error: Falló git add."; return 1; }

    # Mostrar diff resumido
    echo "📋 Cambios a confirmar:"
    git diff --staged --stat
        

    # Preguntar mensaje de commit
    echo "📝 Mensaje de commit (formato recomendado: tipo: descripción)"
    echo "💡 Presiona Enter sin escribir para ver ejemplos de tipos"

    read -p "Mensaje de commit: " commit_message

    # Si no escribe nada, mostrar ejemplos
    if [[ -z "$commit_message" ]]; then
        show_commit_examples
            
        read -p "Mensaje de commit: " commit_message
        if [[ -z "$commit_message" ]]; then
            echo "❌ Error: El mensaje de commit es obligatorio."
            return 1
        fi
    fi

    # Validar formato conventional commits
    if ! validate_commit_message "$commit_message"; then
        echo "⚠️  El mensaje no sigue el formato recomendado de Conventional Commits."
            
        show_commit_examples
            

        # Sugerir tipo basado en cambios
        local changes_summary=$(git diff --staged --name-only)
        local suggested_type=$(suggest_commit_type "$changes_summary")
        echo "💡 Sugerencia basada en tus cambios: $suggested_type: $commit_message"
            

        if ! confirm_action "¿Usar este mensaje de todas formas?" "n" "Se recomienda usar el formato tipo: descripción"; then
            echo "💡 Intenta con: $suggested_type: $commit_message"
            return 1
        fi
    fi

    # Validar longitud del mensaje (solo si no es conventional commit válido)
    if [[ ${#commit_message} -lt 10 ]]; then
        echo "⚠️  El mensaje es muy corto (${#commit_message} caracteres)."
        if ! confirm_action "¿Usar este mensaje de todas formas?" "n"; then
            return 1
        fi
    fi

    git commit -m "$commit_message" || { echo "❌ Error: Falló git commit."; return 1; }

    log_history "Committed changes on $CURRENT_BRANCH: $commit_message"
    echo "✅ Commit realizado exitosamente."
    echo "💾 Mensaje: $commit_message"

    suggest_next_steps "commit"
}