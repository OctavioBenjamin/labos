#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CONEXION_SH="$BASE_DIR/firewalls/conexion.sh"
WOL_SH="$BASE_DIR/remoto/wake-on-lan.sh"
PRENDER_AULA_SH="$BASE_DIR/software/prender_aula.sh"
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
            1) 
		ansible all -i /srv/labos/ansible/hosts.ini -m shell -a "sudo bash /home/admin/labos/firewalls/conexion.sh on" -u admin
	      ;;
            2) 
		ansible all -i /srv/labos/ansible/hosts.ini -m shell -a "sudo bash /home/admin/labos/firewalls/conexion.sh off" -u admin
	      ;;
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
            1) 
                if [ -f "$PRENDER_AULA_SH" ]; then
                    # Limpiar la pantalla antes para ver la salida del script de diagnóstico
                    clear
                    bash "$PRENDER_AULA_SH"
                    echo ""
                    read -p "Presione ENTER para volver al menú..."
                else
                    show_msg "Error: No se encontró el script de encendido en $PRENDER_AULA_SH"
                fi
                ;;
            2) 
              ansible all -i /srv/labos/ansible/hosts.ini -m shell -a "sudo shutdown -h now" -u admin
              ;;
            3) show_msg "Iniciando REINICIO remoto..." ;;
            4) break ;;
        esac
    done
}
menu_admin() {
    INVENTORY="/srv/labos/ansible/hosts.ini"

    while true; do
        CHOICE=$(whiptail --title "Administración" --menu "Opciones de gestión:" 15 60 3 \
            "1" "Ver estado de equipos (Ping)" \
            "2" "Volver al menú principal" 3>&1 1>&2 2>&3)
        
        if [ $? -ne 0 ]; then break; fi
        
        case "$CHOICE" in
            1)
                if [ -f "$INVENTORY" ]; then
                    # Cartel de espera mientras se procesan los pings
                    whiptail --title "Escaneando Red" --infobox "Haciendo ping a los equipos...\nPor favor, esperá unos segundos. ⏳" 10 50
                    
                    # Generamos el texto con el estado capturando la salida del bucle
                    ESTADO=$(
                        echo -e "Estado actual de los equipos:\n"
                        grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' "$INVENTORY" | sort -u | while read -r ip; do
                            if ping -c 1 -W 1 "$ip" &> /dev/null; then
                                echo "✅ ONLINE  - $ip"
                            else
                                echo "❌ OFFLINE - $ip"
                            fi
                        done
                    )
                    
                    # Mostramos el resultado final
                    whiptail --title "Inventario de Red" --scrolltext --msgbox "$ESTADO" 20 65
                else
                    whiptail --title "Error" --msgbox "No se encontró el inventario en $INVENTORY." 10 50
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
