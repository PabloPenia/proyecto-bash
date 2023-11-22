ingresarPedido() {
  local fecha=$(date +"%d-%m-%Y-%H%M%S")
  local temp_file=$(mktemp --tmpdir="$temp_dir")
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
  echo ",PENDIENTE" >> "$temp_file"
  success "Verifique si los datos son correctos\n"
  displayCsvRegisters "$pedidos_headers" "$temp_file"
  read -p "Agregar pedido a la base de datos? (responde q para cancelar) " user_input

  if [ "${user_input,,}" != "q" ]; then
    pedido=$(< "$temp_file")
    echo "$pedido" >> "$pedidos_list"
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
}
seleccionarCliente() {
  local file="$1"
  local temp_file=$(mktemp --tmpdir="$temp_dir")
  read -p "Ingrese término de búsqueda o q para cancelar. " search_term

  if [ "${search_term,,}" == "q" ]; then
    error "Búsqueda cancelada."
    sleep 3
    menuPedidos
  fi

  getRegister "$search_term" "$clientes_list" "$temp_file"
  displayCsvRegisters "$clientes_headers" "$temp_file"
  local num_results=$(wc -l < "$temp_file")
  if [ "$num_results" -eq 1 ]; then
    local code_cliente=$(awk -F, '{print $1}' "$temp_file")
    local tel_cliente=$(awk -F, '{print $NF}' "$temp_file")
    read -p "Continuar con cliente "$code_cliente"? (responde q para cancelar) " user_input
    if  [ "${user_input,,}" == "q" ]; then
      borrarTemporales
      menuPedidos
    else
      echo -n ",$code_cliente,$tel_cliente" >> "$file"
    fi
  elif [ "$num_results" -gt 1 ]; then
    error "Demasiados registros intente acortar la busqueda ingresando el codigo de cliente.\n"
    seleccionarCliente "$file"
  else
    seleccionarCliente "$file"
  fi
}
seleccionarCombo() {
  local file=$1
  local temp_file=$(mktemp --tmpdir="$temp_dir")
  displayCsvRegisters "$combos_headers" "$combos_list"
  read -p "Ingrese el codigo del combo o q para cancelar " user_input
  if [ "${user_input,,}" == "q" ]; then
    borrarTemporales
    menuPedidos
  else
    getRegister "$user_input" "$combos_list" "$temp_file"
    local num_results=$(wc -l < "$temp_file")
    if [ "$num_results" -eq 1 ]; then
      local code_combo=$(awk -F, '{print $1}' "$temp_file")
      local precio_combo=$(awk -F, '{print $NF}' "$temp_file")
      local cantidad=0
      local total=0
      while true; do
        read -p "Ingresar cantidad de $code_combo "  user_input
        if esCantidadValida "$user_input" ; then
          cantidad="$user_input"
          break
        else
          error "Debe ingresar un numero mayor de 0.\n"
        fi
      done
      total=$((cantidad * precio_combo))
      echo -n ",$code_combo,$cantidad","$total" >> "$file"
    else
      clear
      error "El combo no existe, intentelo nuevamente.\n" "$code_combo"
      seleccionarCombo "$1"
    fi
  fi
}
getVentasPorCombo() {
  local temp_file=$(mktemp --tmpdir="$temp_dir")
  read -p "Ingrese el codigo del combo, o q para cancelar " user_input
  if [ "${user_input,,}" == "q" ]; then
    menuResumen
  else
    user_input="${user_input^^}"
    if awk -v combo="$user_input" -F',' '$1 == combo {found=1; exit} END{exit !found}' "$combos_list"; then
      local current_month=$(date +'%m')
      awk -v combo="$user_input" -v month="$current_month" -F',' '{split($2, date, "-"); if(date[2] == month && $6 == combo) print}' "$pedidos_list" > "$temp_file"
      local suma=$(awk -F',' 'BEGIN{suma=0} { suma += $7 } END{print suma}' "$temp_file")
      clear
      displayCsvRegisters "$pedidos_headers" "$temp_file"
      success "Se vendieron un total de $suma combos $user_input en el mes.\n"
      read -p "$continuar"     
    else
      error "El combo $user_input no existe en la base de datos."
      sleep 3
      getVentasPorCombo
    fi
  fi
}
getVentasPorCliente() {
  local temp_file=$(mktemp --tmpdir="$temp_dir")
  read -p "Ingrese el codigo del cliente, o q para cancelar " user_input
  if [ "${user_input,,}" == "q" ]; then
    menuResumen
  else
    user_input="${user_input^^}"
    if awk -v cliente="$user_input" -F',' '$1 == cliente {found=1; exit} END{exit !found}' "$clientes_list"; then
      awk -v cliente="$user_input" -F',' '$4 == cliente' "$pedidos_list" > "$temp_file"
      local suma=$(awk -F',' 'BEGIN{suma=0} { suma += $8 } END{print suma}' "$temp_file")
      clear
      displayCsvRegisters "$pedidos_headers" "$temp_file"
      success "El cliente $user_input ha gastado un total de $suma en compras.\n"
      read -p "$continuar"
    else
      error "El cliente $user_input no existe en la base de datos."
      sleep 3
      getVentasPorCliente
    fi
  fi
}
getVentasPorUsuario() {
  local usuario="$1"
  local temp_file=$(mktemp --tmpdir="$temp_dir")
  awk -v user="$usuario" -F',' 'tolower($3) == tolower(user) {print}' "$pedidos_list" > "$temp_file"
  if [ -s "$temp_file" ]; then
    clear
    header "Ventas de $usuario"
    local num_ventas=$(wc -l < "$temp_file")
    local sum_ventas=$(awk -F',' '{sum += $8} END {print sum}' "$temp_file")
    displayCsvRegisters "$pedidos_headers" "$temp_file"
    success "El usuario $usuario ha realizado $num_ventas  ventas por un total de $ $sum_ventas.\n"
    read -p "$continuar"
  else
    error "El usuario $usuario no ha realizado ninguna venta o no es válido.\n"
    read -p "$continuar"
  fi
}
editPedido() {
  local fecha=$(date +"%d-%m-%Y-%H%M%S")
  local temp_file=$(mktemp --tmpdir="$temp_dir")
  local temp_old_order=$(mktemp --tmpdir="$temp_dir")
  read -p "$search_txt" user_input
  if [ "${user_input,,}" == "q" ]; then
    error "Búsqueda cancelada.\n"
    borrarTemporales
    sleep 3
    menuPedidos
  else
    getRegister "$user_input" "$pedidos_list" "$temp_old_order"
    displayCsvRegisters "$pedidos_headers" "$temp_old_order"
    local num_results=$(wc -l < "$temp_old_order")
    if [ "$num_results" -eq 1 ]; then
      local code_orden=$(awk -F, '{print $1}' "$temp_old_order")
      local code_cliente=$(awk -F, '{print $4}' "$temp_old_order")
      local tel_cliente=$(awk -F, '{print $5}' "$temp_old_order")

      read -p "Continuar con pedido "$code_orden"? (responde q para cancelar) " user_input
      if  [ "${user_input,,}" == "q" ]; then
        borrarTemporales
        menuPedidos
      else
        echo -n "$code_orden,$fecha,$current_user,$code_cliente,$tel_cliente" > $temp_file 
        menuEditPedido "$temp_file" "$temp_old_order"
      fi
    elif [ "$num_results" -gt 1 ]; then
      error "Demasiados registros intente acortar la busqueda ingresando el codigo del pedido.\n"
      borrarTemporales
      editPedido
    else
      editPedido
    fi
  fi
}