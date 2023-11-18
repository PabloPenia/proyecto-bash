menuPrincipal() {
  while true; do
  separador
  printf "$menu_principal"
  read -p "Elegir opcion: " opt
  case $opt in
    1)
      menuPedidos
      ;;
    2)
      # https://losmateospizzeria.com.uy/menu/losmateospizzeria
      clear
      mostrarRegistrosCSV "$listaCombos"
      read -p "$continuar"
      ;;
    3)
      clear
      mostrarRegistrosCSV "$listaClientes"
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
    printf "$menu_pedidos"    
    read -p "Selecciona una opción: " opt
    case $opt in
      1)
        clear
        separador
        echo "Agregar un pedido"
        separador
        ingresarPedido
        read -p "Pedido finalizado. $continuar"
        ;;
      2)
        clear
        separador
        echo "Modificar un pedido"
        separador
        editPedido
        read -p "Pedido modificado. $continuar"
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