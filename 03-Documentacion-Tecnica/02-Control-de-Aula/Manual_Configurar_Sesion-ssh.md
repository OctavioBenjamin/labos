# Configurar conexion SSH

Tanto en linux como en windows el proceso es el mismo.

1. `ssh-keygen -t ed25519 -C "your_email@example.com"`
2. Copiar llave publica al usuario que solo controla. `/home/controlador/.ssh/authorized_keys`
3. Copiar llave publica solo equipos autorizados al usuario informatica. `/home/informatica/.ssh/authorized_keys`
4. Opcional, se puede configurar .ssh/config para configurar el host y realizar una conexion remota. 

### Extra
En Windows se puede crear un archivo .bat o .cmd para facilitar la conexion simplemente con doble click.
Es un archivo que ejecuta instrucciones de consola. El archivo podria tener `ssh controlador@[IP]` y al hacerle click te abre la conexion.

> [!NOTE] 
> No debe estar permitido el ingreso de password para iniciar una sesion SSH.
> Para agregar un usuario nuevo se debe copiar su llave a mano. 
