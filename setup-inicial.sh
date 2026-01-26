#! /bin/bash
########################################################
# Proyecto: Labos - Automatización de Laboratorio
# Autores: 
# Octavio Benjamin - GitHub: https://github.com/OctavioBenjamin/labos
# Zoi Lypnik - Github: https://github.com/ZoiLyp
# Descripción: Configuración de Ubuntu para Psicología UNC
########################################################


########################################################
# Quitar suspension de pantalla
########################################################
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

USUARIO="laboratorio"
HOME_USUARIO="/home/$USUARIO"

if [ ! -d "$HOME_USUARIO" ]; then
	echo
	echo "El usuario '$USUARIO' no existe en el ssitema"
 	echo
	exit 1
else
	echo
	echo "Se encontro el usuario"
 	echo
fi

DESCARGAS_DIR="$HOME_USUARIO/Descargas"
ESCRITORIO_DIR="$HOME_USUARIO/Escritorio"
echo "USUARIO: $USUARIO"
echo "Descargas: $DESCARGAS_DIR"

# Instalacion de WINE
echo "Instalando Wine..."
dpkg --add-architecture i386
apt install -y wget gnupg2 software-properties-common

mkdir -pm755 /etc/apt/keyrings
wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources


echo "Actualizando paquetes para wine..."
apt update

apt install --install-recommends -y winehq-stable
echo
echo "Wine instalado."
echo

#Instalacion de curl
echo "Instalacion de Curl"
apt install -y curl

# Instalacion de Libreoffice
echo "Instalando libre office"
apt install -y libreoffice

# Instalacion de Evince
echo "Instalando evince"
apt install -y evince

# Instalacion de p7zip y unzip
echo "Instalando descrompresor de archivos"
apt install -y p7zip-full unzip

# Instalacion de infostat
# Me traigo el instalador con curl para asegurar que sea la ultima version disponible
curl -L -o "$DESCARGAS_DIR/infostatinstaller_esp.exe" https://www.infostat.com.ar/descargas/demo/infostatinstaller_esp.exe
chown "$USUARIO":"$USUARIO" "$DESCARGAS_DIR/infostatinstaller_esp.exe"

INFOSTAT_INSTALLER="/home/$USUARIO/Descargas/infostatinstaller_esp.exe"
chown "$USUARIO":"$USUARIO" "$INFOSTAT_INSTALLER"
if [ -f "$INFOSTAT_INSTALLER" ]; then
	echo
	echo "Instalador encontrado en descargas"
 	echo

  #Habilita el acceso grafico
  xhost +local:"$USUARIO" > /dev/null

	echo "Inicializando Wine para el usuario $USUARIO (puede tardar unos minutos)..."
	sudo -u "$USUARIO" wineboot --init
	echo "Lanzando instalador de InfoStat..."
	sudo -u "$USUARIO" env DISPLAY=$DISPLAY wine "$INFOSTAT_INSTALLER"
else
	echo "No se encontro el instalador en descargas"
fi


# Crear accesos directos

DESKTOP_DIR="$HOME/Escritorio"

# Acceso directo para InfoStat
#INFOSTAT_DESKTOP="$ESCRITORIO_DIR/InfoStat.desktop"
#cat > "$INFOSTAT_DESKTOP" <<EOL
#[Desktop Entry]
#Name=InfoStat
#Comment=Iniciar InfoStat con Wine
#Exec=wine \"$HOME/.wine/drive_c/Program Files/InfoStat/InfoStat.exe\"
#Icon=wine
#Terminal=false
#Type=Application
#Categories=Education;
#EOL
#chmod +x "$INFOSTAT_DESKTOP"

# Acceso directo para LibreOffice
LIBREOFFICE_DESKTOP="$ESCRITORIO_DIR/LibreOffice.desktop"
cat > "$LIBREOFFICE_DESKTOP" <<EOL
[Desktop Entry]
Name=LibreOffice
Comment=Suite ofimática LibreOffice
Exec=libreoffice
Icon=libreoffice-main
Terminal=false
Type=Application
Categories=Office;
EOL
chmod +x "$LIBREOFFICE_DESKTOP"

# Acceso directo para la Calculadora de GNOME
CALC_DESKTOP="$ESCRITORIO_DIR/Calculadora.desktop"
cat > "$CALC_DESKTOP" <<EOL
[Desktop Entry]
Name=Calculadora
Comment=Calculadora de Ubuntu
Exec=gnome-calculator
Icon=org.gnome.Calculator
Terminal=false
Type=Application
Categories=Utility;
EOL
chmod +x "$CALC_DESKTOP"
chown "$USUARIO":"$USUARIO" "$CALC_DESKTOP"




# FIREFOX AUTOSTART

# Crear carpeta de autostart si no existe
AUTOSTART_DIR="$HOME_USUARIO/.config/autostart"
sudo -u "$USUARIO" mkdir -p "$AUTOSTART_DIR"

# Crear lanzador de Firefox
FIREFOX_AUTOSTART="$AUTOSTART_DIR/firefox-aula-virtual.desktop"
cat > "$FIREFOX_AUTOSTART" <<EOL
[Desktop Entry]
Type=Application
Exec=firefox https://psicologia.aulavirtual.unc.edu.ar/
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Firefox Aula Virtual
EOL

# Ajustar permisos para el usuario
chown "$USUARIO":"$USUARIO" "$FIREFOX_AUTOSTART"
