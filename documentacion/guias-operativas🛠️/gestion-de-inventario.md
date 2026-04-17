# Gestión de Inventario 📋

Esta guía explica cómo registrar un equipo en el sistema de gestión centralizada una vez que ha sido preparado físicamente.

## 🛑 Requisitos Previos
Antes de proceder, el equipo debe haber pasado por el proceso de [Instalación de un Nuevo Equipo](./instalación-de-un-nuevo-equipo.md), asegurando que:
1. Los scripts de `remoto/` (SSH y WoL) ya fueron ejecutados.
2. El equipo tiene conectividad a la red.

---

## 1. Relevamiento de Datos Críticos
Para que el servidor pueda "ver" y controlar el equipo, necesitamos obtener tres datos fundamentales desde la terminal del nuevo puesto:

1.  **Nombre del Puesto:** Siguiendo la nomenclatura actual (ej: `Puesto_15`).
2.  **Dirección IP:** Se obtiene con el comando `ip a` (identificar la IP en la interfaz cableada, ej: `192.168.1.XX`).
3.  **Dirección MAC:** Se obtiene al finalizar el script de WoL o con `cat /sys/class/net/[INTERFAZ]/address`.

---

## 2. Registro Administrativo
Carga el Nombre, IP y MAC en la **Planilla de Inventario en Drive** (solicita el enlace al administrador del laboratorio). Este paso es vital para el control de inventario físico.

---

## 3. Registro Técnico (Servidor de Gestión)
Para que el [Menú de Gestión](./../tutoriales-básicos🎓/guia-uso-menu.md) funcione con el nuevo equipo, debes actualizar los archivos de configuración en el servidor central:

### A. Encendido Remoto (`datos/MACs.txt`)
Añade la dirección MAC del equipo al final de este archivo. Esto permite que la opción de "Encender Aulas" le envíe el paquete de inicio.
```text
# Puesto 15
aa:bb:cc:dd:ee:ff
```

### B. Control de Firewall y Energía (`ansible/hosts.ini`)
Añade el nombre del puesto y su IP en el archivo de inventario de Ansible. Esto permite que el servidor pueda entrar por SSH para apagar la máquina o cerrar el internet.
```ini
[laboratorio]
Puesto_15 ansible_host=192.168.1.XX
```

---

## 💡 Verificación Final
Una vez guardados los archivos, abre el menú de gestión:
```bash
bash software/menu.sh
```
Ve a **Administración -> Ver estado de equipos** y confirma que el nuevo puesto aparece como ✅ **ONLINE**.
