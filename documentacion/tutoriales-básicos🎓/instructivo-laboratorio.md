# Instructivo en caso de problemas
Este instructivo es en caso de que no podamos dar asistencia de forma inmediata.

## Conectarse al servidor
Cualquier encargado del laboratorio va a necesitar ingresar al servidor.
1. Abrir la terminal o cmd 
2. Conectarse al servidor por ssh: `ssh controlador@[IP_Servidor]`

De todas formas dejamos un acceso directo en el escritorio que se llama `controlador`

## PC sin internet
Esto puede ocurrir porque queda activado el firewall (Es lo que le cierra la salida a internet al usuario laboratorio)
1. Ingresar al admin `su - admin`
2. Activar el internet `internet-on` o si falla ese alias tirar `sudo bash labos/firewall/conexion.sh on`

En caso de que este no sea el problema, avisar al soporte informatica el numero de puesto.
Ayuda mucho si se adjunta una foto de la salida del siguiente comando: `ip a`

## PC no bootea
Una de las PC no encuentra el disco para iniciar el sistema operativo.
1. Prender la PC
2. Mientras este iniciando, apretar repetidamente alguna de las siguintes teclas: F2, F10, F11, F12, DEL o ESC (Generalmente es F2)
3. Salir sin guardar


