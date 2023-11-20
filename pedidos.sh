search_txt="Ingrese término de búsqueda o q para cancelar. "
editPedido() {
  local user_input
  read -p "$search_txt" user_input
  local result=$(getRegister "$user_input" "$pedidos_list")

  if [ -n "$result" ]; then
    echo $result
  else
    clear
    printf "No existen registros que coincidan con '%s'. Intentelo nuevamente..." "$user_input"
    sleep 3
    separador
    echo "Modificar un pedido"
    separador
    editPedido
  fi
}
ingresarPedido() {
  # TODO: manejar caso con la fecha de argumento
  mkdir -p .temp
  local fecha=$(date +"%d-%m-%Y-%H%M%S")
  local file=.temp/$fecha
  local current_user="$USER"
  num_orden="ORD001"
  ultimo_pedido=$(awk -F',' 'NR>1 {firstField=$1} END{if (NR>1) print firstField}' "$pedidos_list")
  if [ -n $ultimo_pedido ]; then
    num=$(echo "$ultimo_pedido" | sed 's/ORD//')
    newNum=$(($num + 1))
    num_orden="ORD$(printf "%03d" "$newNum")"    
  fi
  seleccionarCliente "$file"
  # seleccionarCombo "$file"
  # echo "Verifique si los datos son correctos"
  # mostrarRegistrosCSV "$file"
  # read -p "Agregar pedido a la base de datos? (responde s/n) " resp
  # if [ "$resp" == "s" ]; then
  #   pedido=$(tail -n +2 "$file")
  #   echo "$num_orden,$current_user,$fecha,$pedido" >> $pedidos_list
  #   rm $file
  #   echo "Pedido ingresado correctamente"
  #   sleep 5
  #   menuPedidos
  # else
  #   clear
  #   echo "El pedido se ha cancelado"
  #   rm $file
  #   sleep 5
  #   menuPedidos
  # fi
  read -p "$continuar"
}
# seleccionarCliente() {
#   local user_input
#   read -p "$search_txt" user_input

#   if [ "$user_input" == "q" ]; then
#     menuPedidos
#   fi

#   local resultado=($(getRegister "$user_input" "$clientes_list"))
#     printf "${resultado[@]}"

#   if [ "${#resultado[@]}" -gt 0 ]; then
#     displayRegisters "$clientes_headers" "${resultado[@]}"
#   else
#     echo "No existen registros para su búsqueda. Inténtelo nuevamente."
#     sleep 5
#     seleccionarCliente "$1"
#   fi
# }
seleccionarCliente() {
  echo "Ingrese término de búsqueda o q para cancelar."
  read -r search_term

  if [ "$search_term" == "q" ]; then
    echo "Búsqueda cancelada."
  else
    # Create a temporary file based on the current date and time
    local fecha=$(date +"%d-%m-%Y-%H%M%S")
    local temp_file=".temp/$fecha.txt"

    # Call getRegister and pass the search term and temporary file
    getRegister "$search_term" "$clientes_list" "$temp_file"

    # Display the results using displayCsvRegisters
    displayCsvRegisters "CODIGO,NOMBRE,TELEFONO" "$temp_file"
  fi
}




seleccionarCombo() {
  mostrarRegistrosCSV "$listaCombos"
  local combo
  read -p "Ingrese el codigo del combo o q para cancelar " combo
  combo="${combo,,}"
  if [ "$combo" == "q" ]; then
    rm "$1"
    menuPedidos
  fi
  combo="${combo^^}"
  local resultado=$(grep -i "$combo" "$listaCombos")
  lines=$(echo "$resultado" | wc -l)
  if [[ -n "$resultado" && "$lines" -eq 1 ]]; then
    local cantidad=0
    local precio="${resultado##*,}"
    while true; do
      read -p "Ingrese cantidad de $combo " userQty
      if esCantidadValida "$userQty" ; then
        cantidad=$userQty
        break
      else
        clear
        echo "Debe ingresar un numero mayor de 0."
      fi
    done
    local total=$((cantidad * precio))

    printf "Confirmar Combo %s X%d por un total de %d?. (responde s/n) " "$combo" "$cantidad" "$total"
  read respuesta
  respuesta="${respuesta,,}"
  if [ "$respuesta" == "s" ]; then
    local item="$combo,$cantidad,$total"
    echo "$item" >> $1
  else
    clear
    seleccionarCombo "$1"
  fi
  else
    clear
    printf "El combo %s no existe, intentelo nuevamente.\n" "$combo"
    seleccionarCombo "$1"
  fi
}
esCantidadValida() {
  [[ $1 =~ ^[1-9][0-9]*$ ]]
}
