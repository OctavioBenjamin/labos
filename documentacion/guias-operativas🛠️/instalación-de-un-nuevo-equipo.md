# Instalación de un Nuevo Equipo 🖥️

Esta guía detalla los pasos necesarios para configurar un nuevo equipo cliente desde cero e integrarlo al sistema de gestión de laboratorios (Labos).

> [!IMPORTANT]
> Antes de comenzar, asegúrese de tener conexión a internet y de haber iniciado sesión con un usuario con privilegios de administrador.

## 1. Descargar el Repositorio

El primer paso es clonar el repositorio de **Labos** en el equipo local:

```bash
git clone https://github.com/octaviobenjamin/labos.git
cd labos
```

## 2. Configuración de Usuarios y Privilegios

Por motivos de seguridad, debemos crear un usuario `admin` y restringir los permisos del usuario por defecto del laboratorio (`laboratorio`).

Ejecute el siguiente script para realizar esta configuración:

```bash
sudo bash config_inicial/add-admin.sh
```

> [!NOTE]
> El script solicitará crear una contraseña para el usuario `admin`, le otorgará permisos de superusuario (sudo) y removerá la contraseña y permisos de administrador del usuario `laboratorio`.

## 3. Instalación de Software y Entorno

Para instalar todo el software necesario (LibreOffice, Evince, InfoStat vía Wine, utilidades de red) y configurar el entorno del alumno (accesos directos, inicio automático de Firefox en el Aula Virtual, evitar la suspensión de pantalla), ejecute:

```bash
sudo bash config_inicial/setup-inicial.sh laboratorio
```

*(Reemplace `laboratorio` por el nombre del usuario final si es diferente).*

## 4. Habilitar Acceso Remoto (SSH)

Para que el servidor de gestión pueda comunicarse con este equipo, es necesario instalar y configurar el servidor SSH.

Desde el directorio raíz del repositorio, ejecute:

```bash
sudo bash remoto/install_ssh.sh
```

## 5. Configurar Wake-on-LAN (Encendido Remoto)

Para poder encender el equipo de forma remota, siga estos pasos:

### 5.1. Configuración en la BIOS
1. Reinicie el equipo e ingrese a la configuración de la **BIOS/UEFI**.
2. Busque la opción relacionada con **Wake-on-LAN** (a veces bajo las opciones de red, *Power Management* o *APM Configuration*) y actívela.
3. Asegúrese de desactivar opciones de ahorro de energía estrictas que puedan apagar completamente la tarjeta de red (ej. *ErP Ready* o *Deep Sleep*).
4. Guarde los cambios y reinicie el sistema operativo.

### 5.2. Habilitación en el Sistema Operativo
Una vez de vuelta en Ubuntu, ejecute el script de configuración de red para asegurar que la interfaz de red reaccione a los paquetes mágicos:

```bash
sudo bash remoto/wake-on-lan.sh
```

> [!IMPORTANT]
> Al finalizar la ejecución, el script mostrará la **dirección MAC** de la tarjeta de red.
> Debe anotar esta dirección MAC en la planilla de cálculo de **"Equipos de Laboratorio"** ubicada en el Google Drive de administración para que el servidor de Labos sepa cómo encender este equipo específicamente.
