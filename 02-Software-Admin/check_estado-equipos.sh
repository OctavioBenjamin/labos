#!/bin/bash
########################################################
# Proyecto: Labos - Automatización de Laboratorio
# Autores: 
# Octavio Benjamin - GitHub: https://github.com/OctavioBenjamin
# Zoi Lypnik - Github: https://github.com/ZoiLyp
########################################################


INVENTORY="/srv/labos/ansible/hosts.ini"

echo "🔍 Verificando estado de los equipos..."
echo "--------------------------------------"

# Extrae solo las IPs del inventario ignorando grupos [ ] y comentarios #
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' "$INVENTORY" | sort -u | while read -r ip; do
    # ping -c 1 (envía 1 paquete) -W 1 (espera máximo 1 segundo)
    if ping -c 1 -W 1 "$ip" &> /dev/null; then
        echo "✅ $ip - ONLINE"
    else
        echo "❌ $ip - OFFLINE"
    fi
done

echo "--------------------------------------"
