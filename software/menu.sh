#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CONEXION_SH="$BASE_DIR/firewalls/conexion.sh"
WOL_SH="$BASE_DIR/remoto/wake-on-lan.sh"
IP_LIST="$BASE_DIR/datos/IPs.txt"
MAC_LIST="$BASE_DIR/datos/MACs.txt"

TITLE="Laboratorio UNC - Gestión Centralizada"

show_msg() {
    whiptail --title "$TITLE" --msgbox "$1" 10 60
}

menu_firewall() {
    while true; do
        CHOICE=$(whiptail --title "Firewall y Red" --menu "Opciones de conectividad:" 15 60 4 \
            "1" "Activar Internet (Todo Abierto)" \
            "2" "Desactivar Internet (Solo Intranet)" \
            "3" "Estado del Internet" \
            "4" "Volver al menú principal" 3>&1 1>&2 2>&3)
        
        if [ $? -ne 0 ]; then break; fi
        
        case "$CHOICE" in
            1) sudo bash "$CONEXION_SH" on; show_msg "Internet ACTIVADO." ;;
            2) sudo bash "$CONEXION_SH" off; show_msg "Internet RESTRINGIDO." ;;
            3) STATUS=$(sudo bash "$CONEXION_SH" status); show_msg "Estado actual:\n$STATUS" ;;
            4) break ;;
        esac
    done
}

menu_energia() {
    while true; do
        CHOICE=$(whiptail --title "Energía" --menu "Opciones de energía:" 15 60 4 \
            "1" "Encender Aulas (WoL)" \
            "2" "Apagar Aulas (SSH Shutdown)" \
            "3" "Reiniciar Aulas (SSH Reboot)" \
            "4" "Volver al menú principal" 3>&1 1>&2 2>&3)
        
        if [ $? -ne 0 ]; then break; fi
        
        case "$CHOICE" in
            1) show_msg "Enviando paquetes de encendido..." ;;
            2) show_msg "Iniciando secuencia de APAGADO remoto..." ;;
            3) show_msg "Iniciando REINICIO remoto..." ;;
            4) break ;;
        esac
    done
}

menu_admin() {
    while true; do
        CHOICE=$(whiptail --title "Administración" --menu "Opciones de gestión:" 15 60 3 \
            "1" "Ver lista de IPs/MACs" \
            "2" "Volver al menú principal" 3>&1 1>&2 2>&3)
        
        if [ $? -ne 0 ]; then break; fi
        
        case "$CHOICE" in
            1)
                if [ -f "$IP_LIST" ] && [ -f "$MAC_LIST" ]; then
                    DATOS="IPs Registradas:\n$(cat "$IP_LIST")\n\nMACs Registradas:\n$(cat "$MAC_LIST")"
                    whiptail --title "Inventario de Red" --scrolltext --msgbox "$DATOS" 20 65
                else
                    show_msg "Error: No se encontraron los archivos de datos."
                fi
                ;;
            2) break ;;
        esac
    done
}

# --- Bucle Principal ---
while true; do
    MAIN_CHOICE=$(whiptail --title "$TITLE" --menu "Seleccione una categoría:" 15 60 4 \
        "1" "Firewall y Red" \
        "2" "Energía" \
        "3" "Administración" \
        "4" "Salir" 3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then break; fi

    case "$MAIN_CHOICE" in
        1) menu_firewall ;;
        2) menu_energia ;;
        3) menu_admin ;;
        4) break ;;
    esac
done

clear
echo "Sesión de administración finalizada correctamente."
