# Instalación de un Nuevo Equipo 🖥️

Esta guía detalla los pasos necesarios para configurar un nuevo equipo cliente desde cero e integrarlo al sistema de gestión de laboratorios (Labos).

## Instalar sistema operativo
1. Usuario: laboratorio
2. Host: laboratorio-minipc, laboratorio-nuc, etc.
3. Ubicacion: Cordoba

## Inicar Sistema Operativo con Laboratorio
En estos pasos se ejecutan comandos basicos para que el usuario laboratorio quede funcionando.
> [!IMPORTANT]
> Antes de comenzar, asegúrese de tener conexión a internet.

### 1. Descargar el Repositorio

```
sudo apt install git
git clone https://github.com/octaviobenjamin/labos.git
cd labos
```
> [!NOTE]
> El script solicitará crear una contraseña para el usuario `admin`, le otorgará permisos de superusuario (sudo) y removerá la contraseña y permisos de administrador del usuario `laboratorio`.

### 2. Instalación de Software y Entorno

Para instalar todo el software necesario (LibreOffice, Evince, InfoStat vía Wine, utilidades de red) y configurar el entorno del alumno (accesos directos, inicio automático de Firefox en el Aula Virtual, evitar la suspensión de pantalla), ejecute:
```
sudo bash config_inicial/setup-inicial.sh laboratorio
```
*(Reemplace `laboratorio` por el nombre del usuario final si es diferente).*

### 3. Agregar administrador y modificar privilegios
Por motivos de seguridad, debemos crear un usuario `admin` y restringir los permisos del usuario por defecto del laboratorio (`laboratorio`).
Ejecute el siguiente script para realizar esta configuración:

```
sudo bash config_inicial/add-admin.sh
```
Luego de esto borrar borrar la carpeta, por seguridad.

```
rm -rf ./labos
```
### 4. Reiniciar
Para aplicar cambios `reboot`

## Configuracion avanzada con administrador

### 1. Levantar configuracion de firewall
```
sudo bash ./labos/firewalls/config-firewall.sh
```

## 2. Activar wake-on-lan
Esto permite realizar el encendido por LAN.

> [!IMPORTANT]
> Anotar la MAC del dispositivo en la panilla de Google.
```
sudo bash ./labos/remoto/wake-on-lan.sh
```

### 3. Habilitar Acceso Remoto (SSH)

Para que el servidor de gestión pueda comunicarse con este equipo, es necesario instalar y configurar el servidor SSH.
Desde el directorio raíz del repositorio, ejecute:

```
sudo bash remoto/install_ssh.sh
```
