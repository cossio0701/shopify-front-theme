#!/bin/bash
source scripts/utils/env.sh
source scripts/utils/ui.sh
source scripts/utils/git.sh
source scripts/utils/common.sh

start() {
    validate_env
    echo "🚀 Iniciando nuevo flujo de trabajo..."

    # Detectar estado actual
    echo "📊 Estado actual del proyecto:"
    detect_project_state

    get_current_branch

    # Validaciones preventivas
    if [[ "$CURRENT_BRANCH" != "master" ]]; then
            
        echo "⚠️  Ya estás en una rama de trabajo: $CURRENT_BRANCH"
        echo "¿Quieres continuar en esta rama o crear una nueva?"
        echo "1. Continuar en $CURRENT_BRANCH"
        echo "2. Crear nueva rama (cambiará a master primero)"
        echo "3. Cancelar"

        local choice
        read -p "Elige opción (1-3): " -n 1 -r choice
        echo

        case $choice in
            1)
                echo "✅ Continuando en rama actual: $CURRENT_BRANCH"
                suggest_next_steps "start" "existing-branch"
                return 0
                ;;
            2)
                echo "🔄 Cambiando a master para crear nueva rama..."
                git checkout master || { echo "❌ Error: No se pudo cambiar a master."; return 1; }
                ;;
            *)
                echo "🚫 Operación cancelada."
                return 1
                ;;
        esac
    fi

    # Verificar cambios sin commit antes de crear rama
    if ! git diff --quiet || ! git diff --staged --quiet; then
            
        echo "⚠️  Hay cambios sin commit en master."
        if ! confirm_action "¿Crear rama desde este estado?" "n" "Los cambios sin commit estarán en la nueva rama."; then
            echo "💡 Sugerencias:"
            echo "  - Confirma cambios: sf commit"
            echo "  - Guarda temporalmente: sf stash"
            return 1
        fi
    fi

    # Sincronizar con Shopify y remoto antes de crear rama
    echo "🔄 Sincronizando con Shopify y remoto..."
    source scripts/commands/sync.sh
    sync --force || { echo "❌ Error: Falló sincronización."; return 1; }

    # Menú interactivo para seleccionar tipo de flujo
    if ! interactive_menu; then
        return 1
    fi

    # Preguntar nombre descriptivo en kebab-case
    read -p "Nombre descriptivo (kebab-case): " name
    if [[ -z "$name" ]]; then
        echo "❌ Error: El nombre es obligatorio."
        return 1
    fi

    if [[ ! "$name" =~ ^[a-z0-9-]+(-[a-z0-9-]+)*$ ]]; then
        echo "❌ Error: Nombre debe estar en kebab-case (solo letras minúsculas, números y guiones)."
        echo "Ejemplos válidos: add-product-slider, fix-header-bug, update-styles"
        return 1
    fi

    # Generar nombre de rama
    local date_suffix=$(date '+%Y%m%d')
    local branch_name="${flow_type}/${name}-${date_suffix}"

    echo "📝 Creando rama: $branch_name"

    # Ejecutar comandos
    git checkout -b "$branch_name" || { echo "❌ Error: No se pudo crear la rama."; return 1; }
    shopify theme pull -s "$SHOPIFY_STORE" -t "$SHOPIFY_THEME_ID" || { echo "❌ Error: Falló shopify theme pull."; return 1; }
    git push -u origin "$branch_name" || { echo "❌ Error: Falló git push."; return 1; }

    log_history "Started branch: $branch_name"
    echo "✅ Rama '$branch_name' creada exitosamente."
        
    echo "🎯 Trabajo listo para comenzar en: $branch_name"

    suggest_next_steps "start"
}