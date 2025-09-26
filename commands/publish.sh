#!/bin/bash
source utils/env.sh
source utils/git.sh
source utils/common.sh
source commands/sync.sh

publish() {
    validate_env
    get_current_branch

    # Parsear flags
    local flags_output=$(parse_flags "$@")
    local dry_run=$(echo "$flags_output" | cut -d' ' -f1)
    local force=$(echo "$flags_output" | cut -d' ' -f2)
    local verbose=$(echo "$flags_output" | cut -d' ' -f3)

    if [[ "$CURRENT_BRANCH" != "master" ]]; then
        echo "❌ Error: Debes estar en master para publicar. Usa 'sf merge' primero."
        return 1
    fi

    echo "🚀 Preparando publicación desde master"

    # Mostrar resumen de cambios pendientes
    echo "📊 Resumen de cambios por publicar:"
    echo "Rama: $CURRENT_BRANCH"
    echo "Cambios sin commit:"
    git status --porcelain
        
    if [[ "$dry_run" == true ]]; then
        echo "🔍 Modo dry-run: Simulando publicación..."
        echo "  ✅ Sincronizar con Shopify Admin"
        echo "  ✅ Publicar en Shopify"
        echo "  ✅ Subir cambios a remoto"
            
        echo "💡 Ejecuta sin --dry-run cuando estés listo para publicar."
        return 0
    fi

    # Validaciones críticas
    if [[ "$force" != true ]]; then
        check_uncommitted_changes
    fi

    # Ejecutar sync para sincronizar antes de publicar
    echo "🔄 Ejecutando sincronización antes de publicar..."
    if ! sync --force; then
        echo "❌ Error: Falló la sincronización. No se puede continuar con la publicación."
        return 1
    fi

    # Después de sync, estamos listos para publicar
    echo "📤 Publicando en Shopify..."
    shopify theme push -s "$SHOPIFY_STORE" -t "$SHOPIFY_THEME_ID" || {
        echo "❌ Error: Falló shopify theme push."
        echo "💡 Puedes intentar nuevamente o publicar manualmente."
        return 1
    }

    git push origin master || { echo "❌ Error: Falló git push."; return 1; }

    log_history "Published changes to Shopify"
    echo "✅ ¡Publicación completada exitosamente!"
    echo "🌐 Cambios publicados en: https://$SHOPIFY_STORE"

    suggest_next_steps "publish"
}