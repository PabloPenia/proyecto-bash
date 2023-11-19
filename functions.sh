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
  local headers_string="$1"
  local data=("${@:2}")

  # Convert headers string to an array
  IFS=',' read -ra headers <<< "$headers_string"

  # Determine maximum column widths
  declare -a column_widths
  for i in "${!headers[@]}"; do
    col_length=$((${#headers[i]} + 2))  # Add 2 for padding
    column_widths+=("$col_length")
  done

  # Update maximum column widths based on rows
  for row in "${data[@]}"; do
    IFS=',' read -ra row_array <<< "$row"
    for i in "${!row_array[@]}"; do
      col_length=$((${#row_array[i]} + 2))  # Add 2 for padding
      if ((col_length > column_widths[i])); then
        column_widths[i]=$col_length
      fi
    done
  done

  # Print headers with adjusted column widths
  printf "\033[1m"
  for i in "${!headers[@]}"; do
    printf "%-*s " "${column_widths[i]}" "${headers[i]}"
  done
  printf "\033[0m\n"

  # Print separator line
for width in "${column_widths[@]}"; do
  printf "%s" "$(printf '─%.0s' $(seq 1 "$((width + 2))"))"
done
printf "\n"


  # Print rows with adjusted column widths
  for row in "${data[@]}"; do
    IFS=',' read -ra row_array <<< "$row"
    for i in "${!row_array[@]}"; do
      printf "%-*s " "${column_widths[i]}" "${row_array[i]}"
    done
    printf "\n"
  done
}




displayCsvRegisters() {
  local headers=("${@:1:$(( $# - 1 ))}")  # Pass all arguments except the last one as headers
  local file_path="${!#}"  # Use the last argument as the file path

  # Read CSV file into an array
  IFS=$'\n' read -d '' -ra data < "$file_path"

  # Remove empty elements from the data array
  data=("${data[@]//[$'\n']/}")
  headers_string=$(IFS=,; echo "${headers[*]}")
  # Display table using data variable
  displayRegisters "$headers_string" "${data[@]}"
}

searchCsv() {
  local search_term="$1"
  local file_path="$2"

  # Read CSV file into an array
  IFS=$'\n' read -d '' -ra data < "$file_path"

  # Remove empty elements from the data array
  data=("${data[@]//[$'\n']/}")

  # Filter rows containing the search term
  local filtered_rows=()
  for row in "${data[@]}"; do
    if [[ "$row" =~ .*"$search_term".* ]]; then
      filtered_rows+=("$row")
    fi
  done

  # Display filtered rows
  displayRegisters "${data[@]:0:1}" "${filtered_rows[@]}"
}