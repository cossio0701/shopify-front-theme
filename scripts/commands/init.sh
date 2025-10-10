#!/bin/bash
source scripts/utils/env.sh
source scripts/utils/common.sh

init() {
    echo "🚀 Inicializando proyecto sf..."

    # Verificar si se fuerza reinicialización ANTES de cualquier análisis
    if [[ "$1" == "--force" ]]; then
        echo "🔄 Forzando reinicialización completa..."
            
    fi

    # Análisis inteligente del estado actual
    local needs_init=false
    local existing_config=""

    if [[ -f ".env" ]]; then
        existing_config+="✅ .env existe\n"
        source .env 2>/dev/null
        if [[ -n "$SHOPIFY_STORE" && -n "$SHOPIFY_THEME_ID" ]]; then
            existing_config+="✅ Variables de entorno configuradas\n"
        else
            existing_config+="⚠️  Variables de entorno incompletas\n"
            needs_init=true
        fi
    else
        existing_config+="❌ .env no existe\n"
        needs_init=true
    fi

    if [[ -x "sf" ]]; then
        existing_config+="✅ Script sf es ejecutable\n"
    else
        existing_config+="❌ Script sf no es ejecutable\n"
        needs_init=true
    fi

    if [[ -d ".git" ]]; then
        existing_config+="✅ Repositorio Git inicializado\n"
    else
        existing_config+="❌ Repositorio Git no inicializado\n"
        needs_init=true
    fi

    echo "📊 Estado actual del proyecto:"
    echo -e "$existing_config"

    if [[ "$needs_init" == false && "$1" != "--force" ]]; then
            
        echo "🎉 El proyecto ya está completamente inicializado."
        echo "💡 Si quieres reinicializar, ejecuta: sf init --force"
            
        echo "Para verificar configuración: sf status"
        return 0
    fi

    # Verificar confirmación (solo si no es --force)
    if [[ "$1" != "--force" ]]; then
            
        if ! confirm_action "¿Proceder con la inicialización?" "y"; then
            echo "🚫 Inicialización cancelada."
            return 1
        fi
    fi

    # 1. Verificar dependencias
        
    echo "📦 Verificando dependencias..."
    validate_dependencies

    # 2. Hacer script ejecutable
    echo "🔧 Configurando permisos del script..."
    chmod +x sf || { echo "❌ Error: No se pudieron configurar permisos."; return 1; }

    # 3. Crear .env si no existe
    if [[ ! -f ".env" ]]; then
        echo "📝 Creando archivo .env..."
        cat > .env << EOF
# Variables de entorno para el proyecto
# Configuración de Shopify
SHOPIFY_STORE="tu-tienda.myshopify.com"
SHOPIFY_THEME_ID="123456789"
EOF
        echo "✅ Archivo .env creado. Edítalo con tus valores reales."
    else
        echo "✅ Archivo .env ya existe."
    fi

    # 4. Verificar/inicializar repositorio Git
    if [[ ! -d ".git" ]]; then
        echo "📚 Inicializando repositorio Git..."
        git init || { echo "❌ Error: No se pudo inicializar Git."; return 1; }
        git checkout -b master 2>/dev/null || git switch -c master 2>/dev/null || { echo "❌ Error: No se pudo crear rama master."; return 1; }
        echo "✅ Repositorio Git inicializado."
    else
        echo "✅ Repositorio Git ya existe."
    fi

    # 5. Configurar alias
    echo "🔗 Configurando alias global..."
    local script_path="$(pwd)/sf"
    if ! grep -q "alias sf=" ~/.bashrc 2>/dev/null && ! grep -q "alias sf=" ~/.zshrc 2>/dev/null; then
        echo "alias sf=\"$script_path\"" >> ~/.bashrc
        source ~/.bashrc 2>/dev/null || true
        echo "✅ Alias configurado en ~/.bashrc"
        echo "💡 Reinicia tu terminal o ejecuta: source ~/.bashrc"
    else
        echo "✅ Alias ya configurado."
    fi

    # 6. Crear .gitignore si no existe
    if [[ ! -f ".gitignore" ]]; then
        echo "📄 Creando .gitignore básico..."
        cat > .gitignore << EOF
# sf
.env
.sf_history

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Logs
*.log
EOF
        echo "✅ Archivo .gitignore creado."
    fi

    log_history "Project initialized"
        
    echo "🎉 ¡Proyecto inicializado exitosamente!"
        
    echo "📋 Checklist completado:"
    echo "  ✅ Dependencias verificadas"
    echo "  ✅ Script configurado"
    echo "  ✅ Variables de entorno"
    echo "  ✅ Repositorio Git"
    echo "  ✅ Alias global"
    echo "  ✅ .gitignore"
        
    suggest_next_steps "init"
}