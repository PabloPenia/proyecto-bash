#!/bin/bash
source menu.sh  # Logica de los menúes
source functions.sh # herramientas
source pedidos.sh # admin de pedidos
clear
if [ -f "$logoFile" ]; then
  centerImage $logoFile
fi
separador
printf "$bold"
center "**** BIENVENIDO AL CONTROL DE LA PIZZERA ****"
printf "$reset_bold"
separador
menuPrincipal