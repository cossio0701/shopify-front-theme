#!/bin/bash

# Función para verificar si la terminal soporta colores
supports_colors() {
    # Forzar colores ANSI siempre
    return 0
}

# Función para colorear texto si es soportado
color_text() {
    local color_code="$1"
    local text="$2"

    if supports_colors; then
        echo -e "\033[${color_code}m${text}\033[0m"
    else
        # Si no hay colores, usar mayúsculas y símbolos para resaltar
        case "$color_code" in
            "1;31") echo "❌ $text" ;;  # Rojo -> Error symbol
            "1;32") echo "✅ $text" ;;  # Verde -> Success symbol
            "1;33") echo "⚠️  $text" ;;  # Amarillo -> Warning symbol
            "1;34") echo "ℹ️  $text" ;;  # Azul -> Info symbol
            *) echo "$text" ;;
        esac
    fi
}

# Función para confirmar acción
confirm_action() {
    local prompt="$1"
    local default="${2:-n}"  # Default a 'n' si no se especifica
    local help_text="$3"

        
    echo "⚠️  $prompt"
    if [[ -n "$help_text" ]]; then
        echo "$help_text"
    fi

    local response
    read -p "¿Continuar? (y/N): " -n 1 -r response
    echo

    if [[ "$default" == "y" ]]; then
        [[ ! "$response" =~ ^[Nn]$ ]]
    else
        [[ "$response" =~ ^[Yy]$ ]]
    fi
}

# Función para menú interactivo con flechas
interactive_menu() {
    local options=("fix:Corrección de errores" "feat:Nueva funcionalidad" "hotfix:Corrección urgente en producción" "refactor:Refactorización de código" "docs:Cambios en documentación" "style:Cambios de estilo/formato" "test:Cambios en tests" "chore:Tareas de mantenimiento")
    local selected=0
    local key=""

    # Función para dibujar el menú
    draw_menu() {
        echo -e "\nSelecciona el tipo de flujo (usa ↑↓ flechas, Enter para seleccionar):"
        for i in "${!options[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo -e "  \e[7m${options[$i]}\e[0m"  # Resaltado inverso
            else
                echo "  ${options[$i]}"
            fi
        done
        echo
    }

    # Ocultar cursor
    echo -e "\e[?25l"

    # Bucle principal
    while true; do
        draw_menu
        read -sn1 key

        case "$key" in
            $'\e')  # Escape sequence
                read -sn2 -t 0.1 key2
                case "$key2" in
                    '[A')  # Flecha arriba
                        ((selected--))
                        if [[ $selected -lt 0 ]]; then
                            selected=$((${#options[@]} - 1))
                        fi
                        ;;
                    '[B')  # Flecha abajo
                        ((selected++))
                        if [[ $selected -ge ${#options[@]} ]]; then
                            selected=0
                        fi
                        ;;
                esac
                ;;
            '')  # Enter
                break
                ;;
            'q'|'Q')  # Salir con q
                echo -e "\e[?25h"  # Mostrar cursor
                echo "🚫 Operación cancelada."
                return 1
                ;;
        esac

        # Limpiar pantalla hacia arriba
        echo -e "\e[${#options[@]}A\e[J"
    done

    # Mostrar cursor
    echo -e "\e[?25h"

    # Extraer el tipo del option seleccionado
    local selected_option="${options[$selected]}"
    flow_type="${selected_option%%:*}"
    
    echo "✅ Seleccionado: $flow_type"
}