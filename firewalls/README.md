# Instructivo Tecnico

En esta implementación se encuentra por defecto el usuario **laboratorio** solamente con acceso a paginas del dominio **unc.edu.ar** pero los demas usuarios no tienen esta limitación. 

Se uso `iptables` para filtrar por usuario las reglas de firewall.

En algunos equipos se implementara un usuario adicional sin contraseña para el uso libre de internet. 

## Activar y Desactivar la conexión

Primero para realizar esto se debe de entrar al administrador. 

Se agrego un archivo conexion.sh para activar y desactivar el acceso a internet.

Este archivo funciona **por equipo** y mediante terminal. Recordar que siempre hay que trabajar en el usuario Admin, en su home directory se encuentra un archivo de configuración de shell (~/.bashrc) que tiene tres alias:
* `internet-on`
* `internet-off`
* `internet-status`

Cada uno de esos llama al comando `sudo ~/labos/firewalls/conexion.sh [OPCION]` respectivamente. No hace falta indicar la opción, simplemente incovando cada alias ya alcanza. 
