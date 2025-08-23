#!/usr/bin/env bash
#
# Script sencillo para organizar archivos por extensión en carpetas separadas.
# Ejemplo: fotos.jpg -> carpeta "jpg/", documentos.pdf -> carpeta "pdf/"
#
# Opciones:
#   -d DIR   Directorio a organizar (por defecto: el actual)
#   -n       Modo "dry-run": solo muestra lo que haría sin mover nada
#
# Autor: Leoncio Duvan Zavaleta Moctezuma
# Repo:  https://github.com/duvandevs/scripts

set -euo pipefail

# Valores por defecto
DIR="."
DRY_RUN=0

# Muestra ayuda rápida
usage() {
  echo "Uso: $0 [-d DIR] [-n]"
  echo "  -d DIR   Directorio a organizar (default: .)"
  echo "  -n       Dry-run (no mueve archivos, solo muestra)"
  exit 1
}

# Leer parámetros
while getopts ":d:n" opt; do
  case "$opt" in
    d) DIR="$OPTARG" ;;
    n) DRY_RUN=1 ;;
    *) usage ;;
  esac
done

# Verificación
if [[ ! -d "$DIR" ]]; then
  echo "Error: '$DIR' no es un directorio válido." >&2
  exit 2
fi

shopt -s nullglob  # evita errores si no hay coincidencias

moved_count=0

# Recorre los archivos del directorio
for f in "$DIR"/*; do
  [[ -f "$f" ]] || continue  # saltar si no es archivo

  filename="$(basename "$f")"
  ext="${filename##*.}"

  # Si no hay extensión, lo mando a "no_extension"
  if [[ "$filename" == "$ext" ]]; then
    folder="no_extension"
  else
    folder="$(tr '[:upper:]' '[:lower:]' <<< "$ext")"
  fi

  target="$DIR/$folder"

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] movería: '$filename' -> '$folder/'"
  else
    mkdir -p "$target"

    # Evitar sobreescribir archivos con el mismo nombre
    base="${filename%.*}"
    ext_out=""
    [[ "$folder" != "no_extension" ]] && ext_out=".$ext"

    dest="$target/$filename"
    i=1
    while [[ -e "$dest" ]]; do
      dest="$target/${base}_$i$ext_out"
      ((i++))
    done

    mv -- "$f" "$dest"
    echo "Movido: '$filename' -> '$folder/'"
    ((moved_count++))
  fi
done

# Resumen final
if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry-run completado."
else
  echo "Organización terminada. Archivos movidos: $moved_count"
fi

