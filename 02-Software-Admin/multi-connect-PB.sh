#!/bin/bash
########################################################
# Proyecto: Labos - Automatización de Laboratorio
# Autores: 
# Octavio Benjamin - GitHub: https://github.com/OctavioBenjamin
# Zoi Lypnik - Github: https://github.com/ZoiLyp
########################################################

HOSTS="./ansible/hosts.ini"
USUARIO="admin"

echo "Nota: la sesión ssh al servidor debe ser con 'ssh -X -C' para poder abrir una terminal de gnome"

if [ $# -eq 0 ]; then
    echo "Uso: $0 \"comando\""
    echo "Ejemplo: $0 \"hostname; uptime; read\""
    exit 1
fi

COMANDO="$*"

ARGS=()
for ip in $(grep -i "PB" "$HOSTS" | cut -d'=' -f2); do
    if [ ${#ARGS[@]} -eq 0 ]; then
        ARGS+=(-- "ssh -tt $USUARIO@$ip '$COMANDO'")
    else
        ARGS+=(--tab -- "ssh -tt $USUARIO@$ip '$COMANDO'")
    fi
done

gnome-terminal "${ARGS[@]}"
