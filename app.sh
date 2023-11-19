#!/bin/bash
source menu.sh  # Logica de los menúes
source functions.sh # herramientas
source pedidos.sh # admin de pedidos

continuar="Presiona Enter para continuar..."
clientes_headers="CODIGO,NOMBRE,TELEFONO"
clientes_list="db/clientes.csv"
combos_headers="CODIGO,NOMBRE,DETALLE,PRECIO"
combos_list="db/combos.csv"
pedidos_headers="CODIGO,USUARIO,FECHA,CLIENTE,TEL,COMBO,CANT,TOTAL"
pedidos_list="db/pedidos.csv"
logoFile="logo.txt"
menu_pedidos="Menu - Lista de pedidos.\n1. Ingresar nuevo.\n2. Modificar pedido.\n3. Ver todos.\nq. Volver al menu principal.\n"
menu_principal="1. Administrar pedidos.\n2. Ver combos.\n3. Ver clientes.\nq. Salir.\n"

clear
if [ -f "$logoFile" ]; then
  logo=$(cat "$logoFile")
  echo "$logo"
fi
separador
titulo "**** BIENVENIDO AL CONTROL DE LA PIZZERA ****"
separador
menuPrincipal