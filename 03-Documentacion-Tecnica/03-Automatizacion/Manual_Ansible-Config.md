# Documentación del Laboratorio - Ansible

Este directorio contiene un conjunto de herramientas automáticas (playbooks de Ansible) para configurar y administrar los equipos del laboratorio de manera remota y sin tener que hacer trabajo manual en cada computador.

---

## ¿Qué es Ansible?

Imagina que tenes 20 computadores y necesitas instalar un programa en todas. En lugar de ir una por una, Ansible permite escribir una lista de tareas una sola vez y él se encarga de ejecutarlas en todos los equipos al mismo tiempo.

---

## Archivos del Proyecto

### 1. hosts.ini (Lista de equipos)

**¿Para qué sirve?** Es la lista de todas las computadores del laboratorio con sus nombres y direcciones IP.

**¿Cómo usarla?** Si necesitas agregar un nuevo equipo, solo añade una línea con el nombre y la IP en la sección correspondiente.

**Ejemplo:**
```
Puesto_16  ansible_host=192.168.0.51
```

- `Puesto_16` = nombre del equipo
- `ansible_host` = dirección IP del equipo

Los equipos están agrupados en dos secciones:
- **planta_baja**: Computadoras de la planta baja
- **planta_alta**: Computadoras de la planta alta (actualmente vacía, lista para agregar)

---

### 2. ansible.cfg (Configuración básica)

**¿Para qué sirve?** Le dice a Ansible dónde está la lista de equipos y cómo conectarse a ellos.

**Contenido:**
- `host_key_checking = False`: No preguntará si conoce el equipo (útil para entornos de prueba)
- `inventory = hosts.ini`: Usa el archivo hosts.ini como lista de equipos
- `remote_user = admin`: Se conectará como el usuario "admin"
---

## Guía de Uso Rápido

---

## Estructura de un Playbook

Un playbook de Ansible es un archivo **YML** que describe un conjunto de tareas a ejecutar en uno o varios equipos.

### Componentes principales

```yaml
---
- name: Nombre descriptivo del play
  hosts: grupo_del_inventario   # ej: planta_baja, all
  become: yes                    # ejecutar como sudo (opcional)
  vars:                          # variables (opcional)
    paquete: nano
  tasks:                         # lista de tareas a ejecutar
    - name: Descripción de la tarea
      apt:                       # módulo a usar
        name: "{{ paquete }}"
        state: present
```

| Elemento   | ¿Qué es? |
|------------|----------|
| `---`      | Inicio del archivo YAML |
| `name`     | Descripción del play o tarea (visible en la salida) |
| `hosts`    | Grupo o equipo del inventario donde aplicar el play |
| `become`   | Ejecuta las tareas como superusuario (sudo) |
| `vars`     | Variables reutilizables dentro del playbook |
| `tasks`    | Lista ordenada de tareas a ejecutar |
| `handlers` | Tareas especiales que se ejecutan solo si una tarea las notifica (ej: reiniciar un servicio) |

### Módulos comunes

| Módulo | Uso |
|--------|-----|
| `apt` / `yum` | Instalar/eliminar paquetes |
| `copy` | Copiar archivos al equipo remoto |
| `file` | Crear/eliminar archivos o directorios |
| `service` / `systemd` | Iniciar/detener servicios |
| `shell` / `command` | Ejecutar comandos arbitrarios |
| `ping` | Verificar conectividad |

---

## Comandos Ad-hoc (una sola línea)

Ansible permite ejecutar tareas rápidas sin escribir un playbook completo.

### Verificar conectividad con `ping`

```bash
ansible all -m ping
```

Envía un "ping" a todos los equipos del inventario. Si responden, Ansible puede comunicarse correctamente.

```bash
ansible Puesto_16 -m ping
```

Contra un equipo específico.

### Ejecutar comandos con `shell`

```bash
ansible all -m shell -a "comando"
```

Ejecuta cualquier comando en los equipos remotos:

```bash
ansible all -m shell -a "uptime"           # saber hace cuánto están encendidos
ansible all -m shell -a "df -h"            # ver espacio en disco
ansible all -m shell -a "free -h"          # ver memoria RAM
ansible all -m shell -a "ip a"             # ver interfaces de red
ansible all -m shell -a "who"              # ver usuarios conectados
```

> `-m` indica el módulo a usar (`ping`, `shell`, `setup`, etc.).  
> `-a` pasa argumentos al módulo (en `shell` es el comando a ejecutar).

---

## Ejemplo: Playbook Base
Este es un playbook base que podés usar como punto de partida. Instala herramientas esenciales y verifica conectividad.

```yaml
---
- name: Configuración base del laboratorio
  hosts: all
  become: yes
  vars:
    admin_user: admin
    paquetes_base:
      - net-tools
      - curl

  tasks:
    - name: Actualizar lista de paquetes
      apt:
        update_cache: yes

    - name: Instalar paquetes base
      apt:
        name: "{{ paquetes_base }}"
        state: present

    - name: Verificar conectividad a internet
      shell:
        cmd: ping -c 1 8.8.8.8
      ignore_errors: yes
      register: ping_result

    - name: Mostrar resultado de conectividad
      debug:
        msg: "El equipo tiene {{ 'conectividad' if ping_result.rc == 0 else 'SIN conectividad' }} a internet"
```

### Cómo usarlo

1. Guardalo como `playbook_base.yml` en este directorio.
2. Ejecutalo contra todos los equipos:
   ```bash
   ansible-playbook playbook_base.yml
   ```
3. Ejecutalo contra un solo equipo:
   ```bash
   ansible-playbook playbook_base.yml --limit Puesto_16
   ```

---

## Conceptos Básicos

- **Host**: Una computadora en la red
- **Inventario**: Lista de todos los equipos
- **Playbook**: Lista de tareas que se ejecutan en orden
- **SSH**: Manera de comunicarse con equipos remotos de forma segura
- **Llave pública**: Como una contraseña pero más segura, permite acceso sin escribir contraseña
