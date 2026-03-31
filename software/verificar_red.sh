#!/bin/bash

# Configuración
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MAC_LIST="$BASE_DIR/datos/MACs.txt"
RED="172.18.170.0/23"
TEMP_SCAN="/tmp/nmap_scan_laboratorio.txt"
MAPA_MACS="/tmp/mac_ip_map.txt"

if [ ! -f "$MAC_LIST" ]; then
    echo "Error: No se encuentra $MAC_LIST"
    exit 1
fi

echo "-------------------------------------------------------"
echo " Escaneo de Red Laboratorio - Detección Directa"
echo "-------------------------------------------------------"
echo "[1/2] Escaneando subred $RED..."
echo "Por favor, introduce tu contraseña si se solicita."

# 1. Escaneo ARP limitando conexiones paralelas para no saturar
sudo nmap -sn -PR --max-parallelism 20 --max-retries 4 "$RED" > "$TEMP_SCAN"

echo "[2/2] Cruzando datos con MACs.txt..."
echo "-------------------------------------------------------"
printf "%-20s | %-15s | %-10s\n" "Dirección MAC" "Dirección IP" "Estado"
echo "-------------------------------------------------------"

# 2. Obtener datos de Nmap
awk '/Nmap scan report/{ip=$NF; gsub(/[()]/,"",ip)} /MAC Address:/{print toupper($3), ip}' "$TEMP_SCAN" > "$MAPA_MACS"

# 3. Sumar la tabla ARP nativa de Linux (bala de plata)
ip neigh show | awk '{print toupper($5), $1}' >> "$MAPA_MACS"

# 4. Limpiar duplicados por si Nmap y Linux encontraron lo mismo
sort -u -o "$MAPA_MACS" "$MAPA_MACS"

while read -r mac_buscada || [ -n "$mac_buscada" ]; do
    mac_buscada=$(echo "$mac_buscada" | xargs | tr '[:lower:]' '[:upper:]')
    if [[ -z "$mac_buscada" || "$mac_buscada" =~ ^# ]]; then continue; fi

    # Búsqueda en el mapa consolidado
    ip_encontrada=$(grep "^$mac_buscada" "$MAPA_MACS" | awk '{print $2}' | head -n 1)

    if [ -n "$ip_encontrada" ]; then
        printf "%-20s | %-15s | \e[32m[VIVO]\e[0m\n" "$mac_buscada" "$ip_encontrada"
    else
        printf "%-20s | %-15s | \e[31m[OFFLINE]\e[0m\n" "$mac_buscada" "---"
    fi
done < "$MAC_LIST"

# Limpieza
rm -f "$TEMP_SCAN" "$MAPA_MACS"

echo "-------------------------------------------------------"
echo "Escaneo finalizado."
