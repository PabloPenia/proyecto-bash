separador() {
  printf "\n"
  printf '%.s¯' $(seq 1 $(tput cols))
  printf "\n\n"
}
mostrarRegistrosCSV(){
  echo ""
  if [[ ! -f "$1" ]]; then
    echo "El archivo $1 no existe"
    return 1 # valor non-zero = error
  fi
  IFS=',' read -r -a headers < "$1"
  data=() 
  while IFS=',' read -r -a row; do
    data+=("${row[@]}") 
  done < <(tail -n +2 "$1")
  max_widths=()
  for ((i = 0; i < ${#headers[@]}; i++)); do
    max_width=0
    for ((j = 0; j < ${#data[@]}; j += ${#headers[@]})); do
      cell="${data[$j + i]}"
      cell_length=${#cell}
      if ((cell_length > max_width)); then
        max_width=$cell_length
      fi
    done
    max_widths+=("$max_width")
  done
  # Mostrar Cabeceras
  for ((i = 0; i < ${#headers[@]}; i++)); do
    printf "%-*s  " "${max_widths[$i]}" "${headers[$i]}"
  done
  echo

  # Mostrar Datos
  for ((i = 0; i < ${#data[@]}; i += ${#headers[@]})); do
    for ((j = 0; j < ${#headers[@]}; j++)); do
      cell="${data[$i + j]}"
      printf "%-*s  " "${max_widths[$j]}" "$cell"
    done
    echo
  done
  echo ""
}

getRegister() {
  if [ "$#" -eq 2 ]; then
    local searchTerm="$1"
    local file="$2"
    local result=$(grep -i "$searchTerm" "$file")
    echo "$result"
  else
    echo "Debes ingresar almenos 2 argumentos"
  fi
}
displayRegisters() {
  local headers=("$1")
  local data=("${@:2}")
  # Anchos
  declare -a column_widths
  for header in "${headers[@]}"; do
    column_widths+=("$((${#header} + 2))") # el numero es por padding
  done
  # Actualizar anchos segun los campos
  for row in "${data[@]}"; do
    IFS=',' read -ra row_array <<< "$row"
    for i in "${!row_array[@]}"; do
      col_length=$((${#row_array[i]} + 2))
      if ((col_length > column_widths[i])); then
        column_widths[i]=$col_length
      fi
    done
  done
  # Imprimir cabeceras
  for i in "${!headers[@]}"; do
    printf "| %-*s " "${column_widths[i]}" "${headers[i]}"
  done
  printf "|\n"
  # Separador
  for width in "${column_widths[@]}" do
    printf "+%s" "$(printf '%*s' "$((width + 2))" '')"
  done
  printf "+\n"
  # registros
  for row in "${data[@]}"; do
    IFS=',' read -ra row_array <<< "$row"
    for i in "${!row_array[@]}"; do
      printf "| %-*s " "${column_widths[i]}" "${row_array[i]}"
    done
    printf "|\n"
  done
}
displayCsvRegisters() {
  local headers=("$@")
  local file_path="${headers[-1]}"
  unset headers[-1]

  local csv_data=$(<"$file_path")
  displayRegisters "${headers[@]}" "$csv_data"
}