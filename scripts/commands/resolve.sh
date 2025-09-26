#!/bin/bash
source scripts/utils/env.sh
source scripts/utils/git.sh
source scripts/utils/common.sh

resolve() {
    validate_env
    echo "🔧 Resolviendo conflictos y confirmando cambios..."

    get_current_branch

    # Verificar que estamos en master
    if [[ "$CURRENT_BRANCH" != "master" ]]; then
        echo "❌ Error: Debes estar en la rama master para resolver conflictos."
        echo "💡 Cambia a master: git checkout master"
        return 1
    fi

    # Verificar que estamos en medio de un merge o hay cambios para confirmar
    if git diff --quiet && git diff --staged --quiet && ! [[ -f .git/MERGE_HEAD ]]; then
        echo "ℹ️  No hay conflictos pendientes ni cambios para confirmar."
        echo ""
        echo "📊 Estado actual del repositorio:"
        detect_project_state
        echo ""
        echo "💡 Si quieres sincronizar los cambios actuales con Shopify Admin:"
        echo "   sf publish"
        echo ""
        echo "💡 O si tienes cambios en una rama de trabajo, considera:"
        echo "   sf merge  # Para fusionar cambios desde una rama de trabajo"
        return 0
    fi

    # Agregar todos los cambios
    echo "📝 Agregando archivos resueltos..."
    git add . || { echo "❌ Error: Falló git add."; return 1; }

    # Confirmar con mensaje específico
    local commit_message="resolve: conflictos de merge"
    echo "✅ Confirmando cambios con mensaje: '$commit_message'"
    git commit -m "$commit_message" || { echo "❌ Error: Falló git commit."; return 1; }

    # Publicar cambios a remoto
    echo "📤 Publicando cambios a remoto..."
    git push origin master || { echo "❌ Error: Falló git push."; return 1; }

    log_history "Resolved conflicts and committed changes"
    echo "✅ Conflictos resueltos y confirmados exitosamente."
    echo ""
    echo "💡 Próximos pasos recomendados:"
    echo "1. Prueba los cambios localmente: sf dev --test"
    echo "2. Si todo funciona bien, publica a Shopify: sf publish"
    echo "3. Inicia nuevo trabajo: sf start"

    # No llamar a suggest_next_steps aquí, ya que damos sugerencias específicas
}