#!/bin/bash
########################################################
# Proyecto: Labos - Automatización de Laboratorio
# Descripción: Descarga e inicia el instalador de InfoStat con Wine
########################################################

DESCARGAS_DIR="$HOME/Descargas"
INSTALLER_URL="https://www.infostat.com.ar/descargas/demo/infostatinstaller_esp.exe"
INSTALLER_PATH="$DESCARGAS_DIR/infostatinstaller_esp.exe"

# Crear carpeta de descargas si no existe
mkdir -p "$DESCARGAS_DIR"

echo "--- Iniciando proceso para InfoStat ---"

# 1. Descargar el instalador si no existe
if [ ! -f "$INSTALLER_PATH" ]; then
    echo "Descargando instalador de InfoStat..."
    curl -L -o "$INSTALLER_PATH" "$INSTALLER_URL"
else
    echo "El instalador ya se encuentra en Descargas."
fi

# 2. Inicializar Wine si es la primera vez
if [ ! -d "$HOME/.wine" ]; then
    echo "Inicializando configuración de Wine (esto puede demorar)..."
    wineboot --init
fi

# 3. Lanzar el instalador
echo "Lanzando el instalador GUI..."
wine "$INSTALLER_PATH"

echo "--- Proceso finalizado ---"
