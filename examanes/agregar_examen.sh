#!/bin/bash

# Verificar si el usuario es root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Por favor, ejecuta este script con sudo."
  exit 1
fi

# 1. Crear el usuario examen
# -m crea el home, -s define la shell
if ! id "examen" &>/dev/null; then
    useradd -m -s /bin/bash examen
    echo "Usuario examen creado."
else
    echo "El usuario examen ya existe."
fi

# 2. Heredar configuraciones de 'laboratorio'
# Copiamos archivos de config (Firefox, LibreOffice, etc.) 
# para que aparezcan igual que en el otro usuario.
cp -r /home/laboratorio/. /home/examen/
chown -R examen:examen /home/examen/
# Eliminamos posibles archivos de bloqueo o específicos que no queramos clonar
rm -rf /home/examen/.cache

# 3. Configurar inicio de sesión automático (GDM3/LightDM)
# Asumiendo que usas Ubuntu/Debian (GDM3)
GDM_CONFIG="/etc/gdm3/custom.conf"
if [ -f "$GDM_CONFIG" ]; then
    sed -i 's/AutomaticLoginEnable = .*/AutomaticLoginEnable = true/' $GDM_CONFIG
    sed -i 's/AutomaticLogin = .*/AutomaticLogin = examen/' $GDM_CONFIG
fi

# 4. Quitar contraseña para el usuario examen
passwd -d examen

# 5. Ejecutar tu script de bloqueos de Firefox
if [ -f "examenes/conf_bloqueos.sh" ]; then
    bash examenes/conf_bloqueos.sh
    echo "Bloqueos de Firefox aplicados."
else
    echo "Error: No se encontró examenes/conf_bloqueos.sh"
fi

# 6. Configurar Firewall (UFW) específico para 'examen'
USER_UID=$(id -u examen)
iptables -F OUTPUT
iptables -A OUTPUT -o lo -m owner --uid-owner $USER_UID -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m owner --uid-owner $USER_UID -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -m owner --uid-owner $USER_UID -j ACCEPT
iptables -A OUTPUT -d 200.16.0.0/16 -m owner --uid-owner $USER_UID -j ACCEPT
iptables -A OUTPUT -m owner --uid-owner $USER_UID -j REJECT
apt-get install -y iptables-persistent
netfilter-persistent save

echo "Configuración completada con éxito."
