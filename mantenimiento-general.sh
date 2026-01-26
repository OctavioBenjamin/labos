#!/bin/bash
########################################################
# Proyecto: Labos - Automatización de Laboratorio
# Autores: 
# Octavio Benjamin - GitHub: https://github.com/OctavioBenjamin/
# Zoi Lypnik - Github: https://github.com/ZoiLyp
# Descripción: Configuración de Ubuntu para Psicología UNC
########################################################


ACEPTAR_TODO=$1

if [ "$ACEPTAR_TODO" != "-y" ]; then
    echo "--------------------------------------------------------"
    echo "🚨 ¡ADVERTENCIA DE LIMPIEZA PROFUNDA!"
    echo "Se borrarán registros de alumnos, descargas temporales"
    echo "y el caché de Firefox para liberar espacio."
    echo "--------------------------------------------------------"
    read -p " ¿Deseas continuar? (s/n): " confirmacion
    if [[ ! $confirmacion =~ ^[Ss]$ ]]; then
        echo "❌ Operación cancelada por el usuario."
        exit 1
    fi
fi

echo "🚀 Iniciando mantenimiento..."

# 1. Actualización
apt update && apt full-upgrade -y

# 2. Quitar programas que ya no se usan
echo "🧹 Eliminando restos de instalaciones viejas..."
apt autoremove -y
apt autoclean -y

# 3. Limpieza de basura temporal
echo "🗑️ Borrando archivos temporales de más de 7 días..."
find /tmp -type f -atime +7 -delete

# 4. Control de archivos de registro (Logs)
# Aquí borramos el historial viejo para no agotar el disco.
echo "📋 Recortando el historial del sistema a los últimos 500MB..."
journalctl --vacuum-size=500M

# 5. Reparar posibles errores
echo "🛠️ Asegurando que todo esté bien configurado..."
dpkg --configure -a

echo "✅ ¡Listo!"
