#!/usr/bin/env bash
set -euo pipefail

# generate-webp.sh
# Small CLI for macOS to generate responsive WebP variants (1600,800,480)
# Usage:
#   ./scripts/generate-webp.sh              # process all images in assets/images
#   ./scripts/generate-webp.sh path/to/file # process a single file
# Dependencies:
#   - cwebp (install: brew install webp)
#   - sips (macOS built-in) or ImageMagick `magick`

SIZES=(1600 800 480)
QUALITY=80
WORKDIR="assets/images"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ensure_deps() {
  if ! command_exists cwebp; then
    echo "cwebp is required but not installed. Install with: brew install webp"
    exit 1
  fi
  if ! command_exists sips && ! command_exists magick; then
    echo "Neither sips nor ImageMagick (magick) found. On macOS, sips is built-in."
    echo "Install ImageMagick if needed: brew install imagemagick"
    exit 1
  fi
}

resize_and_convert() {
  local src="$1"
  local dir
  dir=$(dirname "$src")
  local base
  base=$(basename "$src")
  local name="${base%.*}"

  for size in "${SIZES[@]}"; do
    # skip if target already exists
    out_webp="$dir/${name}-${size}.webp"
    if [ -f "$out_webp" ]; then
      echo "Skipping existing: $out_webp"
      continue
    fi

    tmp="${TMPDIR:-/tmp}/${name}-${size}.tmp"

    if command_exists sips; then
      # sips will maintain aspect ratio, -Z sets the max dimension
      sips -Z "$size" "$src" --out "$tmp.jpg" >/dev/null
    else
      # ImageMagick fallback
      magick convert "$src" -resize "${size}x${size}>" "$tmp.jpg"
    fi

    # convert to webp
    cwebp -q "$QUALITY" "$tmp.jpg" -o "$out_webp" >/dev/null
    echo "Generated: $out_webp"
    rm -f "$tmp.jpg"
  done
}

process_path() {
  local p="$1"
  if [ -d "$p" ]; then
    shopt -s nullglob
    for f in "$p"/*.{jpg,jpeg,png,webp,JPG,JPEG,PNG,WEBP}; do
      # avoid processing generated variants
      if [[ "$f" =~ -([0-9]{2,4})\.(webp|jpg|png)$ ]]; then
        continue
      fi
      resize_and_convert "$f"
    done
    shopt -u nullglob
  elif [ -f "$p" ]; then
    resize_and_convert "$p"
  else
    echo "Path not found: $p"
    exit 1
  fi
}

main() {
  ensure_deps

  if [ "$#" -eq 0 ]; then
    process_path "$WORKDIR"
  else
    for arg in "$@"; do
      process_path "$arg"
    done
  fi
}

main "$@"
