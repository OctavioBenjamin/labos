#!/bin/bash
########################################################
# Proyecto: Labos - Automatización de Laboratorio
# Autor: 
# Octavio Benjamin - GitHub: https://github.com/OctavioBenjamin
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

ARGS=(-e "true")
for ip in $(grep -i "PB" "$HOSTS" | cut -d'=' -f2); do
    ARGS+=(--tab -e "ssh -tt $USUARIO@$ip $COMANDO")
done

gnome-terminal "${ARGS[@]}"
