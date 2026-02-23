# Instructivo Tecnico

En esta implementación se encuentra por defecto el usuario **laboratorio** solamente con acceso a paginas del dominio **unc.edu.ar** pero los demas usuarios no tienen esta limitación. 

Se uso `iptables` para filtrar por usuario las reglas de firewall.

En algunos equipos se implementara un usuario adicional sin contraseña para el uso libre de internet. 

## Activar y Desactivar la conexión

1. Primero para realizar esto se debe de entrar al administrador. `su - admin`. Contiene un archivo conexion.sh para activar y desactivar el acceso a internet.
2. Este archivo funciona **por equipo** y mediante terminal. Recordar que siempre hay que trabajar en el usuario Admin, en su home directory se encuentra un archivo de configuración de shell (~/.bashrc) que tiene tres alias:
* `internet-on`
* `internet-off`
* `internet-status`

Cada uno de esos llama al comando `sudo ~/labos/firewalls/conexion.sh [OPCION]` respectivamente. No hace falta indicar la opción, simplemente incovando cada alias ya alcanza. 

## Archivo conexion.sh
Este archivo tiene varias partes:

1. Configuración de .bashrc: Valida por primera vez y agrega los tres alias a la configuración de la shell.
2. Instalación del paquete `iptables-persistent`: En la primera instalación valida que no este instalado para realizarlo. Este paquete hace persistente la configuración de las reglas del firewall cada vez que se hace un on/off.
3. Validación del usuario: Se valida que exista para continuar.
4. Accion principal: En un case se toma el para metro $1 desde la terminal para decidir que hacer: 
    * **on** activa el acceso a internet.
    * **off** desactiva el acceso a internet.
    * **status** muestra el estado actual del firewall.


> Para proximas actualizaciones queremos escalar este archivo y combinarlo con parallel-ssh y enviar comandos simultaneamente a todos los equipos. 

> Tenemos que averiguar a que otras paginas darle luz verde.

> Hacer un instructivo para saber como agregar nuevas paginas y gestionar el repositorio.
