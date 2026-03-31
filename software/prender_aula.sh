#!/bin/bash

# Obtener la ruta base del proyecto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MAC_LIST="$BASE_DIR/datos/MACs.txt"

echo "-------------------------------------------------------"
echo " Herramienta de Diagnóstico: Wake-on-LAN (Aulas)"
echo "-------------------------------------------------------"

# Verificar si el archivo existe
if [ ! -f "$MAC_LIST" ]; then
    echo "[ERROR] No se encontró el archivo de MACs en: $MAC_LIST"
    exit 1
fi

echo "[INFO] Leyendo archivo: $MAC_LIST"
echo "-------------------------------------------------------"

contador=0
while IFS= read -r mac || [ -n "$mac" ]; do
    # Eliminar espacios en blanco y saltos de línea extraños
    mac=$(echo "$mac" | xargs)

    # Ignorar líneas vacías y comentarios
    if [[ -n "$mac" && ! "$mac" =~ ^# ]]; then
        ((contador++))
        echo "[$contador] Procesando MAC: $mac"
        
        # Ejecutar wakeonlan sin silenciar para ver la salida real
        if command -v wakeonlan >/dev/null 2>&1; then
            wakeonlan "$mac"
        else
            echo "[ERROR] El comando 'wakeonlan' no está instalado."
            exit 1
        fi
        echo "-------------------------------------------------------"
    fi
done < "$MAC_LIST"

echo "[FIN] Se procesaron $contador direcciones MAC."
