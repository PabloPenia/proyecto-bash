#!/bin/bash
source menu.sh
source functions.sh # importa el contenido de otro archivo
separador="------------------------"
while true; do
  clear
  printf "$menu_principal"
  read -p "Escoger opcion: " opt
  case $opt in
  1)
    menuPedidos
    ;;
  2)
    # https://losmateospizzeria.com.uy/menu/losmateospizzeria
    clear
    mostrarRegistrosCSV "$listaCombos"
    read -p "$continuar"
    ;;
  3)
    clear
    mostrarRegistrosCSV "$listaClientes"
    read -p "$continuar"
    ;;
  "q")
    clear
    echo "Finalizando..."
    read -p "$continuar"
    exit 0
    ;;
  *)
    clear
    echo "$opt no es una opcion valida..."
    read -p "$continuar"
    ;;
  esac
done