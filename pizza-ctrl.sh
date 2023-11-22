#!/bin/bash
source menu.sh  # Logica de los menúes
source functions.sh # herramientas
source pedidos.sh # admin de pedidos
temp_dir=".tmp"
# current_user="$USER"
current_user="$USER"
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  showHelp
  exit 0
fi
menuPrincipal