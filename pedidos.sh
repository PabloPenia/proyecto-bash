buscarCliente() {
  clear
  echo "Agregar un pedido"
  # Implement your logic to add an item to the list
  read -p "Ingrese el codigo del cliente, o termino de busqueda... " optCliente
  resultado=$(grep -i "$optCliente" "$listaClientes")

  if [ -n "$resultado" ]; then
    # If there is a match, display the result
    echo "CODIGO  NOMBRE          TELEFONO"
    echo "$resultado" | while IFS=, read -r codigo nombre telefono; do
      printf "%-6.6s %-15.15s %-15.15s\n" "$codigo" "$nombre" "$telefono"
    done

    # Ask for confirmation after displaying the results
    read -p "Confirmar codigo de cliente: " userInput 2>&1

    if [ -n "$userInput" ]; then
      userInput=${userInput^^}

      # Extract only the first 5 characters of the entered code
      codigoClienteInput=$(echo "$userInput" | cut -c 1-5)

      # Check if the entered code matches the first 5 characters of the CSV file
      if grep -q "^$codigoClienteInput" <<< "$resultado"; then
        echo "Código $userInput existe en el archivo CSV."
        echo "Código del cliente: $userInput"

        # Return the code for further processing
        echo "$userInput"
        return 0
      else
        echo "El código de cliente $userInput no existe en la base de datos. Inténtelo nuevamente"
      fi
    else
      echo "Código de cliente no ingresado. Inténtelo nuevamente"
    fi
  else
    echo "No se encontraron registros."
  fi

  # Prompt to continue
  read -p "Presiona Enter para continuar..."
  return 1
}