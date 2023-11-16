source pedidos.sh
source menu.sh
listaClientes=db/clientes.csv
listaCombos=db/combos.csv
listaPedidos=db/pedidos.csv
function mostrarRegistrosCSV(){
  echo ""
  if [[ ! -f "$1" ]]; then
    echo "El archivo $1 no existe"
    return 1 # valor non-zero = error
  fi
  IFS=',' read -r -a headers < "$1"
  data=() 
  while IFS=',' read -r -a row; do
    data+=("${row[@]}") 
  done < <(tail -n +2 "$1")
  max_widths=()
  for ((i = 0; i < ${#headers[@]}; i++)); do
    max_width=0
    for ((j = 0; j < ${#data[@]}; j += ${#headers[@]})); do
      cell="${data[$j + i]}"
      cell_length=${#cell}
      if ((cell_length > max_width)); then
        max_width=$cell_length
      fi
    done
    max_widths+=("$max_width")
  done
  # Mostrar Cabeceras
  for ((i = 0; i < ${#headers[@]}; i++)); do
    printf "%-*s  " "${max_widths[$i]}" "${headers[$i]}"
  done
  echo

  # Mostrar Datos
  for ((i = 0; i < ${#data[@]}; i += ${#headers[@]})); do
    for ((j = 0; j < ${#headers[@]}; j++)); do
      cell="${data[$i + j]}"
      printf "%-*s  " "${max_widths[$j]}" "$cell"
    done
    echo
  done
  echo ""
}
function menuPedidos {
  while true; do
    clear
    printf "$menu_pedidos"    
    read -p "Selecciona una opción: " opt
    case $opt in
      1)
        clear
        echo "Agregar un pedido"
        ingresarPedido
        read -p "Pedido finalizado. $continuar"
        ;;
      2)
        clear
        echo "Modificar un pedido"
        # Implement your logic to remove an item from the list
        read -p "Elemento modificado. Presiona Enter para continuar..."
        ;;
      3)
        clear
        mostrarRegistrosCSV "db/pedidos.csv"
        read -p "Presiona Enter para continuar..."
        ;;
      "q")
        clear
        return
        ;;

      *)
        clear
        echo "$opt no es una opción válida..."
        read -p "Presiona Enter para continuar..."
        ;;
    esac
  done
}