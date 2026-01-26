#!/bin/bash

# 1. Pedir contraseña para el nuevo usuario admin
read -s -p "Introduce la contraseña para el usuario admin: " password
echo

# 2. Crear usuario admin y asignar contraseña
useradd -m -s /bin/bash admin
echo "admin:$password" | chpasswd

# 3. Dar sudoer a admin (agregándolo al grupo wheel o sudo según el sistema)
usermod -aG sudo admin || usermod -aG wheel admin

# 4. Quitar contraseña al usuario laboratorio
passwd -d laboratorio

# 5. Quitar sudoer a laboratorio
# Esto lo elimina de los grupos comunes de sudo
gpasswd -d laboratorio sudo 2>/dev/null || gpasswd -d laboratorio wheel 2>/dev/null

echo "Configuración completada. Admin creado y Laboratorio restringido. 🚀"
