# Documentación del Laboratorio - Ansible

Este directorio contiene un conjunto de herramientas automáticas (playbooks de Ansible) para configurar y administrar los equipos del laboratorio de manera remota y sin tener que hacer trabajo manual en cada computador.

---

## ¿Qué es Ansible?

Imagina que tienes 20 computadores y necesitas instalar un programa en todas. En lugar de ir una por una, Ansible permite escribir una lista de tareas una sola vez y él se encarga de ejecutarlas en todos los equipos al mismo tiempo.

---

## Archivos del Proyecto

### 1. hosts.ini (Lista de equipos)

**¿Para qué sirve?** Es la lista de todas las computadores del laboratorio con sus nombres y direcciones IP.

**¿Cómo usarla?** Si necesitas agregar un nuevo equipo, solo añade una línea con el nombre y la IP en la sección correspondiente.

**Ejemplo:**
```
Puesto_16  ansible_host=172.18.170.51
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

### 3. setup_lab.yml (Configuración inicial de equipos nuevos)

**¿Para qué sirve?** Prepara una computadora nueva para que pueda ser administrada desde este sistema. Se encarga de tres cosas:
**¿Cuándo usarlo?** Cuando configures una computadora nueva por primera vez.

---

### 4. push_keys.yml (Distribuir llaves SSH)

**¿Para qué sirve?** Envía las llaves públicas de acceso a todos los equipos del laboratorio. Es más simple que setup_lab.yml porque solo se encarga de las llaves SSH.

**¿Cuándo usarlo?** Cuando necesitas dar acceso a usuarios nuevos (informatica, controlador) en todos los equipos.

---

### 5. pull_repo.yml (Actualizar repositorios)

**¿Para qué sirve?** Descarga la última versión del repositorio de laboratorio (labos) en todos los equipos. El repositorio contiene scripts y configuraciones que se usan en el laboratorio.
**¿Cómo funciona?** Ejecuta un `git pull` para traer los cambios desde GitHub.

**¿Cuándo usarlo?** Cuando hayas hecho cambios en el repositorio y quieras que todos los equipos tengan la versión actualizada.

---

### 6. preparar_equipos.yml (Instalar rsync)

**¿Para qué sirve?** Instala el programa "rsync" en todos los equipos de planta baja. Rsync se usa para sincronizar o copiar archivos entre equipos.

**¿Cuándo usarlo?** Solo una vez, cuando necesitas preparar los equipos por primera vez.

---

## Guía de Uso Rápido

### Conectarse a un equipo específico
```bash
ansible Puesto_16 -m ping
```

### Ejecutar una configuración en todos los equipos
```bash
ansible-playbook setup_lab.yml
```

### Actualizar todos los equipos con el último repositorio
```bash
ansible-playbook pull_repo.yml
```

### Ver estado de todos los equipos
```bash
ansible all -m setup
```

---

## Conceptos Básicos

- **Host**: Una computadora en la red
- **Inventario**: Lista de todos los equipos
- **Playbook**: Lista de tareas que se ejecutan en orden
- **SSH**: Manera de comunicarse con equipos remotos de forma segura
- **Llave pública**: Como una contraseña pero más segura, permite acceso sin escribir contraseña

---

## ¿Necesitas Help?

