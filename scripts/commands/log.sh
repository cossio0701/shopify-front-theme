#!/bin/bash

source scripts/utils/env.sh
source scripts/utils/git.sh
source scripts/utils/common.sh

log() {
    local limit="${1:-10}"
    
    echo "📜 Historial de acciones de sf"
    echo "========================================"
    
    # Mostrar historial de sf
    if [[ -f ".sf_history" ]]; then
        echo "Historial de sf:"
        tail -n "$limit" ".sf_history" | while IFS='|' read -r timestamp command details; do
            echo "📅 $(date -d "@$timestamp" '+%Y-%m-%d %H:%M:%S') | $command | $details"
        done
    else
        echo "ℹ️  No hay historial de sf disponible"
    fi
    
    echo ""
    echo "📋 Historial de Git (últimos $limit commits):"
    echo "----------------------------------------"
    
    if git log --oneline -n "$limit" 2>/dev/null; then
        echo ""
        echo "✅ Historial mostrado exitosamente"
    else
        echo "ℹ️  No hay commits en el repositorio"
    fi
}