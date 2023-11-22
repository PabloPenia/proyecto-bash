# TEXTOS
clientes_headers="CODIGO,NOMBRE,TELEFONO"
clientes_list="db/clientes.csv"
combos_headers="CODIGO,NOMBRE,DETALLE,PRECIO"
combos_list="db/combos.csv"
continuar="Presiona Enter para continuar..."
logoFile="logo.txt"
menu_editar_pedido="1. Modificar combo.\n2. Marcar como entregados.\n3. Eliminar.\nq. Volver al menu principal.\n"
menu_pedidos="\n1. Ingresar nuevo.\n2. Modificar pedido.\n3. Ver todos.\nq. Volver al menu principal.\n"
menu_principal="1. Administrar pedidos.\n2. Ver combos.\n3. Ver clientes.\n4. Resumen de ventas.\nq. Salir.\n"
menu_resumen="\n1. Combos vendidos del mes.\n2. Compras por cliente.\n3. Ventas por usuario.\n4. Mis ventas.\nq. Volver al menu principal.\n"
pedidos_headers="CODIGO,FECHA,USUARIO,CLIENTE,TEL,COMBO,CANT,TOTAL,ESTADO"
pedidos_list="db/pedidos.csv"
search_txt="Ingrese término de búsqueda o q para cancelar. "
# MENUES
menuPrincipal() {
  clear
  if [ -f "$logoFile" ]; then
    centerImage $logoFile
  fi
  header "**** BIENVENIDO AL CONTROL DE LA PIZZERA ****"
  while true; do
    titulo "Menu Principal"
    printf "\n$menu_principal"
    read -p "Elegir opcion: " opt
    case $opt in
      1)
        menuPedidos
        ;;
      2)
        # https://losmateospizzeria.com.uy/menu/losmateospizzeria
        clear
        header "Lista de Combos"
        displayCsvRegisters "$combos_headers" "$combos_list"
        read -p "$continuar"
        menuPrincipal
        ;;
      3)
        clear
        header "Lista de Clientes"
        displayCsvRegisters "$clientes_headers" "$clientes_list"
        read -p "$continuar"
        menuPrincipal
        ;;
      4)
        menuResumen
        ;;
      "q")
        clear
        success "Finalizando..."
        borrarTemporales
        sleep 3
        exit 0
        ;;
      *)
        error "$opt no es una opcion valida."
        sleep 3
        menuPrincipal
        ;;
    esac
  done
}
menuPedidos() {
  while true; do
    clear
    header "Administrar Pedidos."
    printf "$menu_pedidos"
    read -p "Selecciona una opción: " opt
    case $opt in
      1)
        clear
        header "Ingresar pedido"
        ingresarPedido
        read -p "Pedido finalizado. $continuar"
        ;;
      2)
        clear
        header "Modificar pedido"
        editPedido
        success "Pedido modificado.\n"
        read -p "$continuar"
        ;;
      3)
        clear
        header "Lista de Pedidos"
        displayCsvRegisters "$pedidos_headers" "$pedidos_list"
        read -p "$continuar"
        ;;
      "q")
        clear
        menuPrincipal
        ;;

      *)
        error "$opt no es una opción válida."
        sleep 3
        menuPedidos
        ;;
    esac
  done
}
menuEditPedido() {
  local file="$1"
  local temp_old_order="$2"
  local temp_file=$(mktemp --tmpdir="$temp_dir")
  while true; do
    clear
    header "Modificar Pedido"
    printf "$menu_editar_pedido"    
    read -p "Selecciona una opción: " opt
    case $opt in
      1)
        clear
        header "Modificar el combo"
        seleccionarCombo "$file"
        echo ",PENDIENTE" >> $file
        echo "Verifique si los nuevos datos son correctos"
        displayCsvRegisters "$pedidos_headers" "$file"
        read -p "Modificar pedido en la base de datos? (responde q para cancelar) " user_input
        if [ "$user_input" != "q" ]; then
          awk -F, 'NR==FNR {data[$1]=$0; next} {if ($1 in data) print data[$1]; else print $0}' "$file" "$pedidos_list" > "$temp_file"
          mv $temp_file "$pedidos_list"
          borrarTemporales
          success "Pedido modificado correctamente\n"
          sleep 3
          menuPedidos
        else
          clear
          error "Se ha cancelado la modificacion del pedido.\n"
          borrarTemporales
          sleep 3
          menuPedidos
        fi
        ;;
      2)
        clear
        header "Marcar como entregado"
        local code_combo=$(awk -F, '{print $6}' "$temp_old_order")
        local cantidad=$(awk -F, '{print $7}' "$temp_old_order")
        local total=$(awk -F, '{print $8}' "$temp_old_order")
        error "Esta seguro que quiere marcar este pedido como entregado?\n"
        displayCsvRegisters "$pedidos_headers" "$temp_old_order"
        read -p " (responde q para cancelar) " user_input
        echo -n ",$code_combo,$cantidad,$total" >> $file
        if [ "$user_input" != "q" ]; then
          echo ",ENTREGADO" >> $file
          awk -F, 'NR==FNR {data[$1]=$0; next} {if ($1 in data) print data[$1]; else print $0}' "$file" "$pedidos_list" > "$temp_file"
          mv "$temp_file" "$pedidos_list"
          borrarTemporales
          success "Pedido marcado como entregado.\n"
          sleep 3
          menuPedidos
        else
          error "Accion cancelada.\n"
          borrarTemporales
          sleep 3
          menuPedidos
        fi
        ;;
      3)
        clear
        header "Cancelar pedido"
        local pedido_eliminar=$(<"$temp_old_order" tr -d '\n')
        error "Esta seguro que quiere eliminar este pedido de la base de datos?\n"
        echo -n "$pedido_eliminar" > "$temp_old_order"
        displayCsvRegisters "$pedidos_headers" "$temp_old_order"
        read -p " (responde q para cancelar) " user_input
        if [ "$resp" != "q" ]; then
          awk -v content="$pedido_eliminar" '$0 != content' "$pedidos_list" > "$temp_file"
          mv "$temp_file" "$pedidos_list"
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
      sleep 3
      menuPedidos
      ;;
    esac
  done
}
menuResumen() {
  while true; do
    clear
    header "Resumen de ventas"
    printf "$menu_resumen"    
    read -p "Selecciona una opción: " opt
    case $opt in
      1)
        clear
        header "Ventas por combo"
        displayCsvRegisters "$combos_headers" "$combos_list"            
        getVentasPorCombo
        ;;
      2)
        clear
        header "Compras por cliente"
        displayCsvRegisters "$clientes_headers" "$clientes_list"            
        getVentasPorCliente
        ;;
      3)
        clear
        header "Ventas por usuario"
        read -p "Ingrese el nombre del usuario, o q para cancelar " user_input
        if [ "${user_input,,}" == "q" ]; then
          menuResumen
        else
          getVentasPorUsuario "$user_input"
        fi
        ;;
      4)
        clear
        getVentasPorUsuario "$current_user"
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