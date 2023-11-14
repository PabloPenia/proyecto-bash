source pedidos.sh
listaClientes=./clientes.csv
function mostrarRegistrosCSV(){
# Funcion que imprime los datos de un CSV con cabeceras dinamicas
# $1 = archivo

  if [[ ! -f "$1" ]]; then
    # [[]] It supports logical operators like && (AND) and || (OR).
    echo "El archivo $1 no existe"
    return 1 # valor non-zero = error
  fi

  # read
  # -r trata backslashes como caracteres normales
  # -a miArray guarda todos los valores un array
  # La variable de entorno IFS que significa Internal Field Separator, sirve para indicar que valor se usa como separador.
  IFS=',' read -r -a headers < "$1" # lee la primer linea del archivo y guarda los campos en un array
  # Crea un array multidimensional
  # Cada elemento del array principal contiene una fila entera del CSV
  # Cada fila es un array de campos del archivo
  data=()  # inicializa array vacio
  while IFS=',' read -r -a row; do
    # '+=' agrega un elemento al array (tipo Array.push)
    data+=("${row[@]}") # agrega el array como elemento (2d array)
  # tail lee todo el archivo ignorando los headers
  done < <(tail -n +2 "$1")

  # calcular maximo ancho de las columnas
  # ${#headers[@]} todos los elementos del array
  # '#' si es un array cuenta los elementos (tipo Array.length)
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
}
function menuListaPedidos {
  while true; do
    clear
    echo "Menu - Lista de pedidos"
    echo "1. Ver todos los pedidos"
    echo "2. Agregar un pedido"
    echo "3. Modificar un pedido"
    echo "4. Dar de baja un pedido"
    echo "5. Buscar un pedido"
    echo "q. Volver al menu principal"
    read -p "Selecciona una opción: " opt

    case $opt in
      1)
        clear
        mostrarRegistrosCSV "pedidos.csv"
        read -p "Presiona Enter para continuar..."
        ;;
      2)
        clear
        echo "Agregar un pedido"
        cliente=$(buscarCliente)
        echo "enviar pedido a $cliente"
        read -p "Pedido finalizado. Presiona Enter para continuar..."
        ;;
      3)
        clear
        echo "Modificar un pedido"
        # Implement your logic to remove an item from the list
        read -p "Elemento modificado. Presiona Enter para continuar..."
        ;;
      4)
        clear
        echo "Eliminar un elemento de Lista de pedidos"
        # Implement your logic to remove an item from the list
        read -p "Elemento eliminado. Presiona Enter para continuar..."
        ;;
      5)
        clear
        echo "Eliminar un elemento de Lista de pedidos"
        # Implement your logic to remove an item from the list
        read -p "Elemento eliminado. Presiona Enter para continuar..."
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