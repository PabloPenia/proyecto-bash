ingresarPedido() {
  # codigo_cliente=""
  # tel_cliente=""
  # fecha="automatica"
  # codigo_combo=""
  # usuario="del SO"
  # cantidad=""
  # total=""
  case "$#" in
    0)
      read -p "Ingrese el codigo del cliente, o termino de busqueda... " searchTerm
      resultado=$(grep -i "$searchTerm" "$listaClientes")

      if [ -n "$resultado" ]; then
        echo "CODIGO  NOMBRE          TELEFONO"
        echo "$resultado" | while IFS=, read -r codigo nombre telefono; do
          printf "%-6.6s %-15.15s %-15.15s\n" "$codigo" "$nombre" "$telefono"
        done
        lines=$(echo "$resultado" | wc -l)
        if [ "$lines" -eq 1 ]; then
          codigo_cliente=${resultado:0:5}
          read -p "Continuar con cliente $codigo_cliente?. (responde s/n)" respuesta
          respuesta="${respuesta,,}"
          if [ "$respuesta" == "s" ]; then
            # continuar con telefono del cliente x letra del obligatorio
            tel_cliente=${resultado: -13}
            ingresarPedido "$tel_cliente"
          else
            clear
            ingresarPedido
          fi
        else
          ingresarPedido
        fi
      fi
      ;;
    1)
      local tel_cliente=$1
      echo "$tel_cliente"
  esac
  
}
