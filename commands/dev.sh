#!/bin/bash

source utils/env.sh
source utils/git.sh
source utils/common.sh

dev() {
    parse_flags "$@"
    
    echo "🚀 Iniciando servidor de desarrollo..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "🔍 [DRY-RUN] Verificando configuración para desarrollo..."
        return 0
    fi
    
    # Verificar que tenemos las variables necesarias
    if [[ -z "${SHOPIFY_STORE}" || -z "${SHOPIFY_THEME_ID}" ]]; then
        echo "❌ Variables SHOPIFY_STORE y SHOPIFY_THEME_ID deben estar configuradas"
        echo "Ejecuta: sf init"
        return 1
    fi
    
    # Verificar que shopify CLI esté disponible
    if ! command -v shopify >/dev/null 2>&1; then
        echo "❌ Shopify CLI no está instalado o no está en PATH"
        echo "Instala Shopify CLI: https://shopify.dev/themes/tools/cli"
        return 1
    fi
    
    echo "🌐 Conectando a tienda: ${SHOPIFY_STORE}"
    echo "🎨 Tema ID: ${SHOPIFY_THEME_ID}"
    echo ""
    
    # Iniciar servidor de desarrollo
    echo "🔧 Iniciando servidor de desarrollo de Shopify..."
    
    if shopify theme dev --store="${SHOPIFY_STORE}" --theme="${SHOPIFY_THEME_ID}"; then
        echo "✅ Servidor de desarrollo iniciado"
        log_history "dev" "Servidor de desarrollo iniciado para tema ${SHOPIFY_THEME_ID}"
    else
        echo "❌ Error al iniciar el servidor de desarrollo"
        echo "Verifica tu configuración de Shopify CLI"
        return 1
    fi
}