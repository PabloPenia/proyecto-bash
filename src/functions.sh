# Funciones de formateo
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
    local imagen=$1
    local width=$(tput cols)
    local image_width=$(awk '{ print length }' "$imagen" | sort -n | tail -n 1)
    local margen=$(( (width - image_width) / 2 ))
    awk -v margin="$margen" '{printf "%"margin"s%s\n", "", $0}' "$imagen"
}
error() {
  printf "\n$red$1$reset_bold"
}
header() {
  local txt="$1"
  separador
  printf "$bold\n"
  center "$txt"
  printf "\n$reset_bold"
  separador
}
separador() {
  printf "\n"
  printf "%s" "$(printf '─%.0s' $(seq 1 $(tput cols)))"
  printf "\n"
}
success() {
  printf "\n$green$1$reset_bold"
}
titulo() {
  printf "\n$bold$1$reset_bold\n"
}
# Registros
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

    # Ancho columnas basado en headers
    declare -a column_widths
    for i in "${!headers[@]}"; do
      col_length=$((${#headers[i]} + 2))  # Add 2 for padding
      column_widths+=("$col_length")
    done

    # Ancho columnas basado en rows
    for row in "${data[@]}"; do
      IFS=',' read -ra row_array <<< "$row"
      for i in "${!row_array[@]}"; do
        col_length=$((${#row_array[i]} + 2))  # padding = 2
        if ((col_length > column_widths[i])); then
          column_widths[i]=$col_length
        fi
      done
    done

    # Imprimir headers
    printf "\n$bold"
    for i in "${!headers[@]}"; do
      printf "%-*s " "${column_widths[i]}" "${headers[i]}"
    done
    printf "$reset_bold\n"

    # Imprimir separador
    for width in "${column_widths[@]}"; do
      printf "%s" "$(printf '─%.0s' $(seq 1 "$((width + 2))"))"
    done
    printf "\n"


    # Imprimir rows
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
  local file="$2"
  # csv -> array de rows
  IFS=$'\n' read -d '' -ra data < "$file"
  data=("${data[@]//[$'\n']/}") # borrar elementos vacios

  displayRegisters "$headers" "${data[@]}"
}
# Tools
borrarTemporales(){
  rm -f $temp_dir/*
}
esCantidadValida() {
  [[ $1 =~ ^[1-9][0-9]*$ ]]
}

showHelp() {
  echo ""
  echo "USO: $(basename "$0") [--help, -h]"
  echo ""
  cat "./src/data/help.txt"
  echo ""
  # read -p $continuar
}