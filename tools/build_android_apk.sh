#!/usr/bin/env bash
# Genera el APK debug de Casa de Gatos para instalar en Android.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

export PATH="${HOME}/.local/bin:${PATH}"
export ANDROID_HOME="${ANDROID_HOME:-${HOME}/android-sdk}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME}}"
export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk-amd64}"
export PATH="${JAVA_HOME}/bin:${PATH}"

if ! command -v godot >/dev/null 2>&1; then
  bash "${ROOT_DIR}/tools/install_godot.sh"
fi

if [[ ! -x "${ANDROID_HOME}/platform-tools/adb" ]]; then
  echo "ERROR: Android SDK no encontrado en ${ANDROID_HOME}"
  exit 1
fi

KEYSTORE="${HOME}/android-debug.keystore"
if [[ ! -f "${KEYSTORE}" ]]; then
  keytool -genkeypair -v \
    -keystore "${KEYSTORE}" \
    -storepass android \
    -keypass android \
    -alias androiddebugkey \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=Android Debug,O=Android,C=US"
fi

# No usar env vars parciales de keystore (Godot falla si faltan).
unset GODOT_ANDROID_KEYSTORE_DEBUG_PATH GODOT_ANDROID_KEYSTORE_DEBUG_USER GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD || true

SETTINGS="${HOME}/.config/godot/editor_settings-4.3.tres"
mkdir -p "${HOME}/.config/godot"
if [[ ! -f "${SETTINGS}" ]]; then
  godot --headless --path "${ROOT_DIR}" --editor --quit-after 1 >/dev/null 2>&1 || true
fi
if [[ -f "${SETTINGS}" ]]; then
  sed -i "s|export/android/java_sdk_path = \".*\"|export/android/java_sdk_path = \"${JAVA_HOME}\"|" "${SETTINGS}"
  sed -i "s|export/android/android_sdk_path = \".*\"|export/android/android_sdk_path = \"${ANDROID_HOME}\"|" "${SETTINGS}"
  sed -i "s|export/android/debug_keystore = \".*\"|export/android/debug_keystore = \"${KEYSTORE}\"|" "${SETTINGS}"
  sed -i "s|export/android/debug_keystore_user = \".*\"|export/android/debug_keystore_user = \"androiddebugkey\"|" "${SETTINGS}"
  sed -i "s|export/android/debug_keystore_pass = \".*\"|export/android/debug_keystore_pass = \"android\"|" "${SETTINGS}"
fi

# Requisito Android: ETC2/ASTC
if ! grep -q 'import_etc2_astc=true' "${ROOT_DIR}/project.godot"; then
  echo "ERROR: falta rendering/textures/vram_compression/import_etc2_astc=true en project.godot"
  exit 1
fi

mkdir -p "${ROOT_DIR}/build" /opt/cursor/artifacts
OUT_APK="${ROOT_DIR}/build/CasaDeGatos.apk"

"${ANDROID_HOME}/platform-tools/adb" start-server >/dev/null 2>&1 || true

echo "Importando proyecto..."
godot --headless --path "${ROOT_DIR}" --import

echo "Exportando APK debug..."
godot --headless --path "${ROOT_DIR}" --export-debug "Android" "${OUT_APK}"

if [[ ! -f "${OUT_APK}" ]]; then
  echo "ERROR: no se generó ${OUT_APK}"
  exit 1
fi

cp -f "${OUT_APK}" /opt/cursor/artifacts/CasaDeGatos.apk
ls -lh "${OUT_APK}" /opt/cursor/artifacts/CasaDeGatos.apk
echo "APK_OK ${OUT_APK}"
