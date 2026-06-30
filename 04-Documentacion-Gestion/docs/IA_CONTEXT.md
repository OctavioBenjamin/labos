# IA Context - Labos

## Descripción General
Sistema centralizado de administración y configuración automatizada para los laboratorios de la Facultad de Psicología (UNC, Argentina). Permite gestionar conectividad, encendido y mantenimiento de equipos desde una interfaz simplificada.

## Stack Tecnológico
- **Servidor gestión:** Debian 13
- **Clientes:** Ubuntu 24.04 LTS (Intel NUCs, All-In-Ones)
- **Automatización:** Bash + Ansible
- **Interfaz:** Whiptail (TUI)
- **Red/Firewall:** iptables + netfilter-persistent
- **Encendido remoto:** Wake-on-LAN + SSH
- **Herramientas:** nmap, ethtool, OpenSSH, Wine (InfoStat)

## Estructura del Proyecto

```
01-Configuracion-Sistemas/   # Scripts de setup (se ejecutan UNA VEZ por cliente)
02-Software-Admin/           # Herramientas de operación diaria
  ├── ansible/               # Playbooks de Ansible
  └── *.sh                   # Scripts de control (menú, firewall, wake, check)
03-Documentacion-Tecnica/    # Manuales, guías, troubleshooting
  ├── 01-Instalacion/        # Setup de equipos nuevos
  ├── 02-Control-de-Aula/    # Operación diaria (menú, firewall, energía)
  ├── 03-Automatizacion/     # Ansible y tareas masivas
  ├── 04-Infraestructura/    # Arquitectura de red y usuarios
  └── 05-Referencia-Tecnica/ # Documentación técnica profunda
04-Documentacion-Gestion/    # Plan SCM, convenciones
  └── docs/                  # IA Context, features, decisiones
```

## Roles de Usuario
- **Servidor:**
  - `informatica` → sudo total, uso del staff IT
  - `controlador` → solo puede ejecutar el menú (firewall/energía/estado)
- **Clientes:**
  - `admin` → sudo para tareas de mantenimiento
  - `laboratorio` → usuario de alumnos, sin sudo, sin password, internet restringible

## Capacidades Clave
1. **Firewall por UID** — Cortar/restaurar internet al usuario `laboratorio` vía iptables, permitiendo solo intranet UNC + dominios whitelist
2. **Power Management** — WoL para encender, SSH para apagar/reiniciar
3. **Monitoreo** — Ping-based online/offline
4. **Provisioning** — Setup completo de cero con Ansible
5. **Actualización Masiva** — `apt update/upgrade`, sincronización de repo, distribución de claves SSH

## Convenciones del Proyecto
- **Scripts de setup:** `setup_[servicio].sh`
- **Playbooks:** `[accion].yml`
- **Scripts de control:** `[accion]_[entidad].sh`
- **Firewall:** `fw_[perfil].sh`
- **Manuales:** `Manual_[tema].md` o `Fix_[tema].md`
- **Commits:** prefijos `material`, `tarea`, `docs`, `organizacion`, `recurso`, `linea-base`
- **Branch:** `main`

## Archivos No Versionados (`.gitignore`)
- `datos/` (listas de IPs, MACs)
- `*.txt`
- `02-Software-Admin/ansible/hosts.ini` (inventario Ansible con IPs reales)

## Arquitectura de Red
- Aula con ~20+ equipos conectados al mismo segmento
- Servidor de gestión en el mismo segmento
- Acceso a internet vía router UNC
- Whitelist de dominios educativos permitidos cuando el firewall está activo
