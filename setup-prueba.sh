#! /bin/bash

# 1. ACTUALIZACIÓN (Faltaba el upgrade para aplicar cambios)
echo "Actualizando listas y sistema..."
apt update && apt upgrade -y

# 2. USUARIO Y RUTAS
USUARIO="laboratorio"
HOME_USUARIO="/home/$USUARIO"
DESCARGAS_DIR="$HOME_USUARIO/Descargas"
ESCRITORIO_DIR="$HOME_USUARIO/Escritorio"

if [ ! -d "$HOME_USUARIO" ]; then
    echo "❌ El usuario '$USUARIO' no existe."
    exit 1
fi

# 3. QUITAR SUSPENSIÓN (Se debe ejecutar COMO el usuario para que funcione)
sudo -u "$USUARIO" gsettings set org.gnome.desktop.session idle-delay 0
sudo -u "$USUARIO" gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# 4. INSTALACIÓN DE WINE (Noble/Ubuntu 24.04)
echo "🍷 Instalando Wine..."
dpkg --add-architecture i386
apt install -y wget gnupg2 software-properties-common
mkdir -pm755 /etc/apt/keyrings
wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
apt update
apt install --install-recommends -y winehq-stable

# 5. OTRAS HERRAMIENTAS
apt install -y curl libreoffice evince p7zip-full unzip

# 6. INFOSTAT
mkdir -p "$DESCARGAS_DIR"
echo "📥 Descargando InfoStat..."
curl -L -o "$DESCARGAS_DIR/infostatinstaller_esp.exe" https://www.infostat.com.ar/descargas/demo/infostatinstaller_esp.exe

# --- CORRECCIÓN CRÍTICA DE PERMISOS ---
# El error de tu imagen era: chown usuario:usuario (sin el path completo antes de los dos puntos)
chown "$USUARIO:$USUARIO" "$DESCARGAS_DIR/infostatinstaller_esp.exe"

INFOSTAT_INSTALLER="$DESCARGAS_DIR/infostatinstaller_esp.exe"
if [ -f "$INFOSTAT_INSTALLER" ]; then
    echo "🖥️ Lanzando instalador gráfico..."
    
    # Habilitar acceso al servidor X
    xhost +local:"$USUARIO" > /dev/null
    
    # Ejecutar Wine (Asegurando que encuentre el ejecutable)
    sudo -u "$USUARIO" env DISPLAY=:0 wine "$INFOSTAT_INSTALLER"
else
    echo "❌ No se encontró el instalador."
fi

# 7. ACCESOS DIRECTOS (Corrigiendo el dueño al final)
mkdir -p "$ESCRITORIO_DIR"
LIBREOFFICE_DESKTOP="$ESCRITORIO_DIR/LibreOffice.desktop"
cat > "$LIBREOFFICE_DESKTOP" <<EOL
[Desktop Entry]
Name=LibreOffice
Exec=libreoffice
Icon=libreoffice-main
Type=Application
Categories=Office;
EOL

chmod +x "$LIBREOFFICE_DESKTOP"
chown "$USUARIO:$USUARIO" "$LIBREOFFICE_DESKTOP"

# Borrar contraseña
passwd -d "$USUARIO"
