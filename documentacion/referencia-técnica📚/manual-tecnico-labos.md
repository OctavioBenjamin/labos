# Manual técnico del sistema Labos

## 1) Objetivo
Este documento explica cómo funciona el código del proyecto Labos, qué hace cada script y cómo se relacionan entre sí para administrar laboratorios de computación.

El sistema tiene dos frentes de trabajo:

1. Configuración de cada equipo cliente (instalación, seguridad, servicios y utilidades).
2. Administración centralizada desde un equipo de gestión (menú de terminal, Ansible, Wake-on-LAN y chequeo de estado).

## 2) Arquitectura funcional
### 2.1 Componentes
- Equipo central de administración: ejecuta el menú principal y comandos remotos.
- Equipos del aula: reciben acciones remotas y aplican políticas locales.
- Inventario Ansible: lista IPs objetivo para tareas masivas.
- Lista de MACs: permite encendido remoto por Wake-on-LAN.
- Lista blanca de dominios: define excepciones de internet cuando se restringe la navegación.

### 2.2 Usuarios y modelo de permisos
- Usuario laboratorio: usuario final de uso cotidiano en clase.
- Usuario admin: usuario administrativo con privilegios para mantenimiento y operación.

La lógica de seguridad del firewall está orientada al usuario laboratorio, aplicando reglas por UID para limitar su salida a internet cuando corresponde.

## 3) Estructura de scripts y responsabilidades
### 3.1 Setup y mantenimiento
- mantenimiento/setup-inicial.sh:
  - Desactiva suspensión de pantalla y energía en GNOME.
  - Instala paquetes base: Wine, curl, LibreOffice, Evince, p7zip, unzip.
  - Descarga instalador de InfoStat y lo ejecuta con Wine para el usuario indicado.
  - Crea accesos directos en escritorio.
  - Configura autostart para abrir Aula Virtual en Firefox al iniciar sesión.

- mantenimiento/add-admin.sh:
  - Crea usuario admin.
  - Asigna contraseña al usuario admin.
  - Agrega admin a grupo de sudo (o wheel según disponibilidad).
  - Elimina contraseña del usuario laboratorio.
  - Retira a laboratorio de grupos de administración.

- mantenimiento/mantenimiento-general.sh:
  - Actualiza paquetes del sistema.
  - Ejecuta limpieza de paquetes obsoletos.
  - Limpia temporales antiguos en /tmp.
  - Recorta logs de journalctl a 500 MB.
  - Reconfigura paquetes pendientes con dpkg.

### 3.2 Firewall y conectividad
- firewalls/config-firewall.sh:
  - Instala dependencias de firewall (iptables-persistent, dnsutils).
  - Crea reglas sudoers para permitir ejecutar el script de conexión sin contraseña desde admin.
  - Agrega alias en shell de admin:
    - internet-on
    - internet-off
    - internet-status
  - Configura tarea de arranque para:
    - actualizar repositorio (git pull)
    - aplicar estado restringido (off) al reinicio

- firewalls/conexion.sh:
  - Parámetro on:
    - elimina regla de rechazo para UID de laboratorio
    - deja política global OUTPUT en ACCEPT
    - guarda reglas persistentes
  - Parámetro off:
    - limpia rechazo previo
    - permite salida a red intranet UNC (200.16.16.0/24)
    - permite DNS (TCP y UDP puerto 53)
    - resuelve dominios de whitelist.txt a IPs y habilita esas IPs
    - agrega rechazo final para todo lo demás del usuario laboratorio
    - guarda reglas persistentes
  - Parámetro status:
    - inspecciona si existe la regla reject para ese UID
    - informa estado visual:
      - SOLO INTRANET
      - TODO ABIERTO

### 3.3 Gestión remota
- remoto/install_ssh.sh:
  - Instala openssh-server.
  - Habilita y arranca servicio SSH.
  - Realiza backup de configuración SSH.
  - Habilita autenticación por contraseña en sshd_config.

- remoto/wake-on-lan.sh:
  - Detecta interfaz cableada.
  - Instala ethtool.
  - Activa Wake-on-LAN inmediato.
  - Crea servicio systemd para persistencia tras reinicio.

### 3.4 Operación centralizada
- software/menu.sh:
  - Interfaz principal con whiptail.
  - Menú Firewall y Red:
    - ejecuta acciones on/off en todos los hosts mediante Ansible.
    - consulta estado local con conexion.sh status.
  - Menú Energía:
    - encendido masivo vía prender_aula.sh.
    - apagado masivo vía Ansible y shutdown.
  - Menú Administración:
    - consulta estado online/offline por ping a IPs del inventario.

- software/prender_aula.sh:
  - Lee lista de MACs.
  - Filtra comentarios y líneas vacías.
  - Envía magic packets con wakeonlan para cada equipo.

- software/check_status.sh:
  - Lee IPs del inventario Ansible.
  - Hace ping corto por cada IP.
  - Reporta ONLINE/OFFLINE.

- software/verificar_red.sh:
  - Escanea subred con nmap ARP.
  - Combina resultados de nmap + tabla ip neigh.
  - Cruza MACs de referencia contra IP detectada.
  - Muestra tabla de presencia por MAC.

## 4) Flujo operativo recomendado
### 4.1 Provisioning de equipo nuevo
1. Crear usuario laboratorio (según política local).
2. Clonar repositorio en el equipo.
3. Ejecutar setup inicial indicando usuario objetivo.
4. Ejecutar add-admin para separación de permisos.
5. Ejecutar configuración de firewall.
6. Instalar y validar SSH.
7. Configurar Wake-on-LAN.
8. Registrar MAC e IP en las fuentes de inventario.

### 4.2 Operación diaria
1. Ingresar al equipo de administración.
2. Ejecutar software/menu.sh.
3. Elegir la acción:
   - Abrir/cerrar internet.
   - Encender/apagar equipos.
   - Ver estado de conectividad.

### 4.3 Mantenimiento periódico
- Ejecutar mantenimiento-general.sh con confirmación manual o con parámetro -y.
- Revisar logs y disponibilidad de disco.
- Validar que el inventario de Ansible y las MACs estén actualizados.

## 5) Dependencias del sistema
### 5.1 Paquetes y utilidades usadas
- apt, dpkg, journalctl, find
- iptables, netfilter-persistent
- dnsutils (dig)
- whiptail
- ansible
- openssh-server
- ethtool
- wakeonlan
- nmap
- winehq-stable

### 5.2 Dependencias de datos
- firewalls/whitelist.txt
- inventario Ansible (ruta absoluta usada en scripts)
- archivo de MACs (ruta esperada por scripts)

## 6) Rutas críticas y supuestos de implementación
El código usa varias rutas absolutas y convenciones de entorno que deben mantenerse o adaptarse:

- /home/admin/labos
- /srv/labos/ansible/hosts.ini
- estructura de carpetas consistente para datos de red

Si cambia la ubicación del repositorio o inventario, hay que ajustar scripts para evitar fallas operativas.

## 7) Consideraciones de seguridad
- Se habilitan reglas sudoers NOPASSWD para operación rápida de firewall desde admin.
- SSH queda con autenticación por contraseña habilitada por script de instalación inicial.
- Se recomienda evaluar endurecimiento posterior:
  - migrar a llaves SSH
  - limitar origen de conexión
  - revisar alcance exacto de comandos permitidos en sudoers

## 8) Riesgos técnicos detectados
1. Duplicación potencial de reglas ACCEPT en firewall off:
   - la ejecución repetida puede acumular reglas de salida permitida por IP.
2. Reinicio remoto no implementado completamente en menú:
   - opción de reinicio muestra mensaje pero no ejecuta reboot remoto efectivo.
3. Acoplamiento a rutas fijas:
   - cambios de ubicación en repositorio o inventario impactan ejecución.
4. Dependencia de resolución DNS dinámica para whitelist:
   - dominios con IPs variables pueden requerir refresco frecuente.
5. Múltiples scripts con lógica de chequeo similar:
   - potencial de divergencia funcional si se modifica uno y no otro.

## 9) Troubleshooting rápido
### 9.1 El firewall no cambia de estado
- Validar que exista usuario laboratorio.
- Validar sudoers y permisos 0440 en archivos de /etc/sudoers.d.
- Confirmar que iptables-persistent esté instalado.
- Revisar salida de estado para confirmar regla reject por UID.

### 9.2 No funciona encendido remoto
- Verificar BIOS (Wake-on-LAN habilitado).
- Verificar que interfaz cableada quede con wol g.
- Verificar instalación de wakeonlan.
- Confirmar formato y vigencia de MACs.

### 9.3 Fallan acciones remotas masivas
- Verificar conectividad SSH.
- Verificar inventario Ansible y usuario remoto.
- Ejecutar una prueba puntual contra un host antes de all.

### 9.4 InfoStat o Wine no inicia
- Validar descarga correcta del instalador.
- Confirmar permisos de archivo en Descargas.
- Verificar inicialización de Wine con el usuario objetivo.
- Validar contexto gráfico (DISPLAY y acceso local xhost).

## 10) Mejoras sugeridas (backlog técnico)
1. Parametrizar rutas críticas mediante variables de entorno o archivo .env.
2. Unificar scripts de diagnóstico en una sola implementación reutilizable.
3. Implementar realmente la acción de reinicio remoto en el menú.
4. Fortalecer gestión de iptables para evitar acumulación de reglas.
5. Agregar validaciones de precondiciones al inicio de cada script.
6. Incorporar logging estructurado por fecha y host para auditoría.
7. Agregar pruebas de humo para cada operación principal.

## 11) Resumen ejecutivo
Labos implementa una plataforma de operación de aula basada en Bash, Ansible y herramientas de red de Linux. Su fortaleza principal es la automatización rápida de tareas repetitivas (conectividad, energía y preparación de equipos). Para consolidar su madurez operativa, conviene avanzar en parametrización, robustez de firewall y endurecimiento de acceso remoto.
