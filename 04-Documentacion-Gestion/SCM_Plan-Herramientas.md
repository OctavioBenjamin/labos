# Planificación de Gestión de Configuración de Software (SCM) - Proyecto LABOS

## 1. Información del Proyecto
**Descripción:** Sistema de administración centralizada y configuración automatizada para los laboratorios de computación de la Facultad de Psicología, UNC. El proyecto permite gestionar conectividad, energía y mantenimiento mediante scripts de Bash y Ansible.

## 2. Estructura del Repositorio (Organizada)
La organización de carpetas sigue un estándar jerárquico para separar la ejecución de la documentación:

* **01-Configuracion-Sistemas/**: Scripts de despliegue, autoinstalación y reglas de red.
* **02-Software-Admin/**: Scripts de control operativo, menús y monitoreo.
* **03-Documentacion-Tecnica/**: Manuales, diagramas de arquitectura y guías de resolución.
* **04-Documentacion-Gestion/**: Reglas de administración del proyecto (incluye este plan).

## 3. Tabla de Ítems de Configuración (IC)
Reglas de nombrado y ubicación para asegurar la trazabilidad del sistema:

| Nombre del Ítem | Regla de Nombrado | Ubicación Física | Tipo |
| :--- | :--- | :--- | :--- |
| Script de Instalación | `setup_[nombre_servicio].sh` | `/01-Configuracion-Sistemas/` | Código |
| Playbook de Ansible | `deploy_[modulo].yaml` | `/01-Configuracion-Sistemas/` | Código |
| Script de Control | `[accion]_[entidad].sh` | `/02-Software-Admin/` | Código |
| Configuración de Firewall | `fw_[perfil].sh` | `/01-Configuracion-Sistemas/` | Configuración |
| Inventario de Red | `relevamiento_[aula]_[fecha].txt` | `/01-Configuracion-Sistemas/` | Datos |
| Manuales y Guías | `Manual_[tema].md` o `Fix_[tema].md` | `/03-Documentacion-Tecnica/` | Documentación |
| Información de grupo | `README.md` | `/` | Documentación |

## 4. Formato de los Commits
Se utilizarán los siguientes prefijos para estandarizar el historial de cambios:

* **material**: Adición de nuevos manuales o guías técnicas.
* **tarea**: Entrega o modificación de scripts de automatización.
* **docs**: Actualización de documentación técnica o README.
* **organizacion**: Reestructuración de carpetas o cambios de jerarquía.
* **recurso**: Adición de archivos de configuración (txt, yaml, json).
* **linea-base**: Creación de un hito de estabilidad (Baseline).

## 5. Gestión de Línea Base (Baseline)
Se establece una Línea Base al finalizar la configuración integral de cada laboratorio físico (ej. Laboratorio Planta Baja).

### Criterios de Calidad:
1. Validación de hardware (sin suspensiones automáticas).
2. Firewall activo e IPs/MACs relevadas correctamente.
3. Software base (InfoStat) instalado y operativo.
4. Acceso remoto funcional (SSH y Wake-on-LAN) verificado.
5. Estructura de archivos y nombres acorde a este documento.

## Autora
**[Zoi Lypnik]** - Redaccion y planificación del SCM - [@ZoiLyp](https://github.com/ZoiLyp)

