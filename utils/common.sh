#!/bin/bash

# Función para registrar acciones en el historial
log_history() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" >> "$HISTORY_FILE"
}

# Función para parsear flags globales
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

# Función para sugerir próximos pasos
suggest_next_steps() {
    local command="$1"
    local context="$2"

        
    echo "💡 Próximos pasos sugeridos:"

    case "$command" in
        init)
            echo "1. Edita .env con tus credenciales de Shopify"
            echo "2. Reinicia terminal o ejecuta: source ~/.bashrc"
            echo "3. Prueba: sf status"
            ;;
        start)
            echo "1. Realiza tus cambios en el código"
            echo "2. Confirma cambios: sf commit"
            echo "3. Fusiona cuando esté listo: sf merge --dry-run"
            ;;
        commit)
            echo "1. Verifica cambios: sf diff --with-master"
            echo "2. Fusiona: sf merge --dry-run (primero)"
            echo "3. Fusiona: sf merge"
            ;;
        merge)
            echo "1. Prueba los cambios localmente: sf dev"
            echo "2. Publica cuando esté listo: sf publish --dry-run"
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
            echo "1. Prueba los cambios localmente: sf dev --test"
            echo "2. Si todo funciona, publica a Shopify: sf publish"
            echo "3. Inicia nuevo trabajo: sf start"
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

# Función para validar formato de conventional commits
validate_commit_message() {
    local message="$1"

    # Tipos de commit válidos (conventional commits)
    local valid_types="feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert"

    # Patrón regex para conventional commits
    # Formato: type(scope): description
    # O: type: description
    local pattern="^($valid_types)(\([a-zA-Z0-9_-]+\))?: .+"

    if [[ $message =~ $pattern ]]; then
        return 0  # Válido
    else
        return 1  # Inválido
    fi
}

# Función para sugerir tipos de commit basados en cambios
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
show_commit_examples() {
    echo "💡 Formato recomendado (Conventional Commits):"
        
    echo "  feat: agregar nueva funcionalidad de login"
    echo "  fix: corregir error en validación de email"
    echo "  docs: actualizar documentación de instalación"
    echo "  style: formatear código con prettier"
    echo "  refactor: renombrar variables para mayor claridad"
    echo "  test: agregar pruebas para componente header"
    echo "  chore: actualizar dependencias"
    echo "  perf: optimizar carga de imágenes"
        
    echo "📝 Tipos disponibles: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert"
}