
bold="\033[1m"
green='\033[1;32m'
red='\033[1;31m'
reset_bold="\033[0m"

center() {
    local contenido="$1"
    local width=$(tput cols)
    local margen=$(( (width - ${#contenido}) / 2 ))
    printf "%${margen}s%s" "" "$contenido"
}
centerImage() {
    imagen=$1
    terminal_width=$(tput cols)
    image_width=$(awk '{ print length }' "$imagen" | sort -n | tail -n 1)
    margin=$(( (terminal_width - image_width) / 2 ))

    # Output the centered image
    awk -v margin="$margin" '{printf "%"margin"s%s\n", "", $0}' "$imagen"
}
separador() {
  printf "\n"
  printf "%s" "$(printf '─%.0s' $(seq 1 $(tput cols)))"
  printf "\n"
}
titulo() {
  printf "\n$bold $1 $reset_bold"
}
success() {
  printf "\n$green $1 $reset_bold"
}
error() {
  printf "\n$red $1 $reset_bold"
}
# getRegister() {
#   if [ "$#" -eq 2 ]; then
#     local search_term="$1"
#     local file="$2"

#     # Read the file into an array, handling null bytes
#     mapfile -t data < "$file"

#     local filtered_rows=()
#     for row in "${data[@]}"; do
#       if echo "$row" | grep -iq "$search_term"; then
#         filtered_rows+=("$row")
#       fi
#     done

#     if [ ${#filtered_rows[@]} -gt 0 ]; then
#       # Use printf to join array elements with a space
#       printf '%s ' "${filtered_rows[@]}"
#     fi
#   fi
# }

getRegister() {
  local search_term="$1"
  local file="$2"
  local temp_file="$3"
  
  grep -i "$search_term" "$file" > "$temp_file"
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
    printf "\n$bold"
    for i in "${!headers[@]}"; do
      printf "%-*s " "${column_widths[i]}" "${headers[i]}"
    done
    printf "$reset_bold\n"

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
    printf "\n"
  else
    error "No hay datos que mostrar\n"
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