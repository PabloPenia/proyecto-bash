ingresarPedido() {
  # TODO: manejar caso con la fecha de argumento
  mkdir -p .temp
  fecha=$(date +"%d-%m-%Y-%H%M%S")
  file=.temp/$fecha
  usuario=$USER
  num_orden="ORD001"
  ultimo_pedido=$(awk -F',' 'NR>1 {firstField=$1} END{if (NR>1) print firstField}' "$listaPedidos")
  if [ -n $ultimo_pedido ]; then
    num=$(echo "$ultimo_pedido" | sed 's/ORD//')
    newNum=$((10#$num + 1))
    num_orden="ORD(printf "%03d" "$newNum")"
  fi
  echo "$num_orden"
  seleccionarCliente "$file"
  seleccionarCombo "$file"
  echo "Verifique si los datos son correctos"
  mostrarRegistrosCSV "$file"
  read -p "$continuar"
}
seleccionarCliente() {
  # TODO: Verificar que se pase la fecha en linux, en windows no funca
  read -ep $'\nIngrese el codigo del cliente, o termino de busqueda...\n ' searchTerm
  resultado=$(grep -i "$searchTerm" "$listaClientes")

  if [ -n "$resultado" ]; then
    echo ""
    echo "CODIGO  NOMBRE          TELEFONO"
    echo "$resultado" | while IFS=, read -r codigo nombre telefono; do
      printf "%-6.6s %-15.15s %-15.15s\n" "$codigo" "$nombre" "$telefono"
    done
    lines=$(echo "$resultado" | wc -l)
    if [ "$lines" -eq 1 ]; then
      codigo_cliente=${resultado:0:5}
      printf "\nContinuar con cliente %s?. (responde s/n)\n" "$codigo_cliente"
      read -ep $'' respuesta
      respuesta="${respuesta,,}"
      if [ "$respuesta" == "s" ]; then
        tel_cliente=${resultado: -13}
        echo -n "$tel_cliente," > $1
      else
        clear
        ingresarPedido "$1"
      fi
    else
      ingresarPedido "$1"
    fi
  fi 
}
seleccionarCombo() {
  mostrarRegistrosCSV "$listaCombos"
  read -ep $'Ingrese el codigo del combo\n' combo
  
  resultado=$(grep -i "$combo" "$listaCombos")
  lines=$(echo "$resultado" | wc -l)
  if [[ -n "$resultado" && "$lines" -eq 1 ]]; then
    cantidad=0
    precio="${resultado##*,}"
    while true; do
      read -p "Ingrese cantidad de $combo" userQty
      if esCantidadValida "$userQty" ; then
        cantidad=$userQty
        break
      else
        clear
        echo "Debe ingresar un numero mayor de 0."
      fi
    done
    total=$((cantidad * precio))

    printf "\nConfirmar Combo %s X%d por un total de %d?. (responde s/n)\n" "$combo" "$cantidad" "$total"
  read respuesta
  respuesta="${respuesta,,}"
  if [ "$respuesta" == "s" ]; then
    item="$combo,$cantidad,$total"
    echo -n "$item," >> $1
  else
    clear
    seleccionarCombo "$1"
  fi
  else
    clear
    printf "El combo %s no existe, intentelo nuevamente.\n" "$combo"
    seleccionarCombo "$1"
  fi
}
esCantidadValida() {
  [[ $1 =~ ^[1-9][0-9]*$ ]]
}