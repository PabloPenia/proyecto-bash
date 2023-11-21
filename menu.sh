continuar="Presiona Enter para continuar..."
clientes_headers="CODIGO,NOMBRE,TELEFONO"
clientes_list="db/clientes.csv"
combos_headers="CODIGO,NOMBRE,DETALLE,PRECIO"
combos_list="db/combos.csv"
pedidos_headers="CODIGO,USUARIO,FECHA,CLIENTE,TEL,COMBO,CANT,TOTAL,ESTADO"
pedidos_list="db/pedidos.csv"
logoFile="logo.txt"
menu_pedidos="\n1. Ingresar nuevo.\n2. Modificar pedido.\n3. Ver todos.\nq. Volver al menu principal.\n"
menu_editar_pedido="Menu - Editar pedido.\n1. Modificar combo.\n2. Marcar como entregados.\n3. Eliminar.\nq. Volver al menu principal.\n"
menu_principal="1. Administrar pedidos.\n2. Ver combos.\n3. Ver clientes.\nq. Salir.\n"
menuPrincipal() {
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
      displayCsvRegisters "${combos_headers[@]}" "$combos_list"
      read -p "$continuar"
      ;;
    3)
      clear
      displayCsvRegisters "${clientes_headers[@]}" "$clientes_list"
      read -p "$continuar"
      ;;
    "q")
      clear
      echo "Finalizando..."
      read -p "$continuar"
      exit 0
      ;;
    *)
      clear
      echo "$opt no es una opcion valida..."
      read -p "$continuar"
      ;;
    esac
  done
}

menuPedidos() {
  while true; do
    clear
    separador
    titulo "Menu - Pedidos."
    separador    
    printf "$menu_pedidos"
    read -p "Selecciona una opción: " opt
    case $opt in
      1)
        clear
        separador
        titulo "Agregar un pedido"
        separador
        ingresarPedido
        read -p "Pedido finalizado. $continuar"
        ;;
      2)
        clear
        separador
        titulo "Modificar un pedido"
        separador
        editPedido
        success "Pedido modificado.\n"
        read -p "$continuar"
        ;;
      3)
        clear
        displayCsvRegisters "${pedidos_headers[@]}" "$pedidos_list"
        read -p "Presiona Enter para continuar..."
        ;;
      "q")
        clear
        menuPrincipal
        ;;

      *)
        clear
        echo "$opt no es una opción válida..."
        read -p "Presiona Enter para continuar..."
        ;;
    esac
  done
}
