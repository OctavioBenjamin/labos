# Conceptos Básicos

## Terminal Linux

| Comando | Qué hace |
|---------|----------|
| `ls` | Lista archivos y carpetas del directorio actual |
| `cd <carpeta>` | Navega a otra carpeta |
| `cp <origen> <destino>` | Copia un archivo |
| `mv <origen> <destino>` | Mueve o renombra un archivo |
| `rm <archivo>` | Elimina un archivo |
| `sudo <comando>` | Ejecuta un comando como administrador |
| `chmod <permisos> <archivo>` | Cambia permisos de lectura/escritura/ejecución |
| `chown <usuario>:<grupo> <archivo>` | Cambia el dueño de un archivo |
| `passwd` | Cambia la contraseña del usuario actual |
| `cat <archivo>` | Muestra el contenido de un archivo en pantalla |
| `grep <patrón> <archivo>` | Busca texto dentro de un archivo |
| `|` (pipe) | Pasa la salida de un comando a otro (ej: `ls | grep algo`) |

## SSH (Conexión Remota)

- **SSH** — Protocolo para conectarse de forma segura a un equipo remoto.
- `ssh usuario@ip` — Conecta a un equipo remoto (ej: `ssh admin@192.168.1.10`).
- **Llave pública** — Archivo que permite entrar sin escribir contraseña.

## Git (Control de Versiones)

- `git clone <url>` — Descarga un repositorio por primera vez.
- `git add <archivo>` — Prepara un archivo para guardarlo.
- `git commit -m "mensaje"` — Guarda los cambios preparados.
- `git push` — Sube los cambios al repositorio remoto.
- `git pull` — Trae los cambios del repositorio remoto.

## Shellscript (Scripts de Bash)

- **Script** — Archivo de texto con comandos que se ejecutan en orden.
- `#!/bin/bash` — Primera línea de un script, indica que es bash.
- `#` — Comentario, el resto de la línea se ignora.
- `if; then; fi` — Estructura condicional.
- `for; do; done` — Estructura repetitiva.
- `$variable` — Accede al valor de una variable.

## Ansible (Automatización)

- **Ad-hoc** — Comando que se ejecuta contra uno o varios equipos desde la terminal.
- **Playbook** — Archivo YAML con una lista de tareas a ejecutar.
- **Inventario** — Lista de equipos (hosts) que Ansible gestiona.
- **Módulo** — Herramienta específica (ej: `apt`, `copy`, `service`).
- `ansible-playbook playbook.yml` — Ejecuta un playbook.

## Redes

- **IP** — Dirección numérica que identifica un equipo en la red (ej: `192.168.1.10`).
- **MAC** — Identificador único de fábrica de la placa de red.
- **Firewall** — Filtro que deja pasar o bloquea tráfico de red según reglas.
- **Puerto** — "Puerta" lógica por donde entra/sale tráfico (ej: puerto 80 para web, puerto 22 para SSH).
- **Puerto 22** — Puerto estándar del protocolo SSH, clave en este proyecto.

## Glosario del Proyecto

- **Equipo** — Cada uno de los clientes (NUCs / All-In-Ones) gestionados por Ansible.
- **Servidor** — La máquina central (Debian) desde donde se administra todo el laboratorio.
- **Aula** — El laboratorio con ~20+ equipos conectados a la misma red.
- **WoL (Wake-on-LAN)** — Tecnología para encender un equipo de forma remota.
- **Playbook** — Conjunto de tareas Ansible (ver arriba).
- **Firewall por UID** — Reglas de iptables que cortan internet al usuario `laboratorio` pero dejan conectividad al resto.
- **iptables** — Herramienta de firewall de Linux (configura reglas de red).
- **Intranet** — Red interna de la Universidad.
