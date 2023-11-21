search_txt="Ingrese término de búsqueda o q para cancelar. "
temp_search_file=.temp/search
current_user="$USER"

ingresarPedido() {
  mkdir -p .temp
  local fecha=$(date +"%d-%m-%Y-%H%M%S")
  local temp_file=.temp/$fecha
  # codgo del pedido
  num_orden="ORD001" # si no hay ninguna creada
  ultimo_pedido=$(awk -F',' '!/^ *$/ {firstField=$1} END {print firstField}' "$pedidos_list")
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
    rm .temp/*
    success "Pedido ingresado correctamente"
    sleep 3
    menuPedidos
  else
    clear
    error "El pedido se ha cancelado"
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
  if [ "$num_results" -eq 1 ]; then
    local code_orden=$(awk -F, '{print $1}' "$temp_search_file")
    local code_cliente=$(awk -F, '{print $4}' "$temp_search_file")
    local tel_cliente=$(awk -F, '{print $5}' "$temp_search_file")

    read -p "Continuar con pedido "$code_orden"? (responde s/n) " user_input
    if  [ "${user_input,,}" == "n" ]; then
      clear
      editPedido
    else
      echo -n "$code_orden,$fecha,$current_user,$code_cliente,$tel_cliente" > $temp_file 
      while true; do
        clear
        printf "$menu_editar_pedido"    
        read -p "Selecciona una opción: " opt
        case $opt in
          1)
            clear
            separador
            echo "Modificar el combo"
            separador
            seleccionarCombo "$temp_file"
            echo ",PENDIENTE" >> $temp_file
            echo "Verifique si los nuevos datos son correctos"
            displayCsvRegisters "$pedidos_headers" "$temp_file"
            read -p "Modificar pedido en la base de datos? (responde s/n) " resp
            if [ "$resp" == "s" ]; then
              awk -F, 'NR==FNR {data[$1]=$0; next} {if ($1 in data) print data[$1]; else print $0}' "$temp_file" "$pedidos_list" > ".temp/pedidos_modified.csv"
              mv .temp/pedidos_modified.csv "$pedidos_list"
              rm .temp/*
              sucess "Pedido modificado correctamente\n"
              read -p "$continuar"
              menuPedidos
            else
              clear
              error "Se ha cancelado la modificacion del pedido."
              rm .temp/*
              sleep 3
              menuPedidos
            fi
            ;;
          2)
            clear
            separador
            echo "Marcar como entregado"
            separador
            local code_combo=$(awk -F, '{print $6}' "$temp_search_file")
            local cantidad=$(awk -F, '{print $7}' "$temp_search_file")
            local total=$(awk -F, '{print $8}' "$temp_search_file")
            echo "$code_combo,$cantidad,$total,ENTREGADO" >> $temp_file
            displayCsvRegisters "$pedidos_headers" "$temp_file"
            error "Esta seguro que quiere marcar este pedido como entregado?"
            read -p " (responde s/n) " resp
            if [ "$resp" == "s" ]; then
              awk -F, 'NR==FNR {data[$1]=$0; next} {if ($1 in data) print data[$1]; else print $0}' "$temp_file" "$pedidos_list" > ".temp/pedidos_modified.csv"
              mv .temp/pedidos_modified.csv "$pedidos_list"
              rm .temp/*
              success "Pedido marcado como entregado.\n"
              read -p "$continuar"
              menuPedidos
            else
              clear
              error "Accion cancelada."
              rm .temp/*
              read -p "$continuar"
              menuPedidos
            fi
            ;;
          3)
            # TODO: Borrar row
            
# Specify the value in the first field that you want to delete
value_to_delete="some_value"

# Specify the path to your CSV file
csv_file="path/to/your/file.csv"

# Create a temporary file to store the modified content
temp_file=$(mktemp)

# Use awk to filter out the rows with the specified value
awk -v value="$value_to_delete" -F, '$1 != value' "$csv_file" > "$temp_file"

# Replace the original file with the modified content
mv "$temp_file" "$csv_file"

# Remove the temporary file
rm "$temp_file"
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
    error "Demasiados registros intente acortar la busqueda ingresando el codigo del pedido."
    rm .temp/*
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
      error "Demasiados registros intenete acortar la busqueda ingresando el codigo de cliente.\n"
      rm .temp/*
      seleccionarCliente "$file"
    else
      seleccionarCliente "$file"
    fi
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
esCantidadValida() {
  [[ $1 =~ ^[1-9][0-9]*$ ]]
}
marcarEntregado() {
  echo ""
}

eliminarPedido() {
  echo ""
}