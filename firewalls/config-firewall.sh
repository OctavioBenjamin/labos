#!/bin/bash

# --- CONFIGURACIÓN DE PRIVILEGIOS (SIN CONTRASEÑA) ---
RULE_FILE="/etc/sudoers.d/laboratorio-firewall"
SCRIPT_PATH="/home/admin/labos/firewalls/conexion.sh"

echo "Configurando permisos de sudo sin contraseña..."

# Creamos la regla: Usuario admin | En cualquier PC | Como Root | Sin Password | Para este script
echo "admin ALL=(ALL) NOPASSWD: /usr/bin/bash $SCRIPT_PATH" | sudo tee $RULE_FILE > /dev/null
# Ajustamos permisos del archivo de regla (debe ser 0440 por seguridad de sudo)
sudo chmod 0440 $RULE_FILE

echo "Permisos configurados. Los alias internet-on/off ya no pedirán contraseña."

# 1. Instalar dependencias
sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent dnsutils

# 2. Configurar Alias en el .bashrc de admin
BASHRC="/home/admin/.bashrc"
if ! grep -q "internet-on" "$BASHRC"; then
    echo "alias internet-on='sudo bash /home/admin/labos/firewalls/conexion.sh on'" >> "$BASHRC"
    echo "alias internet-off='sudo bash /home/admin/labos/firewalls/conexion.sh off'" >> "$BASHRC"
    echo "alias internet-status='sudo bash /home/admin/labos/firewalls/conexion.sh status'" >> "$BASHRC"
fi

# 3. Configurar el Crontab automáticamente
(sudo crontab -l 2>/dev/null; echo "@reboot sleep 30 && cd /home/admin/labos && git pull origin main && bash /home/admin/labos/firewalls/conexion.sh off") | sudo crontab -
