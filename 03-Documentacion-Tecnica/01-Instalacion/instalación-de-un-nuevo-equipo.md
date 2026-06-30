# Instalación de un Nuevo Equipo 🖥️

Esta guía detalla los pasos necesarios para configurar un nuevo equipo cliente desde cero e integrarlo al sistema de gestión de laboratorios (Labos).

## Instalar sistema operativo
1. Usuario: laboratorio
2. Host: laboratorio-minipc, laboratorio-nuc, etc.
3. Ubicación: Cordoba
> [!NOTE]
> La instalación no permite el nombre "admin" entonces usamos laboratorio, luego agregamos admin y dejamos configurados los permisos.

## Iniciar Sistema Operativo con Laboratorio
En estos pasos se ejecutan comandos básicos para que el usuario laboratorio quede funcionando.
> [!IMPORTANT]
> Antes de comenzar, asegúrese de tener conexión a internet.

### 1. Descargar el Repositorio

```
sudo apt install git
git clone https://github.com/octaviobenjamin/labos.git
cd labos
```

### 2. Instalación de Software y Entorno

Para instalar todo el software necesario (LibreOffice, Evince, InfoStat vía Wine, utilidades de red) y configurar el entorno del alumno (accesos directos, inicio automático de Firefox en el Aula Virtual, evitar la suspensión de pantalla), ejecute:
```
sudo bash 01-Configuracion-Sistemas/setup_sistema-base.sh laboratorio
```
*(Reemplace `laboratorio` por el nombre del usuario final si es diferente).*

### 3. Agregar administrador y modificar privilegios
Por motivos de seguridad, debemos crear un usuario `admin` y restringir los permisos del usuario por defecto del laboratorio (`laboratorio`).
Ejecute el siguiente script para realizar esta configuración:

```
sudo bash 01-Configuracion-Sistemas/setup_admin-principal.sh
```
Luego de esto borrar borrar la carpeta, por seguridad.
```
rm -rf ./labos
```

### 4. Reiniciar
Para aplicar cambios `reboot`

## Configuración avanzada con administrador

### 1. Levantar configuración de firewall
```
sudo bash ./01-Configuracion-Sistemas/setup_config_firewall.sh
```

## 2. Activar wake-on-lan
Esto permite realizar el encendido por LAN.

> [!IMPORTANT]
> Anotar la MAC del dispositivo en la panilla de Google.
```
sudo bash ./02-Software-Admin/wake_equipos-aula.sh
```

### 3. Habilitar Acceso Remoto (SSH)

Para que el servidor de gestión pueda comunicarse con este equipo, es necesario instalar y configurar el servidor SSH.
Desde el directorio raíz del repositorio, ejecute:
```
sudo bash 01-Configuracion-Sistemas/setup_config_ssh.sh
```
