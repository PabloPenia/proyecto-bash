#!/bin/bash
source menu.sh
source functions.sh # importa el contenido de otro archivo
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