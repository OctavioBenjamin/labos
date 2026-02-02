#!/bin/bash

# -P                (Política) regla por defecto de una cadena entera
# -A                Append: Añade la regla al final de la lista.
# INPUT / OUTPUT    La dirección del tráfico (lo que entra o lo que sale).
# -i / -o	        La interfaz de red (ej. lo para local, eth0 para internet).
# -p tcp	        El protocolo utilizado (TCP es el estándar para conexiones estables).
# --dport / --sport	Puerto de destino (destination) o puerto de origen (source).
# -j ACCEPT	        La acción a tomar: Aceptar el paquete de datos.

ACCION=$1

case $ACCION in
    on)
        # Desbloquear: Abrir todo
        iptables -P INPUT ACCEPT
        iptables -P OUTPUT ACCEPT
        iptables -F
        echo "Internet habilitado."
        ;;
    off)
        # Bloquear: Solo Intranet y SSH
        iptables -F
        iptables -P INPUT DROP
        iptables -P OUTPUT DROP
        
        # Loopback y SSH (Vital)
        iptables -A INPUT -i lo -j ACCEPT
        iptables -A OUTPUT -o lo -j ACCEPT
        iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
        iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
        
        # Intranet UNC y DNS
        iptables -A OUTPUT -d 200.16.16.0/24 -j ACCEPT
        iptables -A INPUT -s 200.16.16.0/24 -j ACCEPT
        iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
        iptables -A INPUT -p udp --sport 53 -j ACCEPT
        
        echo "Internet bloqueado. Solo Intranet permitida."
        ;;
    status)
        # Mostrar estado simple
        POLITICA=$(iptables -L OUTPUT -n | grep "Chain OUTPUT" | awk '{print $4}')
        if [ "$POLITICA" == "(policy" ]; then POLITICA=$(iptables -L OUTPUT -n | head -n 1 | awk '{print $4}'); fi
        
        if [ "$POLITICA" == "ACCEPT" ]; then
            echo "Estado: TODO ABIERTO"
        else
            echo "Estado: SOLO INTRANET"
        fi
        ;;
    *)
        echo "Uso: sudo bash internet.sh [on|off|status]"
        ;;
esac
