
bold="\033[1m"
reset_bold="\033[0m\n"


separador() {
  printf "\n"
  printf "%s" "$(printf '─%.0s' $(seq 1 $(tput cols)))"
  printf "\n"
}
titulo() {
  printf "\n$bold $1 $reset_bold"
}

getRegister() {
  if [ "$#" -eq 2 ]; then
    local search_term="$1"
    local file="$2"
    IFS=$'\n' read -d '' -ra data < "$file" # archivo -> array
    data=("${data[@]//[$'\n']/}")

    local filtered_rows=()
    for row in "${data[@]}"; do
      if grep -i "$search_term" <<< "$row"; then
        filtered_rows+=("$row")
      fi
    done
    echo "${filtered_rows[@]}"
  fi
}

displayRegisters() {
  local headers_string="$1"
  local data=("${@:2}")

  if [[ ${#data[@]} -gt 0 ]]; then
    # headers -> array de campos
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
    printf "$bold"
    for i in "${!headers[@]}"; do
      printf "%-*s " "${column_widths[i]}" "${headers[i]}"
    done
    printf "$reset_bold"

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
  else
    echo "No hay datos que mostrar"
  fi
}




displayCsvRegisters() {
  local headers="$1"
  local file="$2"  # Use the last argument as the file path
  # csv -> array de rows
  IFS=$'\n' read -d '' -ra data < "$file"
  data=("${data[@]//[$'\n']/}") # borrar elementos vacios

  displayRegisters "$headers" "${data[@]}"
}