# TEXTOS
clientes_headers="CODIGO,NOMBRE,TELEFONO"
clientes_list="db/clientes.csv"
combos_headers="CODIGO,NOMBRE,DETALLE,PRECIO"
combos_list="db/combos.csv"
continuar="Presiona Enter para continuar..."
logoFile="logo.txt"
menu_editar_pedido="1. Modificar combo.\n2. Marcar como entregados.\n3. Eliminar.\nq. Volver al menu principal.\n"
menu_pedidos="\n1. Ingresar nuevo.\n2. Modificar pedido.\n3. Ver todos.\n4. Resumen de ventas.\nq. Volver al menu principal.\n"
menu_principal="1. Administrar pedidos.\n2. Ver combos.\n3. Ver clientes.\nq. Salir.\n"
menu_resumen="\n1. Combos vendidos del mes.\n2. Compras por cliente.\n3. Pedidos por cliente.\n4. Ventas por usuario.\nq. Volver al menu principal.\n"
pedidos_headers="CODIGO,USUARIO,FECHA,CLIENTE,TEL,COMBO,CANT,TOTAL,ESTADO"
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
      "q")
        clear
        success "Finalizando..."
        rm -f .temp/*
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
      4)
        clear
        header "Resumen de Ventas"
        getResumen
        menuPedidos
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
