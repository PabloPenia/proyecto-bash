menu_pedidos="Menu - Lista de pedidos.\n1. Ingresar nuevo.\n2. Buscar.\n3. Ver todos.\nq. Volver al menu principal.\n"
menu_principal="Menu - Principal.\n1. Administrar pedidos.\n2. Ver combos.\n3. Ver clientes.\nq. Salir.\n"
continuar="Presiona Enter para continuar..."
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