#!/bin/bash

source utils/env.sh
source utils/git.sh
source utils/common.sh

backup() {
    parse_flags "$@"
    
    echo "💾 Gestionando copias de seguridad..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "🔍 [DRY-RUN] Verificando estado para backup..."
        return 0
    fi
    
    local backup_dir=".sf_backups"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="backup_$timestamp"
    
    # Crear directorio de backups si no existe
    mkdir -p "$backup_dir"
    
    echo "📦 Creando backup: $backup_name"
    
    # Crear archivo de backup con información del proyecto
    local backup_file="$backup_dir/$backup_name.txt"
    
    {
        echo "=== SF BACKUP ==="
        echo "Fecha: $(date)"
        echo "Usuario: $(whoami)"
        echo "Directorio: $(pwd)"
        echo ""
        
        echo "=== ESTADO DE GIT ==="
        echo "Rama actual: $(get_current_branch)"
        echo "Estado del working directory:"
        git status --porcelain
        echo ""
        
        echo "=== CONFIGURACIÓN ==="
        echo "SHOPIFY_STORE: ${SHOPIFY_STORE:-No configurado}"
        echo "SHOPIFY_THEME_ID: ${SHOPIFY_THEME_ID:-No configurado}"
        echo ""
        
        echo "=== RAMAS ==="
        git branch -a
        echo ""
        
        echo "=== ÚLTIMOS COMMITS ==="
        git log --oneline -10
        echo ""
        
    } > "$backup_file"
    
    echo "✅ Backup creado: $backup_file"
    log_history "backup" "Backup creado: $backup_name"
    
    # Listar backups existentes
    echo "📋 Backups disponibles:"
    ls -la "$backup_dir"/backup_*.txt 2>/dev/null | head -5
    
    suggest_next_steps "Backup completado"
}