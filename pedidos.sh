temp_search_file=.temp/search
# current_user="$USER"
current_user="windows"

ingresarPedido() {
  mkdir -p .temp
  local fecha=$(date +"%d-%m-%Y-%H%M%S")
  local temp_file=.temp/$fecha
  local num_orden="ORD001" # si no hay ninguna creada utiliza esta
  local ultimo_pedido=$(awk -F',' '!/^ *$/ {firstField=$1} END {print firstField}' "$pedidos_list")

  if [ -n $ultimo_pedido ]; then
    num=$(echo "$ultimo_pedido" | sed 's/ORD//')
    newNum=$(($num + 1))
    num_orden="ORD$(printf "%03d" "$newNum")"    
  fi

  echo -n "$num_orden,$fecha,$current_user" > $temp_file
  printf "\n"
  seleccionarCliente "$temp_file"
  seleccionarCombo "$temp_file"
  echo ",PENDIENTE" >> $temp_file
  success "Verifique si los datos son correctos\n"
  displayCsvRegisters "$pedidos_headers" "$temp_file"
  read -p "Agregar pedido a la base de datos? (responde s/n) " resp

  if [ "$resp" == "s" ]; then
    pedido=$(< $temp_file)
    echo "$pedido" >> $pedidos_list
    borrarTemporales
    success "Pedido ingresado correctamente"
    sleep 3
    menuPedidos
  else
    clear
    error "El pedido se ha cancelado"
    borrarTemporales
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
  if [ "${user_input,,}" == "q" ]; then
    error "Búsqueda cancelada.\n"
    sleep 3
    menuPedidos
  else
    getRegister "$user_input" "$pedidos_list" "$temp_search_file"
    displayCsvRegisters "$pedidos_headers" "$temp_search_file"
    local num_results=$(wc -l < "$temp_search_file")
    if [ "$num_results" -eq 1 ]; then
      local code_orden=$(awk -F, '{print $1}' "$temp_search_file")
      local code_cliente=$(awk -F, '{print $4}' "$temp_search_file")
      local tel_cliente=$(awk -F, '{print $5}' "$temp_search_file")

      read -p "Continuar con pedido "$code_orden"? (responde s/n) " user_input
      if  [ "${user_input,,}" == "n" ]; then
        menuPedidos
      else
        echo -n "$code_orden,$fecha,$current_user,$code_cliente,$tel_cliente" > $temp_file 
        while true; do
          clear
          header "Modificar Pedido"
          printf "$menu_editar_pedido"    
          read -p "Selecciona una opción: " opt
          case $opt in
            1)
              clear
              header "Modificar el combo"
              seleccionarCombo "$temp_file"
              echo ",PENDIENTE" >> $temp_file
              echo "Verifique si los nuevos datos son correctos"
              displayCsvRegisters "$pedidos_headers" "$temp_file"
              read -p "Modificar pedido en la base de datos? (responde s/n) " resp
              if [ "$resp" == "s" ]; then
                awk -F, 'NR==FNR {data[$1]=$0; next} {if ($1 in data) print data[$1]; else print $0}' "$temp_file" "$pedidos_list" > ".temp/pedidos_modified.csv"
                mv .temp/pedidos_modified.csv "$pedidos_list"
                borrarTemporales
                success "Pedido modificado correctamente\n"
                read -p "$continuar"
                menuPedidos
              else
                clear
                error "Se ha cancelado la modificacion del pedido.\n"
                borrarTemporales
                read -p "$continuar"
                menuPedidos
              fi
              ;;
            2)
              clear
              header "Marcar como entregado"
              local code_combo=$(awk -F, '{print $6}' "$temp_search_file")
              local cantidad=$(awk -F, '{print $7}' "$temp_search_file")
              local total=$(awk -F, '{print $8}' "$temp_search_file")
              error "Esta seguro que quiere marcar este pedido como entregado?\n"
              displayCsvRegisters "$pedidos_headers" "$temp_search_file"
              read -p " (responde s/n) " resp
              echo -n ",$code_combo,$cantidad,$total" >> $temp_file
              if [ "$resp" == "s" ]; then
                echo ",ENTREGADO" >> $temp_file
                awk -F, 'NR==FNR {data[$1]=$0; next} {if ($1 in data) print data[$1]; else print $0}' "$temp_file" "$pedidos_list" > ".temp/pedidos_modified.csv"
                mv ".temp/pedidos_modified.csv" "$pedidos_list"
                borrarTemporales
                success "Pedido marcado como entregado.\n"
                sleep 3
                menuPedidos
              else
                clear
                error "Accion cancelada.\n"
                borrarTemporales
                read -p "$continuar"
                menuPedidos
              fi
              ;;
            3)
              clear
              header "Cancelar pedido"
              local pedido_eliminar=$(<"$temp_search_file" tr -d '\n')
              error "Esta seguro que quiere eliminar este pedido de la base de datos?\n"
              displayCsvRegisters "$pedidos_headers" "$pedido_eliminar"
              read -p " (responde s/n) " resp
              if [ "$resp" == "s" ]; then
                local temp_file=.temp/delete
                awk -v content="$pedido_eliminar" '$0 != content' "$pedidos_list" > "$temp_file"
                mv "$temp_file" "$pedidos_list"
                borrarTemporales
                success "Pedido eliminado correctamente.\n"
                borrarTemporales
                sleep 3
                menuPedidos
              else
                error "Accion cancelada.\n"
                sleep 3
                borrarTemporales
                menuPedidos
              fi            
              ;;
            "q") 
              menuPedidos
              ;;

            *)
              clear
              error "$opt no es una opción válida\n"
              read -p "$continuar"
              ;;
          esac
        done
      fi
    fi
  elif [ "$num_results" -gt 1 ]; then
    error "Demasiados registros intente acortar la busqueda ingresando el codigo del pedido.\n"
    borrarTemporales
    editPedido
  else
    editPedido
  fi
}
seleccionarCliente() {
  local search_term
  local user_input
  local file="$1"
  read -p "Ingrese término de búsqueda o q para cancelar. " search_term

  if [ "${search_term,,}" == "q" ]; then
    error "Búsqueda cancelada."
    sleep 3
    menuPedidos
  fi
  getRegister "$search_term" "$clientes_list" "$temp_search_file"
  displayCsvRegisters "$clientes_headers" "$temp_search_file"
  local num_results=$(wc -l < "$temp_search_file")
  if [ "$num_results" -eq 1 ]; then
    local code_cliente=$(awk -F, '{print $1}' "$temp_search_file")
    local tel_cliente=$(awk -F, '{print $NF}' "$temp_search_file")
    read -p "Continuar con cliente "$code_cliente"? (responde s/n) " user_input
    if  [ "${user_input,,}" == "n" ]; then
      seleccionarCliente
    fi
    echo -n ",$code_cliente,$tel_cliente" >> $file
  elif [ "$num_results" -gt 1 ]; then
    error "Demasiados registros intenete acortar la busqueda ingresando el codigo de cliente.\n"
    seleccionarCliente "$file"
  else
    seleccionarCliente "$file"
  fi
}

seleccionarCombo() {
  local user_input
  local file=$1
  displayCsvRegisters "$combos_headers" "$combos_list"
  read -p "Ingrese el codigo del combo o q para cancelar " user_input
  if [ "${user_input,,}" == "q" ]; then
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
          error "Debe ingresar un numero mayor de 0.\n"
        fi
      done
      total=$((cantidad * precio_combo))
      echo -n ",$code_combo,$cantidad","$total" >> $file
    else
      clear
      error "El combo no existe, intentelo nuevamente.\n" "$code_combo"
      seleccionarCombo "$1"
    fi
  fi
}
getResumen() {
  while true; do
        clear
        header "Resumen de ventas"
        printf "$menu_resumen"    
        read -p "Selecciona una opción: " opt
        case $opt in
          1)
            clear
            header "Ventas por combo"            
            getVentasPorCombo
            ;;
          2)
            clear
            header "Compras por cliente"
            ;;
          3)
            clear
            header "Pedidos por cliente"
            ;;
          4)
            clear
            header "Ventas por usuario"
            ;;
          "q") 
            menuPedidos
            ;;

          *)
            clear
            error "$opt no es una opción válida\n"
            read -p "$continuar"
            ;;
        esac
      done
}
getVentasPorCombo() {
  local user_input
  read -p "Ingrese el codigo del combo, o q para cancelar " user_input
  if [ "${user_input,,}" == "q" ]; then
    getResumen
  else
    if awk -F, -v id="user_input" '{if ($1 == id) found = 1} END {exit !found}' "$combos_list"; then
      success "El combo existe"
    else
      clear
      error "No existe ningun combo con el codigo $user_input en la bae de datos. Intentelo nuevamente"
      sleep 3
      getVentasPorCombo
    fi
  fi

}