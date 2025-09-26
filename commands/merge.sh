#!/bin/bash
source utils/env.sh
source utils/git.sh
source utils/common.sh
source commands/sync.sh

merge() {
    validate_env
    get_current_branch

    # Parsear flags
    local flags_output=$(parse_flags "$@")
    local dry_run=$(echo "$flags_output" | cut -d' ' -f1)
    local force=$(echo "$flags_output" | cut -d' ' -f2)
    local verbose=$(echo "$flags_output" | cut -d' ' -f3)

    if [[ "$CURRENT_BRANCH" == "master" ]]; then
        echo "❌ Error: Ya estás en master. Usa 'sf sync' para sincronizar."
        return 1
    fi

    echo "🔀 Preparando merge de: $CURRENT_BRANCH"

    # Mostrar resumen de cambios
    echo "📊 Resumen de cambios:"
    echo "Rama: $CURRENT_BRANCH"
    echo "Commits por fusionar: $(git rev-list master.."$CURRENT_BRANCH" --count)"
        
    echo "Archivos modificados:"
    git diff --stat master.."$CURRENT_BRANCH"
        

    if [[ "$dry_run" == true ]]; then
        echo "🔍 Modo dry-run: Simulando merge..."
        echo "  ✅ Verificar que no hay conflictos"
        echo "  ✅ Cambiar a master"
        echo "  ✅ Fusionar $CURRENT_BRANCH"
        echo "  ✅ Sincronizar con Shopify Admin"
            
        echo "💡 Ejecuta sin --dry-run cuando estés listo para mergear."
        return 0
    fi

    # Validaciones críticas
    if [[ "$force" != true ]]; then
        check_uncommitted_changes

        # Verificar conflictos potenciales
        echo "🔍 Verificando conflictos potenciales..."
        if ! git merge-tree $(git merge-base master "$CURRENT_BRANCH") master "$CURRENT_BRANCH" >/dev/null 2>&1; then
            echo "⚠️  Posibles conflictos detectados."
            if ! confirm_action "¿Continuar de todas formas?" "n" "Revisa los archivos que podrían tener conflictos."; then
                return 1
            fi
        fi
    fi

    # Ejecutar sync después del merge para descargar cambios de Shopify Admin
    echo "🔄 Ejecutando sincronización después del merge..."
    if ! sync --force; then
        echo "❌ Error: Falló la sincronización. El merge se completó, pero verifica los cambios."
    fi

    # Después de sync, deberíamos estar en master
    echo "🚀 Fusionando cambios..."

    local feature_branch="$CURRENT_BRANCH"

    # Backup automático antes de mergear
    echo "💾 Creando backup automático..."
    git stash push -m "backup-auto-$(date '+%Y%m%d-%H%M%S')" >/dev/null 2>&1 || true

    # Después de sync, estamos en master y listos para el merge
    if ! git merge "$feature_branch"; then
        echo "❌ Error: Conflicto en merge."
            
        echo "🔧 Para resolver:"
        echo "1. Edita los archivos en conflicto"
        echo "2. Ejecuta: git add <archivo>"
        echo "3. Ejecuta: git commit -m 'Resolve conflicts'"
        echo "4. Luego: sf publish"
            
        echo "O usa 'sf backup restore' para restaurar el estado anterior."
        exit 1
    fi

    log_history "Merged changes from $feature_branch to master"
    echo "✅ ¡Merge completado exitosamente!"
    echo "🌐 Rama fusionada: $feature_branch → master"

    # Sugerir probar cambios si no hay conflictos
    if git diff --quiet && git diff --staged --quiet; then
        echo "💡 No hay conflictos. Puedes probar los cambios localmente."
        echo "   Ejecuta: sf dev"
        echo "   O publica directamente: sf publish"
    else
        echo "⚠️  Hay cambios pendientes. Revisa y confirma antes de publicar."
    fi

    suggest_next_steps "merge"
}