#!/bin/bash

source scripts/utils/env.sh
source scripts/utils/git.sh
source scripts/utils/common.sh

help() {
    echo "sf - Shopify Flow CLI"
    echo "Comandos disponibles:"
    echo "  init     - Inicializar un nuevo proyecto Shopify"
    echo "  start    - Crear y cambiar a una nueva rama"
    echo "  commit   - Hacer commit de cambios"
    echo "  sync     - Sincronizar con Shopify (pull, resolver conflictos, push)"
    echo "  merge    - Merge a master y sync"
    echo "  publish  - Push a Shopify"
    echo "  resolve  - Resolver conflictos"
    echo "  status   - Mostrar estado del proyecto"
    echo "  finish   - Eliminar rama actual después de publicar"
    echo "  stash    - Guardar cambios locales en stash"
    echo "  log      - Mostrar historial de sf y Git"
    echo "  diff     - Comparar diferencias entre ramas/commits"
    echo "  clean    - Remover ramas merged"
    echo "  backup   - Crear backups del estado del proyecto"
    echo "  pr       - Preparar información de Pull Request"
    echo "  dev      - Iniciar servidor de desarrollo local"
    echo "  help     - Mostrar esta ayuda"
    echo ""
    echo "Flags globales:"
    echo "  --dry-run  - Ejecutar en modo simulación"
    echo "  --force    - Forzar operaciones"
    echo "  --help     - Mostrar ayuda"
}

"$@"
