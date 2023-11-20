#!/bin/bash
source menu.sh  # Logica de los menúes
source functions.sh # herramientas
source pedidos.sh # admin de pedidos

clear
if [ -f "$logoFile" ]; then
  logo=$(cat "$logoFile")
  echo "$logo"
fi
separador
titulo "**** BIENVENIDO AL CONTROL DE LA PIZZERA ****"
separador
menuPrincipal