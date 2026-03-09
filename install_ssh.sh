#!/bin/bash

# Actualizar repositorios e instalar OpenSSH Server
sudo apt update
sudo apt install -y openssh-server

# Asegurar que el servicio esté corriendo y habilitado al inicio
sudo systemctl enable ssh
sudo systemctl start ssh

# Configuración básica de seguridad (Opcional pero recomendada)
# Backup del config original
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Permitir autenticación por contraseña temporalmente (si es necesario)
# Luego podrías cambiar esto a 'no' una vez copies tus llaves SSH
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Reiniciar para aplicar cambios
sudo systemctl restart ssh

echo "Configuración de SSH completada en $(hostname)"
