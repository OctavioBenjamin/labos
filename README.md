# Labos - Gestión de Laboratorios 🖥️

Sistema de administración centralizada y configuración automatizada para laboratorios de computación de la Facultad de Psicología, UNC. Este proyecto permite gestionar de manera eficiente la conectividad, energía y mantenimiento de múltiples equipos desde una interfaz simplificada.

## 📋 Resumen General

Labos centraliza tareas complejas de administración de red y sistemas en scripts de Bash y playbooks de Ansible. Su objetivo es permitir que el personal de tecnología educativa y sistemas pueda controlar el estado del aula (encendido, apagado, acceso a internet) sin necesidad de interactuar profundamente con la línea de comandos de cada equipo individual.

## 🛠️ Stack Tecnológico

El sistema se apoya en tecnologías estándar de Linux para garantizar estabilidad y rendimiento:

- **Sistemas Operativos:** Ubuntu 24.04 LTS (Equipos Cliente) y Debian 13 (Servidor de Gestión).
- **Lenguaje Principal:** Bash Scripting.
- **Automatización Masiva:** [Ansible](https://www.ansible.com/).
- **Interfaz de Usuario:** [Whiptail](https://linux.die.net/man/1/whiptail) (TUI - Terminal User Interface).
- **Seguridad de Red:** `iptables` y `netfilter-persistent`.
- **Gestión Remota:** OpenSSH, Wake-on-LAN (WoL).
- **Diagnóstico:** `nmap`, `ping`, `dnsutils`.
- **Compatibilidad de Software:** [Wine](https://www.winehq.org/) (para la ejecución de InfoStat).

## 📂 Documentación

Para una guía detallada sobre la instalación, operación y resolución de problemas, consulte la carpeta de documentación:

- [Guía de Inicio Rápido](./documentacion/README.md)
- [Arquitectura de Red](./documentacion/arquitectura-y-contexto🏗️/Arquitectura-red.md)
- [Manual del Menú de Gestión](./documentacion/tutoriales-básicos🎓/guia-uso-menu.md)

---
**Desarrollado para la Facultad de Psicología - UNC**
