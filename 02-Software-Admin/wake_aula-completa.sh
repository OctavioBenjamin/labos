#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEFAULT_DIR="$BASE_DIR/datos"

mostrar_ayuda() {
    echo "Uso: $0 [archivo_MACs ...]"
    echo ""
    echo "Envía paquetes Wake-on-LAN a las direcciones MAC listadas en uno o más archivos."
    echo ""
    echo "Argumentos:"
    echo "  archivo_MACs    Ruta(s) a archivo(s) .txt con direcciones MAC."
    echo "                  Si no contiene '/', se busca en: $DEFAULT_DIR"
    echo "                  Si no se pasa ningún archivo, se usa: $DEFAULT_DIR/MACs.txt"
    echo ""
    echo "Ejemplos:"
    echo "  $0                             # datos/MACs.txt"
    echo "  $0 MACs_PB.txt                 # datos/MACs_PB.txt"
    echo "  $0 MACs_PB.txt MACs_PA.txt     # múltiples archivos"
    echo "  $0 ~/mis-macs.txt              # ruta absoluta"
    exit 1
}

resolver_archivo() {
    local archivo="$1"
    if [[ "$archivo" == */* ]]; then
        echo "$archivo"
    else
        echo "$DEFAULT_DIR/$archivo"
    fi
}

echo "-------------------------------------------------------"
echo " Herramienta de Diagnóstico: Wake-on-LAN (Aulas)"
echo "-------------------------------------------------------"

ARCHIVOS=("$@")
if [ ${#ARCHIVOS[@]} -eq 0 ]; then
    ARCHIVOS=("$DEFAULT_DIR/MACs.txt")
fi

total_general=0

for entrada in "${ARCHIVOS[@]}"; do
    archivo=$(resolver_archivo "$entrada")

    if [ ! -f "$archivo" ]; then
        echo "[ERROR] No se encontró el archivo: $archivo"
        echo "-------------------------------------------------------"
        continue
    fi

    echo "[INFO] Leyendo archivo: $archivo"
    echo "-------------------------------------------------------"

    contador=0
    while IFS= read -r mac || [ -n "$mac" ]; do
        mac=$(echo "$mac" | xargs)

        if [[ -n "$mac" && ! "$mac" =~ ^# ]]; then
            ((contador++))
            ((total_general++))
            echo "[$total_general] Procesando MAC: $mac"

            if command -v wakeonlan >/dev/null 2>&1; then
                wakeonlan "$mac"
            else
                echo "[ERROR] El comando 'wakeonlan' no está instalado."
                exit 1
            fi
            echo "-------------------------------------------------------"
        fi
    done < "$archivo"

    echo "[ARCHIVO] '$entrada' -> $contador MACs procesadas."
    echo "-------------------------------------------------------"
done

echo "[FIN] Total: $total_general direcciones MAC procesadas."

if [ $total_general -eq 0 ]; then
    echo "[ADVERTENCIA] No se procesó ninguna MAC. Verifique los archivos."
    mostrar_ayuda
fi
