#!/bin/bash
########################################################
# Proyecto: Labos - Automatización de Laboratorio
# Autores: 
# Octavio Benjamin - GitHub: https://github.com/OctavioBenjamin
# Zoi Lypnik - Github: https://github.com/ZoiLyp
# Descripción: Configuración de Ubuntu para Psicología UNC
########################################################

# --- CONFIGURACIÓN DE PRIVILEGIOS (SIN CONTRASEÑA) ---
RULE_FILE="/etc/sudoers.d/laboratorio-firewall"
SCRIPT="/home/admin/labos/02-Software-Admin/fw_conexion.sh"

echo "Configurando permisos de sudo sin contraseña..."

# Creamos la regla: Usuario admin | En cualquier PC | Como Root | Sin Password | Para este script
echo "admin ALL=(ALL) NOPASSWD: /usr/bin/bash $SCRIPT" | sudo tee $RULE_FILE > /dev/null
# Ajustamos permisos del archivo de regla (debe ser 0440 por seguridad de sudo)
sudo chmod 0440 $RULE_FILE

echo "Permisos configurados. Los alias internet-on/off ya no pedirán contraseña."

# 1. Instalar dependencias
sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent dnsutils

# 2. Configurar Alias en el .bashrc de admin
BASHRC="/home/admin/.bashrc"
if ! grep -q "internet-on" "$BASHRC"; then
    echo "alias internet-on='sudo bash $SCRIPT on'" >> "$BASHRC"
    echo "alias internet-off='sudo bash $SCRIPT off'" >> "$BASHRC"
    echo "alias internet-status='sudo bash $SCRIPT status'" >> "$BASHRC"
fi

# --- CONFIGURAR PERMISOS PARA ALIAS ---
echo "Configurando permisos de sudoers para los alias de firewall..."
echo "admin ALL=(ALL) NOPASSWD: /bin/bash $SCRIPT *" | sudo tee /etc/sudoers.d/90-conexion > /dev/null
sudo chmod 0440 /etc/sudoers.d/90-conexion
echo "¡Permisos configurados con éxito!"
