#!/bin/bash

# Verificar si el usuario es root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Por favor, ejecuta este script con sudo."
  exit 1
fi

# 1. Crear el usuario examen
if ! id "examen" &>/dev/null; then
    useradd -m -s /bin/bash examen
    echo "✅ Usuario examen creado."
else
    echo "⚠️ El usuario examen ya existe."
fi

# 2. "Clonar" el software y entorno (Configuraciones)
# El software ya está en /usr/bin, aquí copiamos los perfiles y accesos directos
echo "Factura de entorno: Copiando configs de laboratorio a examen..."
cp -r /home/laboratorio/. /home/examen/
# REGLA ORO: Ajustar permisos para que 'examen' sea dueño de sus archivos
chown -R examen:examen /home/examen/
# Limpiar basura temporal
rm -rf /home/examen/.cache

# 3. Configurar inicio de sesión automático
GDM_CONFIG="/etc/gdm3/custom.conf"
if [ -f "$GDM_CONFIG" ]; then
    sed -i '/AutomaticLoginEnable/s/^#//' $GDM_CONFIG
    sed -i '/AutomaticLogin /s/^#//' $GDM_CONFIG
    sed -i 's/AutomaticLoginEnable = .*/AutomaticLoginEnable = true/' $GDM_CONFIG
    sed -i 's/AutomaticLogin = .*/AutomaticLogin = examen/' $GDM_CONFIG
    echo "✅ Autologin configurado para 'examen'."
fi

# 4. Quitar contraseña
passwd -d examen

# 5. Bloqueos de Firefox
# Corregí la ruta: si el script está en examenes/ usa esa ruta
if [ -f "examenes/conf_bloqueos.sh" ]; then
    bash ./examenes/conf_bloqueos.sh
    echo "✅ Bloqueos de Firefox aplicados."
else
    echo "❌ Error: No se encontró examenes/conf_bloqueos.sh"
fi

# 6. Firewall restrictivo para 'examen'
USER_UID=$(id -u examen)
# Limpiar solo reglas de salida para no afectar el resto del sistema
iptables -S OUTPUT | grep "owner UID match $USER_UID" | sed 's/-A/-D/' | while read line; do iptables $line; done

iptables -A OUTPUT -o lo -m owner --uid-owner $USER_UID -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m owner --uid-owner $USER_UID -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -m owner --uid-owner $USER_UID -j ACCEPT
iptables -A OUTPUT -d 200.16.0.0/16 -m owner --uid-owner $USER_UID -j ACCEPT
iptables -A OUTPUT -m owner --uid-owner $USER_UID -j REJECT

# Persistencia
if dpkg -l | grep -q iptables-persistent; then
    netfilter-persistent save
else
    apt-get update && apt-get install -y iptables-persistent
    netfilter-persistent save
fi

echo "🚀 Configuración completada. ¡Aula lista para el examen!"
