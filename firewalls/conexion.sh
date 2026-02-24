#!/bin/bash

# --- CONFIGURACIÓN ---
USER_NAME="laboratorio"
USER_ID=$(id -u $USER_NAME 2>/dev/null)

# --- CONFIGURACIÓN DE ALIAS ---
BASHRC_FILE="/home/admin/.bashrc"
SCRIPT_PATH="/home/admin/labos/firewalls/conexion.sh"
# Verificar si el alias ya existe para no duplicarlo
if ! grep -q "alias internet-on=" "$BASHRC_FILE"; then
    echo "Configurando alias en $BASHRC_FILE..."
    {
        echo ""
        echo "# Alias para control de firewall Laboratorio"
        echo "alias internet-on='sudo bash $SCRIPT_PATH on'"
        echo "alias internet-off='sudo bash $SCRIPT_PATH off'"
        echo "alias internet-status='sudo bash $SCRIPT_PATH status'"
    } >> "$BASHRC_FILE"
    
    # Notificar al usuario que debe recargar el bashrc
    echo "Alias creados. Ejecute 'source ~/.bashrc' para activarlos ahora."
fi

# --- VALIDACIÓN DE INSTALACIÓN ---
if ! dpkg -l | grep -q iptables-persistent; then
    echo "Servicio iptables-persistent no detectado. Instalando..."
    sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent
fi

# --- VALIDACIÓN DE USUARIO ---
if [ -z "$USER_ID" ]; then
    echo "Error: El usuario $USER_NAME no existe en esta máquina."
    exit 1
fi

ACCION=$1

case $ACCION in
    on)
        # Limpiar reglas específicas del usuario
        iptables -D OUTPUT -m owner --uid-owner $USER_ID -j REJECT 2>/dev/null
        # Aseguramos que la política global sea ACCEPT por si acaso
        iptables -P OUTPUT ACCEPT
        sudo netfilter-persistent save
        echo "Firewall DESACTIVADO para $USER_NAME."
        ;;
    off)
        # 1. Primero limpiamos reglas previas para no duplicar
        iptables -D OUTPUT -m owner --uid-owner $USER_ID -j REJECT 2>/dev/null
        
        # 2. PERMITIR: Intranet UNC
        iptables -A OUTPUT -m owner --uid-owner $USER_ID -d 200.16.16.0/24 -j ACCEPT
        
        # 3. PERMITIR: DNS (para que resuelva nombres de la intranet)
        iptables -A OUTPUT -m owner --uid-owner $USER_ID -p udp --dport 53 -j ACCEPT
        iptables -A OUTPUT -m owner --uid-owner $USER_ID -p tcp --dport 53 -j ACCEPT

        # 4. BLOQUEAR: Todo lo demás para este usuario
        iptables -A OUTPUT -m owner --uid-owner $USER_ID -j REJECT
        
        sudo netfilter-persistent save
        echo "Firewall ACTIVADO para $USER_NAME."        
        ;;
    status)
        # Definición de colores
        VERDE='\033[0;32m'
        ROJO='\033[0;31m'
        NC='\033[0m' # No Color (Reset)

        # Verificar si existe la regla de REJECT para ese UID
        if iptables -L OUTPUT -n | grep -q "owner UID match $USER_ID reject"; then
            # ROJO para "Solo Intranet" (Acceso restringido)
            echo -e "\nEstado para $USER_NAME: ${ROJO}SOLO INTRANET${NC}\n"
        else
            # VERDE para "Todo Abierto" (Acceso libre)
            echo -e "\nEstado para $USER_NAME: ${VERDE}TODO ABIERTO${NC}\n"
        fi
        ;;
    *)
        echo "Uso: sudo bash $0 [on|off|status]"
        ;;
esac
