#!/bin/bash

# Capturamos el primer argumento: 'on' para internet, 'off' para bloqueo
ESTADO=$1

if [ "$ESTADO" == "on" ]; then
    # --- DESBLOQUEO ---
    ufw --force reset
    ufw default allow incoming
    ufw default allow outgoing
    echo "INTERNET: ACTIVADO (Firewall Reseteado)"

elif [ "$ESTADO" == "off" ]; then
    # --- BLOQUEO ---
    # 1. Aseguramos SSH para no colgarnos (Maestro .150)
    ufw allow in from 192.168.0.150 to any port 22 proto tcp
    ufw allow out to 192.168.0.150 port 22 proto tcp
    
    # 2. Permitir lo necesario
    ufw allow in on lo
    ufw allow out on lo
    ufw allow out 53
    ufw allow out to 200.16.16.0/24 port 443 proto tcp
    
    # 3. Muro
    ufw default deny incoming
    ufw default deny outgoing
    
    ufw --force enable
    echo "INTERNET: BLOQUEADO (Solo Aula Virtual)"

elif [ "$ESTADO" == "status" ]; then
    ufw status

else
    echo "Uso: sudo bash firewall.sh [on|off|status]"
fi
