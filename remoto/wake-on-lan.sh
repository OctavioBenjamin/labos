#!/ reorganization/bash

# 1. Identificar la interfaz de red activa (excluyendo loopback y wifi)
INTERFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v 'lo' | grep -v 'wlan' | head -n 1)

if [ -z "$INTERFACE" ]; then
    echo "No se encontró una interfaz Ethernet cableada."
    exit 1
fi

echo "--- Configurando WoL para la interfaz: $INTERFACE ---"

# 2. Instalar ethtool si no está
sudo apt update && sudo apt install -y ethtool

# 3. Activar WoL de forma inmediata
sudo ethtool -s $INTERFACE wol g

# 4. Crear un servicio de Systemd para que persista al reiniciar
cat <<EOF | sudo tee /etc/systemd/system/wol.service
[Unit]
Description=Configure Wake-on-LAN
After=network-online.target

[Service]
Type=oneshot
ExecStart=/sbin/ethtool -s $INTERFACE wol g

[Install]
WantedBy=multi-user.target
EOF

# 5. Habilitar el servicio
sudo systemctl daemon-reload
sudo systemctl enable wol.service

echo "------------------------------------------------------"
echo "¡Listo! El servicio ha sido creado y activado."
echo "Tu dirección MAC es: $(cat /sys/class/net/$INTERFACE/address)"
echo "Anota esa MAC para enviar el Magic Packet desde otro equipo."
