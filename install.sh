#!/bin/bash
install_dir="/usr/local/bin"
app="pizza-ctrl.sh"

if [ ! -f "$app" ]; then
  echo "Error: archivo no encontrado"
  exit 1
fi

cp