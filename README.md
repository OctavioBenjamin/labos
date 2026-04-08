# Labos - Gestión Automatizada de Laboratorios

Este repositorio contiene una colección de herramientas y scripts diseñados para la automatización, configuración y mantenimiento de laboratorios de computación (basados en Ubuntu 24.04), específicamente para la Facultad de Psicología de la UNC.

## 🚀 Funcionalidades Principales

- **Setup Inicial Automatizado**: Configuración del sistema, instalación de software esencial (Wine, InfoStat, LibreOffice) y personalización del entorno de usuario.
- **Control de Red (Firewall)**: Gestión de acceso a internet mediante listas blancas (`iptables`), permitiendo restringir la navegación a dominios institucionales.
- **Gestión Remota**: Encendido de equipos mediante Wake-on-LAN (WoL) y administración centralizada con Ansible (apagado/reinicio).
- **Panel de Control Centralizado**: Interfaz interactiva en terminal para gestionar el estado de los equipos, la energía y la conectividad.

---

## 📂 Estructura del Repositorio

- **`firewalls/`**: Scripts para activar/desactivar el acceso a internet y configuración de reglas persistentes.
- **`mantenimiento/`**: Scripts de instalación inicial (`setup-inicial.sh`) y gestión de usuarios administradores.
- **`remoto/`**: Herramientas para Wake-on-LAN e instalación de servicios SSH.
- **`software/`**: Panel de control principal (`menu.sh`) y scripts de diagnóstico de red.
- **`datos/`**: Archivos de configuración con listados de IPs y direcciones MAC de los equipos.
- **Archivos de raíz**: Configuración de **Ansible** (`ansible.cfg`, `hosts.ini`) para tareas administrativas masivas.

---

## 🛠️ Instalación y Setup Inicial

Para configurar un equipo nuevo con Ubuntu 24.04:

1. Crear el usuario **"laboratorio"** con contraseña (configurar inicio de sesión automático).
2. Instalar **git** y clonar el repo:
   ```sh
   sudo apt update && sudo apt install git -y
   git clone https://github.com/octaviobenjamin/labos
   cd labos/
   ```
3. Ejecutar el setup inicial (reemplazar `[USUARIO]` por el nombre del usuario creado):
   ```sh
   sudo bash mantenimiento/setup-inicial.sh [USUARIO]
   ```
4. Configurar usuarios administradores:
   ```sh
   sudo bash mantenimiento/add-admin.sh
   ```
5. Reiniciar el equipo.

---

## 🖥️ Uso del Laboratorio

### Panel de Gestión Centralizada
Para administrar el laboratorio desde un equipo central, ejecutar:
```sh
bash software/menu.sh
```
Desde este menú se puede:
- Controlar el Firewall de forma global.
- Encender los equipos (WoL).
- Ver el estado de conexión (Ping) de los equipos registrados.

### Control de Internet (Local)
En los equipos con el setup realizado, se pueden usar los siguientes alias desde la terminal del administrador:
- `internet-on`: Acceso total a internet.
- `internet-off`: Solo acceso a dominios permitidos (UNC).
- `internet-status`: Verifica el estado actual del firewall.

---

## ✍️ Autores
* **Octavio Mendez** - [OctavioBenjamin](https://github.com/OctavioBenjamin)
* **Zoi Lypnik** - [ZoiLyp](https://github.com/ZoiLyp)
