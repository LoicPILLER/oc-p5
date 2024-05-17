#!/bin/bash

# Dossier contenant les images
input_dir="slider"
output_dir="slider"

# Vérifiez si le dossier de sortie existe, sinon créez-le
if [ ! -d "$output_dir" ]; then
  mkdir -p "$output_dir"
fi

# Largeur cible pour le redimensionnement
target_width=1920

# Qualité de la compression WebP
quality=80

# Fonction pour optimiser et convertir une seule image
process_image() {
  local img="$1"
  local relative_path="${img#$input_dir/}"
  local output_path="$output_dir/${relative_path%.*}.webp"
  local output_dir_path=$(dirname "$output_path")

  # Créez le dossier de sortie si nécessaire
  mkdir -p "$output_dir_path"

  # Optimiser l'image originale
  case "$img" in
    *.jpg|*.jpeg)
      jpegoptim --strip-all --all-progressive "$img"
      ;;
    *.png)
      optipng -o2 "$img"
      ;;
  esac

  # Redimensionnez et convertissez en WebP
  magick "$img" -resize ${target_width}x -quality $quality "$output_path"

  if [ $? -eq 0 ]; then
    echo "Converted $img to $output_path"
  else
    echo "Failed to convert $img"
  fi
}

export -f process_image
export input_dir
export output_dir
export target_width
export quality

# Trouvez toutes les images et traitez-les
find "$input_dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -exec bash -c 'process_image "$0"' {} \;
