#!/bin/bash
########################################################
# Proyecto: Labos - Automatización de Laboratorio
# Autores: 
# Octavio Benjamin - GitHub: https://github.com/OctavioBenjamin
# Zoi Lypnik - Github: https://github.com/ZoiLyp
########################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

IP_LIST="$BASE_DIR/datos/IPs.txt"

# Ansible
HOSTS="$BASE_DIR/02-Software-Admin/ansible/hosts.ini"
# Grupos de Ansible
PB="planta_baja"
PA="planta_alta"

# Archivos MAC por aula
MACs_PA="MACs_PA.txt"
MACs_PB="MACs_PB.txt"

# Scripts dentro de cada equipo
CONEXION_SCRIPT="sudo /etc/psico/fw_conexion.sh"
PRENDER_AULA_SH="$BASE_DIR/02-Software-Admin/wake_aula-completa.sh"

TITLE="Laboratorio UNC - Gestión Centralizada"

show_msg() {
    whiptail --title "$TITLE" --msgbox "$1" 10 60
}

menu_firewall() {
  # Se selecciona el grupo y la accion que se necesite
  while true; do
        CHOICE=$(whiptail --title "Firewall y Red" --menu "Opciones de conectividad:" 20 65 7 \
            "1" "[ TODO ] Activar Internet" \
            "2" "[ TODO ] Desactivar Internet" \
            "3" "[ PB  ] Activar Internet" \
            "4" "[ PB  ] Desactivar Internet" \
            "5" "[ PA  ] Activar Internet" \
            "6" "[ PA  ] Desactivar Internet" \
            "7" "Volver al menu principal" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then break; fi
        
        case "$CHOICE" in
            1) GRUPO="all"; ACCION="on"  ;;
            2) GRUPO="all"; ACCION="off" ;;
            3) GRUPO="$PB"; ACCION="on"  ;;
            4) GRUPO="$PB"; ACCION="off" ;;
            5) GRUPO="$PA"; ACCION="on"  ;;
            6) GRUPO="$PA"; ACCION="off" ;;
            7) break ;;
        esac

        ansible "$GRUPO" -i "$HOSTS" -m shell -a "$CONEXION_SCRIPT $ACCION"
    done
}
menu_energia() {
    while true; do
        CHOICE=$(whiptail --title "Energía" --menu "Opciones de energía:" 20 65 7 \
            "1" "[ TODO ] Encender Aulas" \
            "2" "[ TODO ] Apagar Aulas" \
            "3" "[ TODO ] Reiniciar Aulas" \
            "4" "[ PB  ] Encender Aula" \
            "5" "[ PB  ] Apagar Aula" \
            "6" "[ PB  ] Reiniciar Aula" \
            "7" "[ PA  ] Encender Aula" \
            "8" "[ PA  ] Apagar Aula" \
            "9" "[ PA  ] Reiniciar Aula" \
            "10" "Volver al menú principal" 3>&1 1>&2 2>&3)
        [ $? -ne 0 ] && break

        case "$CHOICE" in
            1)  GRUPO="all";   ACCION="encender";  MAC_FILES="$MACs_PB $MACs_PA" ;;
            2)  GRUPO="all";   ACCION="apagar"   ;;
            3)  GRUPO="all";   ACCION="reiniciar" ;;
            4)  GRUPO="$PB";   ACCION="encender";  MAC_FILES="$MACs_PB" ;;
            5)  GRUPO="$PB";   ACCION="apagar"   ;;
            6)  GRUPO="$PB";   ACCION="reiniciar" ;;
            7)  GRUPO="$PA";   ACCION="encender";  MAC_FILES="$MACs_PA" ;;
            8)  GRUPO="$PA";   ACCION="apagar"   ;;
            9)  GRUPO="$PA";   ACCION="reiniciar" ;;
            10) break ;;
        esac

        case "$ACCION" in
            encender)
                clear
                bash "$PRENDER_AULA_SH" $MAC_FILES
                echo ""
                read -p "Presione ENTER para volver al menú..."
                ;;
            apagar)
                ansible "$GRUPO" -i "$HOSTS" -m shell -a "sudo shutdown -h now"
                ;;
            reiniciar)
                ansible "$GRUPO" -i "$HOSTS" -m shell -a "sudo reboot"
                ;;
        esac
    done
}
menu_admin() {
    while true; do
        CHOICE=$(whiptail --title "Administración" --menu "Opciones de gestión:" 15 60 2 \
            "1" "Ver estado de equipos (Ping)" \
            "2" "Volver al menú principal" 3>&1 1>&2 2>&3)
        [ $? -ne 0 ] && break

        case "$CHOICE" in
            1)
                clear
                ansible all -i "$HOSTS" -m ping
                echo ""
                read -p "Presione ENTER para volver al menú..."
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
