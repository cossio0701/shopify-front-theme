#!/bin/bash

source utils/env.sh
source utils/git.sh
source utils/common.sh

diff() {
    parse_flags "$@"
    
    echo "🔍 Comparando diferencias..."
    
    local target="${1:-HEAD}"
    local source="${2:-}"
    
    if [[ -n "$source" ]]; then
        echo "Comparando $source con $target..."
        git diff "$source" "$target"
    else
        echo "Mostrando cambios en $target..."
        git diff "$target"
    fi
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Comparación completada"
    else
        echo "❌ Error al mostrar diferencias"
        return 1
    fi
}