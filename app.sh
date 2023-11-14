#!/bin/bash
export TERM="dumb"
source functions.sh # importa el contenido de otro archivo
separador="------------------------"
while true; do
  clear
  echo "1. Lista de pedidos."
  echo "2. Lista de combos."
  echo "3. Lista de clientes."
  echo "q. Salir."
  read -p "Escoger opcion: " opt

  case $opt in
  1)
    menuListaPedidos
    ;;
  2)
    # https://losmateospizzeria.com.uy/menu/losmateospizzeria
    clear
    mostrarRegistrosCSV "combos.csv"
    read -p "Presiona Enter para continuar..."
    ;;
  3)
    clear
    mostrarRegistrosCSV "clientes.csv"
    read -p "Presiona Enter para continuar..."
    ;;
  "q")
    clear
    echo "Finalizando..."
    read -p "Presiona Enter para continuar..."
    exit 0
    ;;
  *)
    clear
    echo "$opt no es una opcion valida..."
    read -p "Presiona Enter para continuar..."
    ;;
  esac
done