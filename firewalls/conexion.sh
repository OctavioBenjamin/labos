#!/bin/bash

# 1. Obtener el UID del usuario laboratorio
USER_NAME="laboratorio"
USER_ID=$(id -u $USER_NAME 2>/dev/null)

if [ -z "$USER_ID" ]; then
    echo "Error: El usuario $USER_NAME no existe."
    exit 1
fi

ACCION=$1

case $ACCION in
    on)
        # Limpiar reglas específicas del usuario
        iptables -D OUTPUT -m owner --uid-owner $USER_ID -j REJECT 2>/dev/null
        # Aseguramos que la política global sea ACCEPT por si acaso
        iptables -P OUTPUT ACCEPT
        echo "Internet habilitado para el usuario $USER_NAME."
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
        
        echo "Internet bloqueado para $USER_NAME. Solo Intranet permitida."
        ;;
    status)
        # Verificar si existe la regla de REJECT para ese UID
        if iptables -L OUTPUT -n | grep -q "owner UID match $USER_ID reject"; then
            echo "Estado para $USER_NAME: SOLO INTRANET"
        else
            echo "Estado para $USER_NAME: TODO ABIERTO"
        fi
        ;;
    *)
        echo "Uso: sudo bash $0 [on|off|status]"
        ;;
esac
