#!/bin/bash
source utils/env.sh
source utils/git.sh
source utils/ui.sh

status() {
    validate_env
    echo "📊 Estado del proyecto:"

    # Usar función de detección de estado
    detect_project_state

    echo ""
    echo "🔗 Shopify Store: $(color_text "1;34" "$SHOPIFY_STORE")"
    echo "🆔 Theme ID: $SHOPIFY_THEME_ID"
    echo ""
    echo "📋 Detalles de archivos:"

    # Mostrar archivos modificados pero no preparados
    local unstaged=$(git diff --name-only)
    if [[ -n "$unstaged" ]]; then
        echo "$(color_text "1;31" "✏️  Cambios sin preparar:")"
        echo "$unstaged" | sed 's/^/    /'
        echo ""
    fi

    # Mostrar archivos preparados para commit
    local staged=$(git diff --staged --name-only)
    if [[ -n "$staged" ]]; then
        echo "$(color_text "1;32" "📝 Cambios preparados:")"
        echo "$staged" | sed 's/^/    /'
        echo ""
    fi

    # Mostrar archivos no rastreados
    local untracked=$(git ls-files --others --exclude-standard)
    if [[ -n "$untracked" ]]; then
        echo "📄 Archivos no rastreados:"
        echo "$untracked" | sed 's/^/    /'
        echo ""
    fi

    echo "💡 Para verificar cambios en Shopify Admin:"
    echo "   shopify theme pull -s "$SHOPIFY_STORE" -t "$SHOPIFY_THEME_ID""
}