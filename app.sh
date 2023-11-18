#!/bin/bash
source menu.sh  # Logica de los menúes
source functions.sh # herramientas
source pedidos.sh # admin de pedidos
menu_pedidos="Menu - Lista de pedidos.\n1. Ingresar nuevo.\n2. Modificar pedido.\n3. Ver todos.\nq. Volver al menu principal.\n"
menu_principal="Menu - Principal.\n1. Administrar pedidos.\n2. Ver combos.\n3. Ver clientes.\nq. Salir.\n"
continuar="Presiona Enter para continuar..."
listaClientes=db/clientes.csv
listaCombos=db/combos.csv
pedidos_list="db/pedidos.csv"
pedidos_headers=("CODIGO" "USUARIO" "FECHA" "CLIENTE" "TEL" "COMBO" "CANT" "TOTAL")
logoFile="logo.txt"
clear
separador
if [ -f "$logoFile" ]; then
  logo=$(cat "$logoFile")
  echo "$logo"
  separador
fi
printf "\n**** BIENVENIDO AL CONTROL DE LA PIZZERA ****\n\n"
menuPrincipal