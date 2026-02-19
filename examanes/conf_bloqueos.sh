#!/bin/bash

# Verificar si el usuario es root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Por favor, ejecuta este script con sudo."
  exit 1
fi

# Actualización e instalacion de paquetes
echo "\nActualización e instalación de paquetes..."
apt update
apt install -y binutils

# Sacar modo incognito
DISTRIBUCION_DIR="/usr/lib/firefox/distribution"
POLITICAS_DIR="/etc/firefox/policies"

echo "\nCreación de direcctorios..."
mkdir -p "$DISTRIBUCION_DIR"
mkdir -p "$POLITICAS_DIR"

touch "$POLITICAS_DIR/policies.json"

echo "\nInsertando politicas nuevas..."
cat <<EOF > "$POLITICAS_DIR/policies.json"
{
  "policies": {
    "DisablePrivateBrowsing": true,
    "BlockAboutConfig": true,
    "DisableDeveloperTools": true
  }
}
EOF

# Conectar carpetas
ln -sf "$POLITICAS_DIR/policies.json" "$DISTRIBUCION_DIR/policies.json"

# reboot
echo "\nReiniciando firefox..."
killall firefox








 
