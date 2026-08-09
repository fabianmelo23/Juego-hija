#!/usr/bin/env bash
# Instala Godot 4.3 en el entorno de desarrollo (idempotente).
set -euo pipefail

GODOT_VERSION="4.3"
INSTALL_DIR="${HOME}/tools/godot"
BIN_DIR="${HOME}/.local/bin"
BIN_LINK="${BIN_DIR}/godot"
GODOT_BIN="${INSTALL_DIR}/Godot_v${GODOT_VERSION}-stable_linux.x86_64"
ZIP_URL="https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"

mkdir -p "${INSTALL_DIR}" "${BIN_DIR}"

if [[ ! -x "${GODOT_BIN}" ]]; then
  echo "Descargando Godot ${GODOT_VERSION}..."
  tmp_zip="$(mktemp /tmp/godot-XXXXXX.zip)"
  curl -fL "${ZIP_URL}" -o "${tmp_zip}"
  unzip -o "${tmp_zip}" -d "${INSTALL_DIR}"
  rm -f "${tmp_zip}"
  chmod +x "${GODOT_BIN}"
fi

ln -sfn "${GODOT_BIN}" "${BIN_LINK}"
export PATH="${BIN_DIR}:${PATH}"

echo "Godot listo: $("${BIN_LINK}" --version)"

# Importa el proyecto si estamos en la raíz del repo.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "${ROOT_DIR}/project.godot" ]]; then
  echo "Importando proyecto Casa de Gatos..."
  "${BIN_LINK}" --headless --path "${ROOT_DIR}" --import
  echo "Proyecto importado."
fi

echo "OK — usa: godot --path \"${ROOT_DIR}\""
