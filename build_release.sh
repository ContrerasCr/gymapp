#!/usr/bin/env bash

set -e  # cortar si hay error

echo "Buildozer Android Release (firmado)"

# ===== CONFIGURACIÓN =====
KEYSTORE_PATH="$(pwd)/myapp.keystore"
KEY_ALIAS="myapp"
KEYSTORE_PASS="Terraform"
KEYALIAS_PASS="Terraform"

# ===== VALIDACIONES =====
if [ ! -f "$KEYSTORE_PATH" ]; then
  echo "❌ Keystore no encontrado: $KEYSTORE_PATH"
  exit 1
fi

# ===== INSTALAR LIBRERIAS =====

uv pip install -r requeriments.txt


# ===== VARIABLES PARA P4A =====
export P4A_RELEASE_KEYSTORE="$KEYSTORE_PATH"
export P4A_RELEASE_KEYALIAS="$KEY_ALIAS"
export P4A_RELEASE_KEYSTORE_PASSWD="$KEYSTORE_PASS"
export P4A_RELEASE_KEYALIAS_PASSWD="$KEYALIAS_PASS"

echo "🔑 Keystore cargado correctamente"

# ===== BUILD =====
echo "🧹 Limpiando build anterior..."
buildozer android clean

echo "📦 Compilando release firmado..."
buildozer android release

echo "✅ Build finalizado"
ls -lh bin/

