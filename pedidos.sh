search_txt="Ingrese término de búsqueda o q para cancelar. "
temp_search_file=.temp/search
current_user="someone"
ingresarPedido() {
  # TODO: manejar caso con la fecha de argumento
  mkdir -p .temp
  local fecha=$(date +"%d-%m-%Y-%H%M%S")
  local temp_file=.temp/$fecha
  # local current_user="$USER"
  num_orden="ORD001"
  ultimo_pedido=$(awk -F',' '!/^ *$/ {firstField=$1} END {print firstField}' "$pedidos_list")
  if [ -n $ultimo_pedido ]; then
    num=$(echo "$ultimo_pedido" | sed 's/ORD//')
    newNum=$(($num + 1))
    num_orden="ORD$(printf "%03d" "$newNum")"    
  fi
  echo -n "$num_orden,$fecha,$current_user" > $temp_file 
  seleccionarCliente "$temp_file"
  seleccionarCombo "$temp_file"
  echo "Verifique si los datos son correctos"
  displayCsvRegisters "$pedidos_headers" "$temp_file"
  read -p "Agregar pedido a la base de datos? (responde s/n) " resp
  if [ "$resp" == "s" ]; then
    pedido=$(< $temp_file)
    echo "$pedido" >> $pedidos_list
    rm .temp/*
    echo "Pedido ingresado correctamente"
    sleep 3
    menuPedidos
  else
    clear
    echo "El pedido se ha cancelado"
    rm .temp/*
    sleep 3
    menuPedidos
  fi
  read -p "$continuar"
}
editPedido() {
  mkdir -p .temp
  local user_input
  local fecha=$(date +"%d-%m-%Y-%H%M%S")
  local temp_file=.temp/$fecha
  read -p "$search_txt" user_input
  getRegister "$user_input" "$pedidos_list" "$temp_search_file"
  displayCsvRegisters "$pedidos_headers" "$temp_search_file"
  local num_results=$(wc -l < "$temp_search_file")
  echo "$num_results"
  if [ "$num_results" -eq 1 ]; then
    local code_orden=$(awk -F, '{print $1}' "$temp_search_file")
    read -p "Continuar con pedido "$code_orden"? (responde s/n) " user_input
    if  [ "${user_input,,}" == "n" ]; then
      clear
      editPedido
    else
      echo -n "$code_orden,$fecha,$current_user" > $temp_file 
      while true; do
        clear
        printf "$menu_editar_pedido"    
        read -p "Selecciona una opción: " opt
        case $opt in
          1)
            # TODO: Agregar datos del cliente
            clear
            separador
            echo "Modificar el combo"
            separador
            seleccionarCombo "$temp_file"
            echo "Verifique si los nuevos datos son correctos"
            displayCsvRegisters "$pedidos_headers" "$temp_file"
            read -p "Modificar pedido en la base de datos? (responde s/n) " resp
            if [ "$resp" == "s" ]; then
              awk -F, 'NR==FNR {data[$1]=$0; next} {if ($1 in data) print data[$1]; else print $0}' "$temp_file" "$pedidos_list" > ".temp/pedidos_modified.csv"
              mv .temp/pedidos_modified.csv "$pedidos_list"
              rm .temp/*
              echo "Pedido modificado correctamente"
              sleep 3
              menuPedidos
            else
              clear
              echo "Se ha cancelado la modificacion del pedido."
              rm .temp/*
              sleep 3
              menuPedidos
            fi
            read -p "Pedido modificado. $continuar"
            ;;
          2)
            # TODO: Agregar campo a la BD
            clear
            separador
            echo "Marcar como entregado"
            separador
            marcarEntregado
            read -p "Pedido marcado como entregado. $continuar"
            ;;
          3)
            # TODO: Borrar row
            clear
            separador
            echo "eliminar"
            separador
            eliminarPedido
            read -p "Pedido marcado como entregado. $continuar"
            ;;
          "q")
            clear
            editPedido
            ;;

          *)
            clear
            echo "$opt no es una opción válida..."
            read -p "Presiona Enter para continuar..."
            ;;
        esac
      done
    fi
  elif [ "$num_results" -gt 1 ]; then
    echo "Demasiados registros intente acortar la busqueda ingresando el codigo del pedido."
    rm .temp/*
    editPedido
  else
    echo "No hay registros que coincidan con $user_input. Intentelo nuevamente"
    editPedido
  fi
}
seleccionarCliente() {
  local search_term
  local user_input
  local file="$1"
  read -p "Ingrese término de búsqueda o q para cancelar. " search_term

  if [ "${search_term,,}" == "q" ]; then
    echo "Búsqueda cancelada."
    sleep 3
    menuPedidos
  else
    getRegister "$search_term" "$clientes_list" "$temp_search_file"
    # Display the results using displayCsvRegisters
    displayCsvRegisters "$clientes_headers" "$temp_search_file"
    local num_results=$(wc -l < "$temp_search_file")
    if [ "$num_results" -eq 1 ]; then
      # continue
      local code_cliente=$(awk -F, '{print $1}' "$temp_search_file")
      local tel_cliente=$(awk -F, '{print $NF}' "$temp_search_file")
      read -p "Continuar con cliente "$code_cliente"? (responde s/n) " user_input
      if  [ "${user_input,,}" == "n" ]; then
        clear
        seleccionarCliente
      else
        echo -n ",$code_cliente,$tel_cliente" >> $file
      fi
    elif [ "$num_results" -gt 1 ]; then
      echo "Demasiados registros intenete acortar la busqueda ingresando el codigo de cliente."
      rm .temp/*
      seleccionarCliente "$file"
    else
      echo "No hay registros que coincidan con $user_input. Intentelo nuevamente"
      seleccionarCliente "$file"
    fi
  fi
}

seleccionarCombo() {
  local user_input
  local file=$1
  displayCsvRegisters "$combos_headers" "$combos_list"
  read -p "Ingrese el codigo del combo o q para cancelar " user_input
  if [ "${combo,,}" == "q" ]; then
    rm .tmp/*
    menuPedidos
  else
    getRegister "$user_input" "$combos_list" "$temp_search_file"
    local num_results=$(wc -l < "$temp_search_file")
    if [ "$num_results" -eq 1 ]; then
      local code_combo=$(awk -F, '{print $1}' "$temp_search_file")
      local precio_combo=$(awk -F, '{print $NF}' "$temp_search_file")
      local cantidad=0
      local total=0
      while true; do
        read -p "Ingresar cantidad de $code_combo "  user_input
        if esCantidadValida "$user_input" ; then
          cantidad=$user_input
          break
        else
          clear
          echo "Debe ingresar un numero mayor de 0."
        fi
      done
      total=$((cantidad * precio_combo))
      printf "Confirmar Combo %s X%d por un total de %d?. (responde s/n) " "$code_combo" "$cantidad" "$total"
      read user_input
      if [ "${user_input,,}" == "s" ]; then
        echo ",$code_combo,$cantidad,$total" >> $file
      else
        clear
        seleccionarCombo "$file"
      fi
    else
      clear
      printf "El combo %s no existe, intentelo nuevamente.\n" "$code_combo"
      seleccionarCombo "$1"
    fi
  fi
}
esCantidadValida() {
  [[ $1 =~ ^[1-9][0-9]*$ ]]
}
marcarEntregado() {
  echo ""
}

eliminarPedido() {
  echo ""
}