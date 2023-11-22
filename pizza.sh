#!/bin/bash
source "./src/menu.sh"  # Logica de los menúes
source "./src/functions.sh" # herramientas
source "./src/pedidos.sh" # admin de pedidos

temp_dir="./src/.temp"
current_user="$USER"
mkdir -p "$temp_dir"
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  showHelp
  exit 0
fi
menuPrincipal