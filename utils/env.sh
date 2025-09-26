#!/bin/bash

# Función para cargar variables de entorno desde .env
load_env() {
    local env_file=".env"
    if [[ -f "$env_file" ]]; then
        source "$env_file"
    fi
}

# Función para validar dependencias
validate_dependencies() {
    local missing_deps=()

    # Verificar Git
    if ! command -v git &> /dev/null; then
        missing_deps+=("Git")
    fi

    # Verificar Shopify CLI
    if ! command -v shopify &> /dev/null; then
        missing_deps+=("Shopify CLI")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo "❌ Error: Las siguientes dependencias no están instaladas:"
        printf "  - %s\n" "${missing_deps[@]}"
            
        echo "Instala las dependencias faltantes:"
        echo "  - Git: https://git-scm.com/downloads"
        echo "  - Shopify CLI: https://shopify.dev/themes/tools/cli"
        exit 1
    fi
}

# Función para validar variables de entorno
validate_env() {
    if [[ -z "$SHOPIFY_STORE" || -z "$SHOPIFY_THEME_ID" ]]; then
        echo "❌ Error: Variables de entorno no configuradas"
            
        echo "Solución:"
        echo "1. Crea o edita el archivo .env en la raíz del proyecto:"
        echo "   SHOPIFY_STORE=\"tu-tienda.myshopify.com\""
        echo "   SHOPIFY_THEME_ID=\"123456789\""
            
        echo "2. O configura las variables en tu entorno:"
        echo "   export SHOPIFY_STORE=\"tu-tienda.myshopify.com\""
        echo "   export SHOPIFY_THEME_ID=\"123456789\""
            
        echo "Después de configurar, ejecuta el comando nuevamente."
        exit 1
    fi

    # Validar formato básico
    if [[ ! "$SHOPIFY_STORE" =~ \.myshopify\.com$ ]]; then
        echo "⚠️  Advertencia: SHOPIFY_STORE no parece una URL de Shopify válida"
        echo "   Esperado: algo.myshopify.com"
        echo "   Actual: $SHOPIFY_STORE"
    fi

    if [[ ! "$SHOPIFY_THEME_ID" =~ ^[0-9]+$ ]]; then
        echo "⚠️  Advertencia: SHOPIFY_THEME_ID debe ser un número"
        echo "   Actual: $SHOPIFY_THEME_ID"
    fi
}